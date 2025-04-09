;; package manager
(defvar bootstrap-version)
(let ((bootstrap-file
    (expand-file-name
      "straight/repos/straight.el/bootstrap.el"
      (or (bound-and-true-p straight-base-dir)
        user-emacs-directory)))
    (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
       'silent 'inhibit-cookies)
    (goto-char (point-max))
    (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;;use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq use-package-always-defer t)

;; Evil Mode
(use-package evil
  :demand ;
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

;; doom-modliner
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; nerd icons
(use-package nerd-icons)

;; ====================
;; vterm
;; ====================
(use-package vterm
  :ensure t
  :hook (vterm-mode . (lambda () (setq-local global-hl-line-mode nil))))

(use-package multi-vterm)

;; ====================
;; 🎨 Catppuccin Theme
;; ====================
(use-package catppuccin-theme
  :demand
  :config
  (setq catppuccin-flavor 'mocha) ;; scegli: 'latte, 'frappe, 'macchiato, 'mocha
  (load-theme 'catppuccin t))
