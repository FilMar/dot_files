(use-package vterm
  :ensure t
  :hook (vterm-mode . (lambda () (setq-local global-hl-line-mode nil))))

(use-package multi-vterm)

(use-package exec-path-from-shell
  :init
  (exec-path-from-shell-initialize))

