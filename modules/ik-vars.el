;;; ik-vars.el --- Useful Variables for my configuration  -*- lexical-binding: t; -*-

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

;; This is a collection of simple, but useful variables for my configuration.

;;; Code:

(defvar ik:work-laptop-p (eq system-type 'darwin) "Whether or not I'm on my work laptop.")
(defvar ik:notes-dir (expand-file-name "~/Notes") "My Notes directory")

(provide 'ik-vars)
;;; ik-vars.el ends here
