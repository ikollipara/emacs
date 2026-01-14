;;; ik-ivy.el --- Ivy, Counsel, and Swiper Configuration. The Abo-Abo Suite  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian.kollipara@gmail.com>
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

;; I really lik `abo-abo''s tools, particularly his `ivy' suite.
;; This is the basis for my completion system.

;;; Code:

(use-package amx :ensure t :defer t)

(use-package ivy
  :ensure t
  :hook elpaca-after-init
  :custom
  (ivy-use-virtual-buffers t)
  (iv-use-selectable-prompt t)
  (ivy-re-builders-alist
   '((t . ivy--regex-ignore-order)
     (counsel-M-x . ivy--regex-ignore-order)
     (counsel-org-capture . regexp-quote))))

(use-package ivy-avy
  :ensure nil
  :load-path "./elpaca/repos/swiper"
  :hook (dashboard-before-initialize . provide-ivy-avy)
  :init
  (defun provide-ivy-avy ()
    (require 'ivy-avy)))

(use-package counsel
  :ensure t
  :after ivy
  :bind (("M-s r" . counsel-recentf)
	 ("M-s M-r" . counsel-rg)
	 ("M-s M-f" . counsel-fzf)
	 ("C-x p c" . counsel-compile)
	 ("C-h o" . counsel-describe-symbol))
  :hook ivy-mode
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  (counsel-describe-symbol-function #'helpful-symbol)
  :config
  (ivy-configure 'counsel-M-x :initial-input "")
  (ivy-configure 'counsel-org-capture :initial-input "")
  (ivy-configure 'counsel-describe-symbol :initial-input "")
  (ivy-configure 'counsel-minor :initial-input "")
  (ivy-configure 'counsel-package :initial-input ""))


(use-package nerd-icons-ivy-rich
  :ensure t
  :after counsel
  :functions counsel-describe-variable-transformer counsel-describe-function-transformer ffip-project-root
  :hook
  (counsel-mode . nerd-icons-ivy-rich-mode)
  (counsel-mode . ivy-rich-mode))

(use-package avy
  :ensure t
  :bind (("C-'" . avy-goto-char)
	 ("M-'" . avy-goto-line)))

(use-package swiper
  :ensure t
  :after (:all counsel avy)
  :bind (("C-s" . swiper)
	 ("C-r" . swiper-all)
	 ("M-s ." . swiper-thing-at-point)
	 ("M-s M-." . swiper-thing-at-point)
	 (:map swiper-map
	       ("C-'" . ivy-avy))))




(provide 'ik-ivy)
;;; ik-ivy.el ends here
