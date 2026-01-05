;;; ik-corfu.el --- Corfu Completion                 -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian.kollipara@gmail.com>
;; Keywords: lisp, local, convenience

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

;; I use `corfu' for my completion.

;;; Code:

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t)
  :hook
  (ivy-mode . orderless--setup-ivy)
  :config
  (defun orderless--setup-ivy ()
    "Setup `ivy' to play with `orderless'."
    (setq ivy-re-builders-alist '((t . orderless-ivy-re-builder)))
    (add-to-list 'ivy-highlight-functions-alist '(orderless-ivy-re-builder . orderless-ivy-highlight))))

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 2)
  :bind (:map corfu-map
	      ("C-'" . corfu-quick-complete))
  :hook
  (elpaca-after-init . global-corfu-mode)
  (global-corfu-mode . corfu-popupinfo-mode)
  (global-corfu-mode . corfu-history-mode))

(use-package nerd-icons-corfu
  :ensure t
  :after (:all nerd-icons corfu)
  :hook (global-corfu-mode . setup-nerd-icons-corfu)
  :init
  (defun setup-nerd-icons-corfu ()
    (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)))

(use-package cape
  :ensure t
  :hook (elpaca-after-init . setup-cape)
  :init
  (defun setup-cape ()
    (add-hook 'completion-at-point-functions #'cape-dabbrev)
    (add-hook 'completion-at-point-functions #'cape-file)))



(provide 'ik-corfu)
;;; ik-corfu.el ends here
