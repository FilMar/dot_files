
(use-package ivy
  :demand
  :config
  (ivy-mode))

(use-package which-key
  :demand
  :init
  (setq which-key-idle-delay 0.5) ; Open after .5s instead of 1s
  :config
  (which-key-mode))

(use-package company-mode
  :init
  (global-company-mode))

(use-package rg
  :general
  (leader-keys
    "f" '(rg-menu :which-key "find")))
