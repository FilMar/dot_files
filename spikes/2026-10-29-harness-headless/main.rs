// SPIKE — throwaway code. Question: can a Rust subprocess drive claude (stream-json)
// and pi (rpc) interactively over stdin/stdout: send prompt, receive streaming events,
// answer a permission request? Verdict: yes/no per engine.
// Run:  cargo run --release --manifest-path spikes/2026-10-29-harness-headless/Cargo.toml -- pi
//       cargo run --release --manifest-path spikes/2026-10-29-harness-headless/Cargo.toml -- claude
//
// ANSWER (2026-10-29):
// pi: YES end to end. Rust drives the full loop: prompt accepted, text streams as
//   message_update deltas, bash tool exec shows as tool_execution_start/end, the run
//   closes with agent_settled. No permission prompts exist in RPC mode: pi is
//   trust-based (docs/security.md). A confirm-before-bash gate would be an extension
//   using ctx.ui.select/confirm, surfaced as extension_ui_request -> answered with
//   extension_ui_response (handler implemented here, never triggered).
// claude: PROTOCOL YES, RUNTIME BLOCKED. The JSON channel works from Rust (spawn,
//   stdin/stdout, system init, SessionStart hooks fire — the local tb/ti hook chain
//   rides along even headless — assistant and result events parse fine). The agentic
//   loop never started: claude injects a stale ANTHROPIC_API_KEY from
//   ~/.claude/settings.json env and dies with "Invalid API key" before any tool call.
//   The can_use_tool control_request/control_response round-trip (implemented here)
//   stayed untriggered. Fix is one line in the user's credentials; not a protocol
//   problem.
// VERDICT: pi drives fully from Rust today. claude drives mechanically and is blocked
// only by a bad key in settings.json; permission flow unverified until that is fixed.

// ---------------- parameter block ----------------
const PI_MODEL: &str = "nemotron-3-nano:30b-cloud"; // ollama tag known to work
const PI_PROVIDER: &str = "ollama";
const PROMPT: &str = "Use the bash tool (Bash for claude) to run exactly this one command: echo hello-from-tool. Then reply with the single word: done";
const WORKDIR: &str = "/tmp"; // cwd of the spawned engine
const TIMEOUT_SECS: u64 = 150; // hard stop waiting for the run to settle
// --------------------------------------------------

use std::io::{BufRead, BufReader, Write};
use std::process::{ChildStdin, Command, Stdio};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

