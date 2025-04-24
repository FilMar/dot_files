(use-package helm
:straight t
:init
(helm-mode 1)
)

(use-package which-key
  :demand
  :init
  (setq which-key-idle-delay 0.5) ; Open after .5s instead of 1s
  :config
  (which-key-mode))

(use-package company-mode
  :init
  (global-company-mode)
)

(use-package flycheck
    :init
    (global-flycheck-mode)
)

(use-package rg)
