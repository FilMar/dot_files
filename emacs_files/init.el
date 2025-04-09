;; ====================
;; 📦 Package Manager Setup
;; ====================
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; ====================
;; 🚀 use-package
;; ====================
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; ====================
;; 😈 Evil Mode
;; ====================
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(defun my/vterm-setup ()
  (display-line-numbers-mode -1)
  (evil-local-mode -1))
(add-hook 'vterm-mode-hook #'my/vterm-setup)


(with-eval-after-load 'evil
  (global-unset-key (kbd "C-x"))
  (global-unset-key (kbd "M-x") )
  (global-unset-key (kbd "C-c") )
  (global-unset-key (kbd "C-u") )  ;; ad es. se non vuoi scroll
)

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
  :config
  (setq catppuccin-flavor 'mocha) ;; scegli: 'latte, 'frappe, 'macchiato, 'mocha
  (load-theme 'catppuccin t)
  (catppuccin-reload))

;; ====================
;; 🧼 UI Clean-Up
;; ====================
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
()
(setq inhibit-startup-screen t)
(global-display-line-numbers-mode t)
(show-paren-mode 1)
(ido-mode 1)
(which-key-mode 1)
(global-hl-line-mode 1)
(setq ring-bell-function 'ignore)

;; ====================
;; 🔤 Font (opzionale)
;; ====================
(set-face-attribute 'default nil :font "FiraCode Nerd Font" :height 110)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil)
 '(warning-suppress-log-types '((native-compiler))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
