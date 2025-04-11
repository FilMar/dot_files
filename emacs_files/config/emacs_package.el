(use-package emacs
  :hook (rust-mode . eglot-ensure)
  :hook (python-mode . eglot-ensure)
  :hook (lisp-mode . eglot-ensure)
  :general
  (leader-keys
    "l" '(:ignore t :which-key "lsp")
    "e" '(dired ("./") :which-key "directory")
    "l <escape>" '(keyboard-escape-quit :which-key t)
    "l r" '(eglot-rename :which-key "rename")
    "l a" '(eglot-code-actions :which-key "code actions"))
  :config
  (setq backup-directory-alist `(("." . "~/.saves")))
  :init
  (setq initial-scratch-message nil)
  (defun display-startup-echo-area-message ()
    (message "ciao benvenuto"))
  (defalias 'yes-or-no-p 'y-or-n-p)
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
  (set-face-attribute 'default nil
    :font "Fira Code Nerd Font"
    :height 110)
  (defun ab/enable-line-numbers ()
    "Enable relative line numbers"
    (interactive)
    (display-line-numbers-mode)
    (setq display-line-numbers 'relative))
  (add-hook 'prog-mode-hook #'ab/enable-line-numbers)
  (global-set-key (kbd "<escape>") 'keyboard-escape-quit)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . light))
  ;;(setq ns-use-proxy-icon  nil)
  (setq frame-title-format nil)
  ;;(setq-default fill-column 80)
  ;;(set-face-attribute 'fill-column-indicator nil
  ;;                   :foreground "#717C7C" ; katana-gray
  ;;                    :background "transparent")
  ;;(global-display-fill-column-indicator-mode 1)
)
