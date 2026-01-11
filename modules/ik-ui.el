;;; ik-ui.el --- UI Configuration                    -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian.kollipara@gmail.com>
;; Keywords: lisp, local, frames

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

;; My customization of the Emacs UI.

;;; Code:

(defvar ik:titanmacs-logo
  (concat user-emacs-directory "assets/titanmacs-logo.txt")
  "The custom logo for titan Emacs, my configuration.")


(use-package doom-modeline
  :ensure t
  :hook elpaca-after-init
  :custom
  (mode-line-right-align-edge 'right-fringe))

(use-package catppuccin-theme
  :ensure t
  :demand t
  :custom
  (catppuccin-flavor 'latte)
  :bind (("C-c t t" . ivy-catppuccin-load-flavor))
  :init
  (defvar ik:catppuccin-rich-init-p nil)
  (defvar ik:catppuccin-descriptions
    '((latte . ("🌻" . "Our lightest theme harmoniously inverting the essence of Catppuccin's dark themes."))
      (frappe . ("🪴" . "A less vibrant alternative using subdued colors for a muted aesthetic."))
      (macchiato . ("🌺" . "Medium contrast with gentle colors creating a soothing atmosphere."))
      (mocha . ("🌿" . "The Original — Our darkest variant offering a cozy feeling with color-rich accents.")))
    "Descriptions for the `catppuccin-flavor'.")
  (defun ivy-rich--catppucin-load-flavor-extract-symbol (candidate)
    "Get the symbol for the CANDIDATE."
    (car (alist-get (intern candidate) ik:catppuccin-descriptions nil nil #'equal)))
  (defun ivy-rich--catppuccin-load-flavor-extract-name (candidate)
    "Display the CANDIDATE."
    (capitalize candidate))
  (defun ivy-rich--catppuccin-load-flavor-extract-description (candidate)
    "Get the description for the CANDIDATE."
    (cdr (alist-get (intern candidate) ik:catppuccin-descriptions nil nil #'equal)))

  (defun ivy-catppuccin-load-flavor ()
    (interactive)
    (unless ik:catppuccin-rich-init-p
      (setq ik:catppuccin-rich-init-p t)
      (setup-ivy-rich-ivy-catppuccin-load-flavor))
    (ivy-read "Catppuccin flavor: "
	      ik:catppuccin-descriptions
	      :preselect catppuccin-flavor
	      :action (lambda (flavor)
			(setq catppuccin-flavor (car flavor))
			(catppuccin-reload)
			(setup-org-faces)
			(message "Catppuccin flavor changed to %s %s" (cadr flavor) (capitalize (symbol-name (car flavor)))))))
  (defun setup-ivy-rich-ivy-catppuccin-load-flavor ()
    (setopt ivy-rich-display-transformers-list
	    (append
	     '(
	       ivy-catppuccin-load-flavor
	       (:columns
		((ivy-rich--catppucin-load-flavor-extract-symbol)
		 (ivy-rich--catppuccin-load-flavor-extract-name (:width 0.15))
		 (ivy-rich--catppuccin-load-flavor-extract-description (:width 0.8 :face 'font-lock-doc-face)))))
	     ivy-rich-display-transformers-list))
    (ivy-rich-reload))
  :config
  (load-theme 'catppuccin :no-confirm))


(use-package focus
  :ensure t
  :bind (("C-c t f" . focus-mode)))

(use-package grid
  :ensure (grid :host github :repo "ichernyshovvv/grid.el")
  :demand t
  :functions grid--merge-plists)

(use-package dashboard
  :ensure t
  :custom
  (dashboard-startup-banner ik:titanmacs-logo)
  (dashboard-banner-logo-title (format-time-string "%Y-%m-%d"))
  (dashboard-footer-messages '("Failures, repeated failures, are finger posts on the road to achievement. One fails forward toward success. \n- C.S. Lewis"))
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-items '((projects . 5) (agenda . 5) (recents . 5) (bookmarks . 1)))
  (dashboard-projects-backend 'project-el)
  (dashboard-projects-backend-switch-function 'project-switch-project)
  (dashboard-agenda-files `(,(concat ik:notes-dir "/gtd.org")))
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook))

(use-package helpful
  :ensure t
  :commands helpful-callable helpful-variable helpful-symbol
  :functions shortdoc--function-groups)

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-ibuffer
  :ensure t
  :after nerd-icons
  :hook ibuffer-mode)

(use-package rainbow-delimiters
  :ensure t
  :hook prog-mode)

(provide 'ik-ui)
;;; ik-ui.el ends here

