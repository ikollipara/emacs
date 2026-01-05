;;; ik-work.el --- Work Configuration                -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian.kollipara@gmail.com>
;; Keywords: local

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

;; 

;;; Code:

(require 'ik-vars)

(setopt ns-command-modifier 'meta)

(use-package obsidian
  :ensure t
  :if ik:work-laptop-p
  :bind (("C-c n M-f" . obsidian-jump))
  :hook (after-init . obsidian-rescan-cache)
  :custom
  (obsidian-directory (expand-file-name "~/Documents"))
  (obsidian-inbox-directory "Notes")
  :config
  (global-obsidian-mode t)
  (obsidian-backlinks-mode))

(provide 'ik-work)
;;; ik-work.el ends here
