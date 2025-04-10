
(use-package catppuccin-theme
  :demand
  :config
  (setq catppuccin-flavor 'mocha) ;; scegli: 'latte, 'frappe, 'macchiato, 'mocha
  (load-theme 'catppuccin t))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package nerd-icons)

