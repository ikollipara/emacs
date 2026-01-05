;;; ik-research.el --- My Research Tooling Configuration  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian.kollipara@gmail.com>
;; Keywords: local, text, tex, abbrev

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

;; I make heavy use of org, latex, and citar for my research workflow.
;; This is how its set up in emacs.

;;; Code:

(use-package ebib
  :functions ebib--update-buffers ebib--get-key-at-point
  :ensure t
  :custom
  (ebib-bibtex-dialect 'biblatex)
  (ebib-file-associations nil)
  :bind (("C-c r b" . ebib)))

(use-package biblio :ensure t)

(use-package ebib-biblio
  :ensure nil
  :after (:all biblio ebib)
  :load-path "elpaca/repos/ebib"
  :bind ((:map ebib-index-mode-map
	       ("B" . ebib-biblio-import-doi))
	 (:map biblio-selection-mode-map
	       ("e" . ebib-biblio-selection-import))))

(use-package pdf-tools
  :ensure t
  :magic ("%PDF" . pdf-view-mode)
  :hook (elpaca-after-init . pdf-tools-install))

(use-package citar
  :ensure t
  :custom
  (org-cite-global-bibliography `(,(expand-file-name ik:notes-dir "/lib.bib") "~/Dropbox/ZK/References.bib"))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography org-cite-global-bibliography))

(use-package citar-denote
  :functions denote-silo-directory-prompt denote-sequence-get-new denote-sequence-file-prompt
  :ensure t
  :after (:all denote citar)
  :custom
  (citar-denote-file-type 'org)
  (citar-denote-keyword "bib")
  (citar-denote-signature nil)
  (citar-denote-subdir nil)
  (citar-denote-template nil)
  (citar-denote-title-format "title")
  (citar-denote-title-format-andstr "and")
  (citar-denote-use-bib-keywords nil)
  :hook (elpaca-after-init . citar-denote-mode))

(use-package auctex
  :ensure (auctex
	   :repo "https://git.savannah.gnu.org/git/auctex.git"
	   :branch "main"
           :pre-build (("make" "elpa"))
           :build (:not elpaca--compile-info) ;; Make will take care of this step
           :files ("*.el" "doc/*.info*" "etc" "images" "latex" "style")
           :version (lambda (_) (require 'auctex) AUCTeX-version))
  :hook
  (LaTeX-mode . TeX-fold-mode)
  (LaTeX-mode . TeX-source-correlate-mode)
  (LaTeX-mode . jinx-mode)
  (LaTeX-mode . setup-pdf-view)
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-source-correlat-start-server t)
  (TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view)))
  :init
  (defun setup-pdf-view ()
    (setq-local display-buffer-alist
		(append
		 display-buffer-alist
		 (list `(,(concat (file-name-base (buffer-file-name)) ".pdf")
			 (display-buffer-in-side-window)
			 (side . right)
			 (window-width . 0.5))))))
  (defun narrow-to-section ()
    "Narrow to the current `LaTeX' section."
    (interactive)
    (LaTeX-mark-section)
    (call-interactively #'narrow-to-region)
    (deactivate-mark t)))

(use-package reftex
  :ensure nil
  :after (:all auctex citar)
  :hook
  (LaTeX-mode . turn-on-reftex)
  (LaTeX-mode . activate-local-bib-if-tex)
  :custom
  (reftex-plug-into-AUCTeX t)
  :init
  (defun activate-local-bib-if-tex ()
    "Set `citar' to use the locally specified bib file in the tex document."
    (when (string-equal "tex" (file-name-extension (buffer-file-name)))
      (save-excursion
	(goto-char (point-min))
	(when (re-search-forward (rx "\\addbibresource{" (* letter) "\." (one-or-more letter)) nil t)
	  (let* ((file (thing-at-point 'filename))
		 (start (+ 1 (s-index-of "{" file)))
		 (end (s-index-of "}" file)))
	    (if (length> (substring file start end) 0)
		(setq-local citar-bibliography (list (format "./%s" (substring file start end))))
	      (message "No Bib File Found."))))))))

(provide 'ik-research)
;;; ik-research.el ends here
