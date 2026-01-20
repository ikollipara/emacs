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
  :bind (("C-c j" . counsel-org-capture)
	 ("C-c a" . org-agenda)
	 ("C-c C-t" . org-agenda-clock-out))
  :hook
  (org-mode . visual-line-mode)
  (org-mode . variable-pitch-mode)
  (org-mode . org-indent-mode)
  :custom
  (org-hide-emphasis-markers t)
  (org-image-actual-width nil)
  :config
  (require 'org-tempo)
  (require 'org-habit)
  (require 'org-timer)
  (defun setup-org-faces ()
    (set-face-attribute 'org-level-1 nil :inherit nil :height 1.6 :foreground (face-attribute 'lambda-green :foreground))
    (set-face-attribute 'org-level-2 nil :inherit nil :height 1.4 :foreground (face-attribute 'lambda-red :foreground))
    (set-face-attribute 'org-level-3 nil :inherit nil :height 1.2 :foreground (face-attribute 'lambda-aqua :foreground))
    (set-face-attribute 'org-level-4 nil :inherit nil :height 1.0)
    (set-face-attribute 'org-level-5 nil :inherit nil :height 1.0)
    (set-face-attribute 'org-level-6 nil :inherit nil :height 1.0)
    (set-face-attribute 'org-level-7 nil :inherit nil :height 1.0)
    (set-face-attribute 'org-level-8 nil :inherit nil :height 1.0)
    (set-face-attribute 'org-document-title nil :height 2.0 :foreground (face-attribute 'lambda-blue :foreground))
    (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
    (set-face-attribute 'org-table nil :inherit 'fixed-pitch)
    (set-face-attribute 'org-formula nil :inherit 'fixed-pitch)
    (set-face-attribute 'org-code nil :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))
  (setup-org-faces)
  (defvar ik:org-gtd-file (concat ik:notes-dir "/gtd.org") "The `org' file used for my gtd workflow.")
  (defvar ik:org-journal-file (concat ik:notes-dir "/journal.org") "My journal file.")
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

  (defun get-votd ()
    "Get the verse of the day from biblegateway.com."
    (with-current-buffer (url-retrieve-synchronously "https://biblegateway.com" t t)
      (goto-char (point-min))
      (re-search-forward "^$" nil 'move)
      (let* ((dom (libxml-parse-html-region (point) (point-max)))
	     (votd-node (car (dom-by-id dom "votd")))
	     (verse-text-node (car (dom-by-id votd-node "verse-text")))
	     (citation-node (car (dom-by-class votd-node "citation"))))
	(kill-buffer)
	(when votd-node
	  `((verse . ,(string-trim (dom-texts verse-text-node "")))
	    (citation . ,(string-trim (dom-text citation-node))))))))

  (defun get-votd-for-capture ()
    (let ((votd (get-votd)))
      (concat
       "#+begin_quote\n"
       "/" (alist-get 'verse votd) "/\n"
       "- " (alist-get 'citation votd) "\n"
       "#+end_quote")))
  
  (defun org-extract-title-from-link (link)
    "Extract the title of a webpage, then format it as an org link."
    (interactive "sURL: ")
    (let ((title (extract-html-title-libxml link)))
      (insert (format "[[%s][%s]]" link title) "\n")))
  (setq org-directory ik:notes-dir
	org-todo-keywords '((sequence "CAPTURE(c)")
			    (sequence "NEXT(n)" "PROJECT(p)" "|" "DONE(d!)" "CANCELLED(l!)")
			    (sequence "READ(r)" "READING(e)" "|" "FINISHED(f!)")
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
	   "** CAPTURE Read %(org-extract-title-from-link \"%c\")" :empty-lines 1 :immediate-finish t)
	  ("Cs" "Item to Buy" entry (file+headline ,ik:org-gtd-file "Intray")
	   "** %{Item} :SHOPPING:" :empty-lines 0 :immediate-finish t)
	  ("Cr" "Respond to" entry (file+headline ,ik:org-gtd-file "Next Actions")
	   "** NEXT Respond to %^{Whom} %^{For|CUNE|UNL}\nSCHEDULED: %T\n\n%?" :empty-lines 1)
	  ("j" "Journal")
	  ("jm" "Morning Dump" plain (file+olp+datetree ,ik:org-journal-file)
	   "*Morning Dump*\n%?\n" :empty-lines 1)
	  ("jb" "Daily Bible" plain (file+olp+datetree ,ik:org-journal-file)
	   "*Bible Study*\n%(get-votd-for-capture)\n%?\n" :empty-lines 1)
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
  :hook org-mode
  :config
  (defvar ik:org-present--org-modern-original-stars org-modern-replace-stars))

(use-package org-download
  :ensure t
  :after org
  :custom
  (org-download-image-dir (concat ik:notes-dir "/images"))
  :hook (dired-mode . org-download-enable)
  :functions url-handler-file-remote-p)

(use-package denote
  :ensure t
  :hook
  (dired-mode . denote-dired-mode)
  (org-mode . denote-rename-buffer-mode)
  (org-mode . setup-denote-keybinds-for-org)
  :custom
  (denote-directory ik:notes-dir)
  :bind (("C-c n f" . denote-open-or-create)
	 ("C-c n d" . denote))

  :init
  (defun setup-denote-keybinds-for-org ()
    (bind-key "C-c C-x C-d" 'denote-link 'org-mode-map)
    (bind-key "C-c C-x M-d" 'denote-backlinks 'org-mode-map))

  (defun denote-create-from-article-link ()
    "Create a new denote note with the name from the LINK."
    (interactive)
    (let* ((link (org-element-context))
	   (path (org-element-property :raw-link link))
	   (description (buffer-substring-no-properties
			 (org-element-property :contents-begin link)
			 (org-element-property :contents-end link)))
	   (new-note (find-file-noselect (denote description '("article" "online")))))
      (with-current-buffer new-note
	(goto-char (point-max))
	(insert "#+LINK: " path))
      (switch-to-buffer new-note))))

(use-package org-present
  :ensure t
  :commands org-present
  :hook
  (org-present-mode . org-present--start-up)
  (org-present-mode-quit . org-present--shut-down)
  :init
  (defun org-present--start-up ()
    (setq-local face-remapping-alist '((default (:height 1.5) variable-pitch)
                                       (header-line (:height 4.0) variable-pitch)
                                       (org-document-title (:height 1.75) org-document-title)
                                       (org-code (:height 1.55) org-code)
                                       (org-verbatim (:height 1.55) org-verbatim)
                                       (org-block (:height 1.25) org-block)
                                       (org-block-begin-line (:height 0.7) org-block)))
    (setq header-line-format " ")
    (org-display-inline-images)
    (hide-mode-line-mode 1)
    (jinx-mode -1)
    (set-frame-parameter (selected-frame) 'alpha '(97 . 100)))
  
  (defun org-present--shut-down ()
    (setq-local face-remapping-alist '((default variable-pitch default)))
    (setq header-line-format nil)
    (hide-mode-line-mode -1)
    (jinx-mode 1)
    (set-frame-parameter (selected-frame) 'alpha '(100 . 100))))

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
