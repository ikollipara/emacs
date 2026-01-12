;;; ik-core.el --- Core Emacs Configurations         -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian@fedora>
;; Keywords: lisp, local

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This is my customization of the core Emacs experience.
;; That is, this is only for changes made to built-in tooling.

;;; Code:

(require 'ik-vars)

(use-package emacs
  :ensure nil
  :bind (("C-x C-b" . ibuffer)
	 ("C-x k" . kill-current-buffer)
	 ("M-o" . other-window))
  :hook
  (prog-mode . electric-pair-local-mode)
  (prog-mode . display-line-numbers-mode)
  (prog-mode . hl-line-mode)
  :custom
  (ring-bell-function #'ignore)
  (user-full-name "Ian Kollipara")
  (user-mail-address "ian.kollipara@gmail.com")
  (custom-file (concat user-emacs-directory "custom.el"))
  (use-package-enable-imenu-support t)
  (xref-search-program 'ripgrep)
  :config
  (defalias 'yes-or-no-p 'y-or-n-p)
  (set-fringe-mode 10)
  (recentf-mode 1)
  (delete-selection-mode 1)
  (display-time-mode 1)
  (display-battery-mode 1)
  (hl-line-mode 1)
  (when (file-exists-p custom-file)
    (load custom-file))
  (set-face-attribute 'default nil :family "Cascadia Code" :height (static-if ik:work-laptop-p 160 110))
  (set-face-attribute 'variable-pitch nil :family "Space Mono" :height (static-if ik:work-laptop-p 160 110))
  (set-face-attribute 'fixed-pitch nil :family "Space Mono" :height (static-if ik:work-laptop-p 160 110)))


(use-package eshell
  :ensure nil
  :bind (("C-c s" . eshell))
  :custom
  (eshell-banner-message "
#                                              
#                                              
#    ██████ ▄█████ ██  ██ ██████ ██     ██     
#    ██▄▄   ▀▀▀▄▄▄ ██████ ██▄▄   ██     ██     
#    ██▄▄▄▄ █████▀ ██  ██ ██▄▄▄▄ ██████ ██████ 
#                                              
")
  (eshell-prompt-function
   (lambda ()
     (concat
      (getenv "USER")
      ":"
      (abbreviate-file-name (eshell/pwd))
      (if (= (file-user-uid) 0) " # " " $ "))))
  :config
  (defun eshell/h () (eshell/cd "~"))
  (defun eshell/b () (eshell/cd "..")))


(use-package no-littering
  :ensure t
  :demand t
  :custom
  (version-control t)
  (kept-old-versions 6)
  (kept-new-versions 2)
  (delete-old-versions t)
  (backup-by-copying t)
  :config
  (setq backup-directory-alist `((".*" . ,(no-littering-expand-var-file-name "backup/")))
        auto-save-file-name-transforms `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))
	lock-file-name-transforms `(("\\`/.*/\\([^/]+\\)\\'" "/var/tmp/\\1" t))))

(use-package perspective
  :ensure t
  :hook (elpaca-after-init . persp-mode)
  :custom
  (persp-interactive-completion-function 'ivy-completing-read)
  (persp-modestring-short t)
  (persp-suppress-no-prefix-key-warning t)
  (persp-mode-prefix-key (kbd "C-]"))
  :bind (("C-x b" . persp-counsel-switch-buffer)
	 ("C-x k" . kill-buffer-dwim))
  :config
  (defun kill-buffer-dwim ()
    "Kill the buffer using `kill-current-buffer' unless prefixed, call `persp-kill-buffer*'."
    (interactive)
    (call-interactively (if current-prefix-arg #'persp-kill-buffer* #'kill-current-buffer)))
  (defun advice--create-new-persp-after (orig &rest args)
    "Create a new perspective, or switch to one, after running original function.
Used in the integration of project.el with perspective.el"
    (let ((d (apply orig args)))
      (persp-switch (project-name (project-current nil)))
      (persp-set-buffer d)
      (persp-switch-to-buffer d)))
  (advice-add 'project-find-dir :around #'advice--create-new-persp-after)
  (advice-add 'project-find-file :around #'advice--create-new-persp-after)
  (advice-add 'project-dired :around #'advice--create-new-persp-after)
  (advice-add 'project-shell :around #'advice--create-new-persp-after)
  (advice-add 'project-eshell :around #'advice--create-new-persp-after))


(provide 'ik-core)
;;; ik-core.el ends here
