;;(load (concat (getenv "CONFIG_HOME") "/emacs_files/package.el"))
(let ((config (getenv "CONFIG_HOME")))
    (if config
        (progn (load (concat config "/emacs_files/config/0_package.el"))
        (load (concat config "/emacs_files/config/evil_package.el"))
        (load (concat config "/emacs_files/config/emacs_package.el"))
        (load (concat config "/emacs_files/config/theme_package.el"))
        (load (concat config "/emacs_files/config/terminal_package.el"))
        (load (concat config "/emacs_files/config/search_package.el"))
        (load (concat config "/emacs_files/config/projects_package.el"))
        (load (concat config "/emacs_files/config/treesitter_package.el"))
        )
    )
)
;; ====================
;; 🧼 UI Clean-Up
;; ====================


(tool-bar-mode -1)             ; Hide the outdated icons
(scroll-bar-mode -1)           ; Hide the always-visible scrollbar
(setq inhibit-splash-screen t) ; Remove the "Welcome to GNU Emacs" splash screen
(setq use-file-dialog nil)      ; Ask for textual confirmation instead of GUI



(print "load filconfig")
