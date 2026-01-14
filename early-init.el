;;; early-init.el --- Emacs Early Initialization     -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian@fedora>
;; Keywords: lisp, local, tools

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

;; This is the early init file for emacs. It contains basic modifications.
;; Most notable is disabling `package.el', since I am using elpaca.

;;; Code:

(setq package-enable-at-startup nil)

(scroll-bar-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)

(when (and (fboundp 'startup-redirect-eln-cache)
           (boundp 'native-comp-eln-load-path))
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(left-fringe . 10))
(add-to-list 'default-frame-alist '(right-fringe . 10))

(provide 'early-init)
;;; early-init.el ends here