fn main() {
    let engine = std::env::args().nth(1).unwrap_or_else(|| "pi".into());
    let mut cmd = match engine.as_str() {
        "pi" => {
            let mut c = Command::new("pi");
            c.args(["--mode", "rpc", "--no-session", "-nt",
                    "--provider", PI_PROVIDER, "--model", PI_MODEL, "-t", "bash"]);
            c
        }
        "claude" => {
            let mut c = Command::new("claude");
            c.args(["-p", "--output-format", "stream-json",
                    "--input-format", "stream-json", "--verbose"]);
            c
        }
        other => panic!("unknown engine {other}"),
    };
    let mut child = cmd
        .current_dir(WORKDIR)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .expect("spawn engine");

    let stdin = Arc::new(Mutex::new(child.stdin.take().unwrap()));
    let send = {
        let stdin = Arc::clone(&stdin);
        move |v: serde_json::Value| {
            let mut w = stdin.lock().unwrap();
            w.write_all(serde_json::to_string(&v).unwrap().as_bytes()).unwrap();
            w.write_all(b"\n").unwrap();
            w.flush().unwrap();
        }
    };

    // first message
    match engine.as_str() {
        "pi" => send(serde_json::json!({"id": "p1", "type": "prompt", "message": PROMPT})),
        "claude" => send(serde_json::json!({"type": "user", "message": {"role": "user",
            "content": [{"type": "text", "text": PROMPT}]}})),
        _ => unreachable!(),
    }

    let stdout = BufReader::new(child.stdout.take().unwrap());
    let start = Instant::now();
    let (mut streamed, mut tool_seen, mut perm_roundtrip, mut settled) =
        (false, false, false, false);
    let mut texts: Vec<String> = Vec::new();

    for line in stdout.lines() {
        let Ok(line) = line else { break };
        if line.trim().is_empty() {
            continue;
        }
        let Ok(ev) = serde_json::from_str::<serde_json::Value>(&line) else {
            println!("NONJSON {}", &line[..line.len().min(200)]);
            continue;
        };
        let t = ev["type"].as_str().unwrap_or("");

        match engine.as_str() {
            "pi" => match t {
                "response" => println!("RESP {} ok={}", ev["command"], ev["success"]),
                "tool_execution_start" => {
                    tool_seen = true;
                    println!("TOOL_START {} {}", ev["toolName"], &ev["args"].to_string()[..120.min(ev["args"].to_string().len())]);
                }
                "tool_execution_end" => println!("TOOL_END {} err={}", ev["toolName"], ev["isError"]),
                "extension_ui_request" => {
                    // permission / dialog: auto-approve
                    let method = ev["method"].as_str().unwrap_or("");
                    println!("UI_REQUEST {method}");
                    let resp = match method {
                        "confirm" => serde_json::json!({"type": "extension_ui_response", "id": ev["id"], "confirmed": true}),
                        "select" => serde_json::json!({"type": "extension_ui_response", "id": ev["id"], "value": ev["options"][0]}),
                        _ => serde_json::json!({"type": "extension_ui_response", "id": ev["id"], "value": "yes"}),
                    };
                    send(resp);
                    perm_roundtrip = true;
                    println!("UI_ANSWERED");
                }
                "message_update" => {
                    let d = &ev["assistantMessageEvent"];
                    if d["type"] == "text_delta" {
                        streamed = true;
                        texts.push(d["delta"].as_str().unwrap_or("").into());
                    }
                }
                "agent_settled" => {
                    settled = true;
                    println!("SETTLED");
                    break;
                }
                _ => {}
            },
            "claude" => match t {
                "system" => println!("SYSTEM {}", ev["subtype"].as_str().unwrap_or("")),
                "control_request" => {
                    println!("PERMISSION_REQUEST {}", &ev["request"].to_string()[..200.min(ev["request"].to_string().len())]);
                    if ev["request"]["subtype"] == "can_use_tool" {
                        send(serde_json::json!({"type": "control_response", "response": {
                            "request_id": ev["request_id"],
                            "response": {"behavior": "allow", "updatedInput": ev["request"]["input"]}}}));
                        perm_roundtrip = true;
                        println!("SENT_ALLOW");
                    }
                }
                "assistant" => {
                    streamed = true;
                    for c in ev["message"]["content"].as_array().cloned().unwrap_or_default() {
                        println!("ASSISTANT {} {}", c["type"], c["text"].as_str().unwrap_or(c["name"].as_str().unwrap_or("")));
                    }
                }
                "user" => {
                    // tool result message
                    if ev["message"]["content"].to_string().contains("tool_result") {
                        tool_seen = true;
                        println!("TOOL_RESULT");
                    }
                }
                "result" => {
                    settled = true;
                    println!("RESULT err={} {}", ev["is_error"], &ev["result"].as_str().unwrap_or("")[..150.min(ev["result"].as_str().unwrap_or("").len())]);
                    break;
                }
                _ => {}
            },
            _ => unreachable!(),
        }
        if start.elapsed() > Duration::from_secs(TIMEOUT_SECS) {
            println!("TIMEOUT");
            break;
        }
    }

    let _ = child.kill();
    println!("--- engine={engine}");
    println!("STREAMING_EVENTS: {streamed}");
    println!("TOOL_EXECUTED: {tool_seen}");
    println!("PERMISSION_ROUNDTRIP: {perm_roundtrip}");
    println!("SETTLED: {settled}");
    println!("FINAL_TEXT: ...{}", &texts.concat()[..texts.concat().len().min(120)]);
}
