;;; ik-org.el --- Org Configuration                  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian.kollipara@gmail.com>
;; Keywords: lisp, local, text

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

;; I use org for nearly everything, and this is my complex configuratio for it.

;;; Code:

(require 'ik-vars)

(use-package olivetti
  :ensure t
  :custom
  (olivetti-body-width 120)
  (olivetti-style t)
  :hook (org-mode markdown-mode))

(use-package org
  :ensure t
  :demand t
  :bind (("C-c j" . counsel-org-capture)
	 ("C-c a" . org-agenda)
	 ("C-c C-t" . org-agenda-clock-out))
  :hook
  (org-mode . visual-line-mode)
  (org-mode . variable-pitch-mode)
  :custom
  (org-hide-emphasis-markers t)
  :config
  (require 'org-tempo)
  (require 'org-habit)
  (require 'org-timer)
  (set-face-attribute 'org-document-title nil :height 2.0)
  (defvar ik:org-gtd-file (concat ik:notes-dir "/gtd.org") "The `org' file used for my gtd workflow.")
  (defvar ik:org-journal-file (concat ik:notes-dir "/20251228T174637--journal__ongoing_personal.org") "My journal file.")
  (defvar ik:org-work-tag "CUNE" "Things that are associated with Concordia, where I currently work.")
  (defvar ik:org-research-tag "UNL" "Things that are associated with UNL, where I am completing my research.")
  (defvar ik:org-personal-tag "PERSONAL" "Things that are associated with my personal life.")
  (defvar ik:org-gtd-considering-project-tag "CONSIDERING" "Projects that I am considering, but haven't started yet.")
  (defmacro org-include (var)
    "Prefix with '+' the VAR."
    `(concat "+" ,var))
  (defun extract-html-title-libxml (url)
    "Fetch the URL and extract the <title> tag using libxml parsing."
    (with-current-buffer (url-retrieve-synchronously url t t)
      (goto-char (point-min))
      (re-search-forward "^$" nil 'move) ; Skip HTTP headers
      (let* ((dom (libxml-parse-html-region (point) (point-max)))
             (title-node (car (dom-by-tag dom 'title))))
	(kill-buffer)
	(when title-node
          (string-trim (dom-text title-node))))))

  (defun org-extract-title-from-link (link)
    "Extract the title of a webpage, then format it as an org link."
    (interactive "sURL: ")
    (let ((title (extract-html-title-libxml link)))
      (insert (format "[[%s][%s]]" link title) "\n")))
  (setq org-directory ik:notes-dir
	org-todo-keywords '((sequence "CAPTURE(c)")
			    (sequence "NEXT(n)" "PROJECT(p)" "|" "DONE(d!)" "CANCELLED(l!)")
			    (sequence "SOMEDAY(s)"))
	org-agenda-files `(,ik:org-gtd-file))
  (setq org-stuck-projects
	`(,(concat "+PROJECT/-" ik:org-gtd-considering-project-tag) ("NEXT")))
  (setq org-capture-templates
	`(("c" "Capture" entry (file+headline ,ik:org-gtd-file "Intray")
	   "** CAPTURE %?" :empty-lines 1)
	  ("C" "Capture Helpers")
	  ("Ct" "Code Todo" entry (clock)
	   "** CAPTURE Fix in %F\n#+begin_src\n%i#+end_src\n%?" :empty-lines 1)
	  ("CT" "Thesis Fixes" entry (file+headline ,ik:org-gtd-file "Intray")
	   "** CAPTURE [%U] Updates from Soh :THESIS:UNL:" :empty-lines 1 :immediate-finish t)
	  ("Ca" "Article to Read" entry (file+headline ,ik:org-gtd-file "Intray")
	   "** CAPTURE Read %(org-extract-title-from-link \"%x\")" :empty-lines 1 :immediate-finish t)
	  ("Cs" "Item to Buy" entry (file+headline ,ik:org-gtd-file "Intray")
	   "** %{Item} :SHOPPING:" :empty-lines 0 :immediate-finish t)
	  ("Cr" "Respond to" entry (file+headline ,ik:org-gtd-file "Next Actions")
	   "** NEXT Respond to %{Whom} %^{For|CUNE|UNL}\nSCHEDULED: %T\n\n%?" :empty-lines 1)
	  ("j" "Journal")
	  ("jm" "Morning Dump" plain (file+olp+datetree ,ik:org-journal-file)
	   "*Morning Dump*\n%?\n" :empty-lines 1)
	  ("jb" "Daily Bible" plain (file+olp+datetree ,ik:org-journal-file)
	   "*Bible Study*\n#+begin_quote\n%^{Bible Verse}\n- %^{Bible Verse Location}\n#+end_quote\n%?\n" :empty-lines 1)
	  ("jc" "End of Day" plain (file+olp+datetree ,ik:org-journal-file)
	   "*End of Day*\n%?\n" :empty-lines 1)))
  (setq org-agenda-custom-commands
	`(("w" tags-todo ,(org-include ik:org-work-tag))
	  ("p" tags ,(org-include ik:org-personal-tag))
	  ("s" tags "shopping")
	  ("u" tags-todo ,(org-include ik:org-research-tag))
	  ("c" todo "CAPTURE")
	  ("C" tags-todo ,(org-include ik:org-gtd-considering-project-tag))
	  ("s" todo "SOMEDAY")
	  ("W" "CUNE Dashboard"
	   ((todo-tags "bus371")
	    (todo-tags "cs241")
	    (tags "CUNE")))
	  ("d" "My Dashboard"
	   ((todo "CAPTURE")
	    (todo "NEXT")
	    `(todo-tags ,ik:org-gtd-considering-project-tag)))))
  (setq org-clock-persist 'history)
  (org-clock-persistence-insinuate))

(use-package org-modern
  :ensure t
  :after org
  :hook (elpaca-after-init . global-org-modern-mode))

(use-package org-download
  :ensure t
  :demand t
  :after org
  :custom
  (org-download-image-dir (concat ik:notes-dir "/images"))
  :hook (dired-mode . org-download-enable)
  :functions url-handler-file-remote-p)

(use-package denote
  :ensure t
  :after org
  :hook
  (dired-mode . denote-dired-mode)
  (org-mode . denote-rename-buffer-mode)
  :custom
  (denote-directory ik:notes-dir)
  :bind (("C-c n f" . counsel-denote-open)
	 ("C-c n d" . denote)
	 (:map org-mode-map
	       ("C-c C-x C-d" . denote-link)
	       ("C-c C-x M-d" . denote-backlinks)))
  :config
  (setopt ivy-rich-display-transformers-list
	  (append
	   '(counsel-denote-open
	     (:columns
	      ((nerd-icons-ivy-rich-file-icon)
	       (ivy-rich--counsel-denote-open-extract-name (:width 0.15))
	       (ivy-rich--counsel-denote-open-extract-keyword (:width 0.8)))))
	   ivy-rich-display-transformers-list))
  (ivy-rich-reload)
  (defun fast-read-org-titles (dir)
    "Use ripgrep to extract #+TITLE lines from .org files under DIR."
    (let ((default-directory dir))
      (mapcar
       (lambda (line)
	 (when (string-match "^\\(.*\\.org\\):[^\n]*#\\+title:[[:space:]]*\\(.*\\)" line)
           (cons (expand-file-name (match-string 1 line) dir)
		 (string-trim (match-string 2 line)))))
       (process-lines
	"rg"
	"--with-filename"       ;; show filename prefix
	"--no-heading"          ;; one line per match
	"--smart-case"
	"--glob" "*.org"        ;; only org files
	"^#\\+title:"           ;; match title line
	"."))))                 ;; search from current directory
  
  (defun ivy-rich--counsel-denote-open-extract-name (candidate)
    (let ((options (fast-read-org-titles counsel--fzf-dir))
	  (normalized-name (expand-file-name (concat counsel--fzf-dir candidate))))
      (alist-get normalized-name options nil nil 'string=)))
  (defun ivy-rich--counsel-denote-open-extract-keyword (candidate)
    (string-replace "_" ", " (car (string-split (cadr (string-split (cadr (string-split candidate "--")) "__")) ".org"))))
  (defun counsel-denote-open ()
    "Open a note using a rich counsel interface."
    (interactive)
    (let ((counsel--fzf-dir (concat ik:notes-dir "/")))
      (with-environment-variables
	  (("FZF_DEFAULT_COMMAND" "fd --type f -e org --exclude gtd.org"))
	(ivy-read "Open Denote: "
		  #'counsel-fzf-function
		  :re-builder #'ivy--regex-ignore-order
		  :dynamic-collection t
		  :action (lambda (x)
			    (with-ivy-window
			      (let ((default-directory counsel--fzf-dir))
				(when (bufferp x) (kill-buffer x))
				(find-file x))))
		  :caller 'counsel-denote-open)))))

(use-package jinx
  :ensure t
  :bind (("M-$" . jinx-correct))
  :hook text-mode
  :config
  (defun ivy-jinx-correct-select ()
    "Fix the bug when using `jinx-correct-select' in ivy."
    (interactive)
    (let* ((keys (this-command-keys-vector))
	   (word (nth (if (eq (aref keys 0) ?0)
			  (+ 9 (or (seq-position jinx--select-keys (aref keys 1)) 999))
			(- (aref keys 0) ?1))
		      (all-completions "" minibuffer-completion-table))))
      (unless (and word (get-text-property 0 'jinx--prefix word))
	(user-error "Invalid select key `%s'" (key-description keys)))
      (delete-minibuffer-contents)
      (ivy--done word)))
  (advice-add 'jinx-correct-select :override #'ivy-jinx-correct-select))

(provide 'ik-org)
;;; ik-org.el ends here
