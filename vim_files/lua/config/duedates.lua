-- Expand due:<shortcut> into due:YYYY-MM-DD when leaving insert mode.
-- Markdown buffers only. Unknown tokens stay untouched.
-- Grammar:
--   eod today | tom tomorrow | eow next sunday | eom last day of month
--   mon..sun next weekday, today counts | nmon..nsun strict next weekday
--   Nd Nw Nm Ny offsets (month/year are fuzzy, like GNU date)
--   3sep next 3rd of september (also sept, september); rolls to next
--   year if already past; invalid dates (31sep) do not resolve
-- User aliases: name -> grammar token, stored one per line in the
-- due_aliases file next to init.lua. Add with :DueAlias <name> <token>,
-- list with :DueAlias, remove with :DueAlias -d <name>.

local M = {}

local DAY = 86400
local WEEKDAYS = { sun = 1, mon = 2, tue = 3, wed = 4, thu = 5, fri = 6, sat = 7 }
local MONTHS = {
    "january", "february", "march", "april", "may", "june",
    "july", "august", "september", "october", "november", "december",
}

-- Month from an english prefix of at least 3 letters ("sep", "sept", ...)
local function month_from(alpha)
    if #alpha < 3 then return nil end
    for i, name in ipairs(MONTHS) do
        if name:sub(1, #alpha) == alpha then return i end
    end
    return nil
end

-- Timestamp for day/month if that date exists in the given year
local function valid_date(year, month, day)
    local time = os.time({ year = year, month = month, day = day, hour = 12 })
    local check = os.date("*t", time)
    if check.day == day and check.month == month then return time end
    return nil
end

-- Anchor at noon so a DST jump cannot shift the date
local function noon(t)
    return os.time({ year = t.year, month = t.month, day = t.day, hour = 12 })
end

-- Built-in aliases: name -> function(now, today) -> timestamp
local BUILTIN = {
    eod = function(now) return now end,
    tom = function(now) return now + DAY end,
    eow = function(now, today) return now + ((1 - today.wday) % 7) * DAY end,
    eom = function(_, today)
        return os.time({ year = today.year, month = today.month + 1, day = 1, hour = 12 }) - DAY
    end,
}

local aliases_path = vim.fn.stdpath("config") .. "/due_aliases"
local user_aliases = {}

local function load_user_aliases()
    user_aliases = {}
    local f = io.open(aliases_path, "r")
    if not f then return end
    for line in f:lines() do
        local name, expr = line:match("^(%w+)%s+(%S+)$")
        if name then user_aliases[name] = expr end
    end
    f:close()
end

-- Rewrite the whole file from the map: keeps it clean and deduplicated
local function save_user_aliases()
    local names = vim.tbl_keys(user_aliases)
    table.sort(names)
    local f = io.open(aliases_path, "w")
    if not f then return end
    for _, name in ipairs(names) do
        f:write(name .. " " .. user_aliases[name] .. "\n")
    end
    f:close()
end

local function resolve(token, depth)
    depth = depth or 0
    if depth > 5 then return nil end
    local today = os.date("*t")
    local now = noon(today)
    if BUILTIN[token] then return BUILTIN[token](now, today) end
    if user_aliases[token] then return resolve(user_aliases[token], depth + 1) end
    local strict, name = token:match("^(n?)(%l%l%l)$")
    if name and WEEKDAYS[name] then
        local delta = (WEEKDAYS[name] - today.wday) % 7
        if strict == "n" and delta == 0 then delta = 7 end
        return now + delta * DAY
    end
    local n, unit = token:match("^(%d+)([dwmy])$")
    if n then
        n = tonumber(n)
        if unit == "d" then return now + n * DAY end
        if unit == "w" then return now + n * 7 * DAY end
        if unit == "m" then
            return os.time({ year = today.year, month = today.month + n, day = today.day, hour = 12 })
        end
        return os.time({ year = today.year + n, month = today.month, day = today.day, hour = 12 })
    end
    local day, alpha = token:match("^(%d+)(%l+)$")
    local month = day and month_from(alpha)
    if month then
        day = tonumber(day)
        local time = valid_date(today.year, month, day)
        if time and time >= now then return time end
        return valid_date(today.year + 1, month, day)
    end
    return nil
end

-- Returning nil from the gsub callback keeps the original text,
-- so typos and already-expanded dates pass through unchanged.
function M.expand(line)
    return (line:gsub("due:(%w+)", function(token)
        local time = resolve(token)
        if time then return "**due:" .. os.date("%Y-%m-%d", time) .. "**" end
    end))
end

load_user_aliases()

-- blink.cmp source: complete due: tokens with their resolved date.
-- Registered in completion.lua under sources.providers.duedates.
function M.new()
    return setmetatable({}, { __index = M })
end

function M.enabled()
    return vim.bo.filetype == "markdown"
end

function M.get_trigger_characters()
    return { ":" }
end

function M.get_completions(_, ctx, callback)
    -- Always incomplete: the item set depends on the typed text (nominal
    -- tokens vs numeric offsets), so blink must re-query on every change
    -- instead of filtering a cached list.
    local response = { is_incomplete_forward = true, is_incomplete_backward = true, items = {} }
    local before = ctx.line:sub(1, ctx.cursor[2])
    local partial = before:match("due:(%w*)$")
    if partial then
        local function add(token)
            local time = resolve(token)
            if time then
                table.insert(response.items, {
                    label = token,
                    insertText = token,
                    labelDetails = { description = os.date("%Y-%m-%d", time) },
                })
            end
        end
        local digits = partial:match("^(%d+)")
        if digits then
            -- Typed a number: offer the four units and the twelve months
            for unit in ("dwmy"):gmatch("%a") do
                add(digits .. unit)
            end
            for _, name in ipairs(MONTHS) do
                add(digits .. name:sub(1, 3))
            end
        else
            for name in pairs(BUILTIN) do add(name) end
            for name in pairs(user_aliases) do add(name) end
            for name in pairs(WEEKDAYS) do
                add(name)
                add("n" .. name)
            end
        end
    end
    callback(response)
end

vim.api.nvim_create_user_command("DueAlias", function(opts)
    if #opts.fargs == 0 then
        local names = vim.tbl_keys(user_aliases)
        if #names == 0 then
            print("no user aliases")
            return
        end
        table.sort(names)
        for _, name in ipairs(names) do
            print(name .. " -> " .. user_aliases[name])
        end
        return
    end
    local name, expr = opts.fargs[1], opts.fargs[2]
    if name == "-d" then
        if not expr or not user_aliases[expr] then
            vim.notify("DueAlias: no alias '" .. tostring(expr) .. "'", vim.log.levels.ERROR)
            return
        end
        user_aliases[expr] = nil
        save_user_aliases()
        print("removed alias " .. expr)
        return
    end
    if not expr or not name:match("^%w+$") then
        vim.notify("usage: DueAlias <name> <token> | DueAlias -d <name>", vim.log.levels.ERROR)
        return
    end
    if not resolve(expr) then
        vim.notify("DueAlias: '" .. expr .. "' does not resolve", vim.log.levels.ERROR)
        return
    end
    user_aliases[name] = expr
    save_user_aliases()
    print("due:" .. name .. " -> " .. expr .. " (" .. os.date("%Y-%m-%d", resolve(name)) .. ")")
end, {
    nargs = "*",
    desc = "Add, list or remove (-d) due: date aliases",
    complete = function()
        local names = vim.tbl_keys(user_aliases)
        table.sort(names)
        table.insert(names, 1, "-d")
        return names
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    group = vim.api.nvim_create_augroup("DueDates", { clear = true }),
    callback = function(ev)
        if vim.bo[ev.buf].filetype ~= "markdown" then return end
        -- Only scan the lines touched by the last insert ('[ and '] marks)
        local first = vim.api.nvim_buf_get_mark(ev.buf, "[")[1]
        local last = vim.api.nvim_buf_get_mark(ev.buf, "]")[1]
        local count = vim.api.nvim_buf_line_count(ev.buf)
        if first < 1 or last < first or first > count then
            first = vim.api.nvim_win_get_cursor(0)[1]
            last = first
        end
        if last > count then last = count end
        local lines = vim.api.nvim_buf_get_lines(ev.buf, first - 1, last, false)
        for i, line in ipairs(lines) do
            local expanded = M.expand(line)
            if expanded ~= line then
                vim.api.nvim_buf_set_lines(ev.buf, first + i - 2, first + i - 1, false, { expanded })
            end
        end
    end,
})

return M
