
(use-package evil
  :demand ;
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :demand
  :config
  (evil-collection-init))

