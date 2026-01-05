;;; ik-mail.el --- Email Configuration               -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian.kollipara@gmail.com>
;; Keywords: local, mail, lisp, abbrev

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

;; My `mu4e' email configuration.

;;; Code:
(require 'ik-vars)
(require 'smtpmail)

(use-package mu4e
  :ensure nil
  :load-path "/usr/local/share/emacs/site-lisp/mu4e"
  :bind (("C-c m" . mu4e)
	 (:map mu4e-view-mode-map
	       ("n" . next-line)
	       ("p" . previous-line)))
  :custom
  (mail-user-agent 'mu4e-user-agent)
  (mu4e-drafts-folder "/[Gmail]/Drafts")
  (mu4e-sent-folder "/[Gmail]/Sent Mail")
  (mu4e-trash-folder "/[Gmail]/Trash")
  (mu4e-refile-folder "/[Gmail]/All Mail")
  (mu4e-get-mail-command "mbsync -V gmail")
  (message-signature "Sincerely,\nIan")
  (mu4e-maildir-shortcuts
   '( (:maildir "/INBOX"              :key ?i)
      (:maildir "/[Gmail]/Sent Mail"  :key ?s)
      (:maildir "/[Gmail]/Trash"      :key ?t)
      (:maildir "/[Gmail]/All Mail"   :key ?a)))
  (message-send-mail-function 'smtpmail-send-it)
  (smtpmail-smtp-stream-type 'starttls)
  (smtpmail-auth-credentials `(("smtp.gmail.com" 587 ,user-mail-address nil)))
  (smtpmail-default-smtp-server "smtp.gmail.com")
  (smtp-smtp-server "smtp.gmail.com")
  (smtpmail-smtp-service 587))

(use-package org-msg
  :ensure t
  :functions mu4e-running-p notmuch-show-view-raw-message notmuch-show mu4e-message-readable-path
  :after mu4e
  :hook (elpaca-after-init . load-org-msg)
  :init
  (defun load-org-msg ()
    (require 'org-msg))
  :config
  (setq org-msg-options "html-postamble:nil H:5 num:nil ^:{} toc:nil author:nil email:nil tex:dvipng"
        org-msg-startup "hidestars indent inlineimages"
        org-msg-greeting-name-limit 3
        org-msg-default-alternatives '((new . (utf-8 html))
                                       (reply-to-text . (utf-8))
                                       (reply-to-html . (utf-8 html)))
        org-msg-convert-citation t
        ;; The default attachment matcher gives too many false positives,
        ;; it's better to be more conservative. See https://regex101.com/r/EtaiSP/4.
        org-msg-attached-file-reference
        "see[ \t\n]\\(?:the[ \t\n]\\)?\\(?:\\w+[ \t\n]\\)\\{0,3\\}\\(?:attached\\|enclosed\\)\\|\
(\\(?:attached\\|enclosed\\))\\|\
\\(?:attached\\|enclosed\\)[ \t\n]\\(?:for\\|is\\)[ \t\n]"))

(provide 'ik-mail)
;;; ik-mail.el ends here
