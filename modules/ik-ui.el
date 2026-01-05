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

(defvar ik:titanmacs-logo "
▄▄▄▄▄▄▄▄▄                        ▄▄▄▄▄▄▄                            
▀▀▀███▀▀▀ ▀▀  ██                ███▀▀▀▀▀                            
   ███    ██ ▀██▀▀ ▀▀█▄ ████▄   ███▄▄    ███▄███▄  ▀▀█▄ ▄████ ▄█▀▀▀ 
   ███    ██  ██  ▄█▀██ ██ ██   ███      ██ ██ ██ ▄█▀██ ██    ▀███▄ 
   ███    ██▄ ██  ▀█▄██ ██ ██   ▀███████ ██ ██ ██ ▀█▄██ ▀████ ▄▄▄█▀ 
" "The custom logo for titan emacs, my configuration.")


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
  :bind (("C-c t t" . catppuccin-load-flavor))
  :config
  (load-theme 'catppuccin :no-confirm))

(use-package focus
  :ensure t
  :bind (("C-c t f" . focus-mode)))

(use-package grid
  :ensure (grid :host github :repo "ichernyshovvv/grid.el")
  :demand t
  :functions grid--merge-plists)

(use-package enlight
  :ensure t
  :after grid
  :init
  (require 'grid)
  :custom
  (initial-buffer-choice #'enlight)
  (enlight-content
   (concat
    (grid-make-box `(:content ,ik:titanmacs-logo :width 80)))))

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
