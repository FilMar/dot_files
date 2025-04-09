(print "load filconfig")

;;(load (concat (getenv "CONFIG_HOME") "/emacs_files/package.el"))
(let ((config (getenv "CONFIG_HOME")))
    (if config
        (load (concat config "/emacs_files/config/package.el"))
    )
)
;; ====================
;; 🧼 UI Clean-Up
;; ====================

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(global-display-line-numbers-mode t)
(show-paren-mode 1)
(ido-mode 1)
(which-key-mode 1)
(global-hl-line-mode 1)
(setq ring-bell-function 'ignore)
(set-charset-priority 'unicode)
(setq locale-coding-system 'utf-8
      coding-system-for-read 'utf-8
      coding-system-for-write 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(defun ab/enable-line-numbers ()
    "Enable relative line numbers"
    (interactive)
    (display-line-numbers-mode)
    (setq display-line-numbers 'relative))
(add-hook 'prog-mode-hook #'ab/enable-line-numbers)
(set-face-attribute 'default nil :font "FiraCode Nerd Font" :height 110)
