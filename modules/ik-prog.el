;;; ik-prog.el --- Programming Language Setup        -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Ian Kollipara

;; Author: Ian Kollipara <ian.kollipara@gmail.com>
;; Keywords: convenience, local

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

;; This is the setup I use for writing code.
;; Since this is my passion, its quite detailed and supports a variety
;; of different languages.

;;; Code:

(use-package wgrep
  :ensure t
  :commands wgrep-change-to-wgrep-mode)

(use-package exec-path-from-shell
  :ensure (:wait t)
  :hook (elpaca-after-init . exec-path-from-shell-initialize))

(use-package mise
  :ensure t
  :hook (elpaca-after-init .global-mise-mode))

(use-package eat
  :ensure '(eat :host codeberg :repo "akib/emacs-eat")
  :bind (("C-c S" . eat))
  :custom (eat-kill-buffer-on-exit t)
  :hook (eshell-load . eat-eshell-mode))

(use-package transient :ensure t :defer t)

(use-package magit
  :ensure t
  :bind (("C-x g" . magit)))

(use-package forge
  :ensure t
  :after magit
  :defer t
  :config
  (auth-source-forget-all-cached))


(use-package flycheck
  :ensure t
  :hook (elpaca-after-init . global-flycheck-mode)
  :bind ((:map flycheck-mode-map
	       ("C-c ! l" . flycheck-list-errors-dwim)))
  :init
  :init
  (defun flycheck-list-errors-dwim ()
    "List the errors using `counsel-flycheck' unless prefixed, then call `flycheck-list-errors'."
    (interactive)
    (call-interactively (if current-prefix-arg #'flycheck-list-errors #'counsel-flycheck))))

(use-package lsp-mode
  :ensure t
  :after corfu
  :custom
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-completion-provider :none)
  (lsp-keymap-prefix "C-c l")
  :hook
  (lsp-completion-mode . lsp-mode--setup-completion-for-corfu)
  :init
  (defun lsp-mode--setup-completion-for-corfu ()
    "Setup `lsp-mode' to play well with `corfu'."
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))
  :config
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection
		     '("some-sass-language-server" "--stdio")
		     (lambda () (executable-find "some-sass-language-server")))
    :activation-fn (lsp-activate-on "scss")
    :add-on? t
    :server-id 'some-sass)))

(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  (treesit-auto-add-to-auto-mode-alist 'all)
  (treesit-language-source-alist
   '((fsharp "https://github.com/ionide/tree-sitter-fsharp" "main" "fsharp/src")
     (emacs-lisp "https://github.com/Wilfred/tree-sitter-elisp")
     (scss "https://github.com/serenadeai/tree-sitter-scss")
     (elm "https://github.com/elm-tooling/tree-sitter-elm")
     (python . ("https://github.com/tree-sitter/tree-sitter-python" "v0.23.6" nil nil nil))))
  :hook
  (elpaca-after-init . global-treesit-auto-mode))

(use-package expreg
  :ensure '(expreg :host github :repo "casouri/expreg")
  :bind (("M-SPC" . expreg-expand)))

(use-package apheleia
  :ensure t
  :config
  (setf (alist-get 'python-ts-mode apheleia-mode-alist)
	'(ruff ruff-isort))
  (setf (alist-get 'python-mode apheleia-mode-alist)
	'(ruff ruff-isort))
  (setf (alist-get 'python-base-mode apheleia-mode-alist)
	'(ruff ruff-isort))
  (setf (alist-get 'js-mode apheleia-mode-alist)
	'(biome))
  (setf (alist-get 'js-ts-mode apheleia-mode-alist)
	'(biome))
  (setf (alist-get 'js-json-mode apheleia-mode-alist)
	'(biome))
  (push '(djade . ("djade" inplace)) apheleia-formatters)
  (push
   '(fantomas . ("fantomas" inplace "--out" inplace))
   apheleia-formatters)
  (setf (alist-get 'fsharp-mode apheleia-mode-alist)
	'(fantomas))
  :hook
  (elpaca-after-init . apheleia-global-mode))

(use-package python
  :ensure nil
  :hook
  (python-base-mode . python--setup-lsp-with-uv)
  (python-base-mode . lsp-deferred)
  (python-base-mode . electric-pair-local-mode)
  :init
  (defun python--setup-lsp-with-uv ()
    "Configure `lsp-mode' to recognize the current project's `.venv' file."
    (interactive)
    (let* ((project-dir (project-root (project-current nil)))
	   (venv-dir-name (concat project-dir ".venv")))
      (when project-dir
	(setq lsp-pylsp-plugins-jedi-environment venv-dir-name))))
  (defun django-project-p ()
    "Check if the given project is a Django project."
    (and
     (project-current nil)
     (file-exists-p (concat (project-root (project-current nil)) "manage.py")))))

(use-package yasnippet
  :ensure t
  :hook ((text-mode prog-mode conf-mode snippet-mode) . yas-minor-mode-on)
  :bind (("M-/" . yas-insert-snippet))
  :custom (yas-snippet-dirs (list (concat user-emacs-directory "snippets"))))

(use-package yasnippet-snippets
  :ensure '(yasnippet-snippets :host github :repo "AndreaCrotti/yasnippet-snippets")
  :after yasnippet
  :hook (yasnippet-global-mode . yasnippet-snippets-initialize))

(use-package js2-mode
  :ensure t
  :custom
  (js-indent-level 2)
  :hook
  (js-ts-mode . js2-minor-mode)
  (js-ts-mode . lsp-deferred)
  :mode ("\\.\\(c\\|m\\)?\\(t\\|j\\)s\\'" . js-ts-mode))

(use-package web-mode
  :ensure t
  :hook
  (web-mode . web-mode--activate-django-engine-if-django-project)
  :mode
  (("\\.phtml\\'" . web-mode)
   ("\\.php\\'" . web-mode)
   ("\\.tpl\\'" . web-mode)
   ("\\.[agj]sp\\'" . web-mode)
   ("\\.as[cp]x\\'" . web-mode)
   ("\\.cshtml\\'" . web-mode)
   ("\\.erb\\'" . web-mode)
   ("\\.mustache\\'" . web-mode)
   ("\\.djhtml\\'" . web-mode)
   ("\\.j2\\'" . web-mode)
   ("\\.njk\\'" . web-mode)
   ("\\.html\\'" . web-mode))
  :init
  (defun web-mode--activate-django-engine-if-django-project ()
    "Set the current engine as `django' if the project is a django project."
    (when (django-project-p)
      (setq-local web-mode-engine "django")
      (setq-local apheleia-formatter 'djade))))

(use-package emmet-mode
  :ensure t
  :hook web-mode)

(use-package rjsx-mode
  :ensure t
  :hook (rjsx-mode . lsp-deferred)
  :mode
  (("\\.jsx\\'" . rjsx-mode)
   ("\\.tsx\\'" . rjsx-mode)))

(use-package json-mode
  :mode (("\\.json\\'" . json-mode))
  :ensure t
  :custom
  (js-indent-level 2))

(use-package yaml-mode
  :mode (("\\.yml\\'" . yaml-mode)
	 ("\\.yaml\\'" . yaml-mode))
  :ensure t)

(use-package fsharp-mode
  :ensure t
  :hook (fsharp-mode . lsp-deferred)
  :config
  (defun ad--fsharp-find-sln-only (dir-or-file)
    (fsharp-mode-search-upwards (rx (0+ nonl) ".sln" eol)
				(file-name-directory dir-or-file)))
  (advice-add 'fsharp-mode/find-sln-or-fsproj :override #'ad--fsharp-find-sln-only))

(use-package csharp-mode
  :ensure t
  :hook
  (csharp-ts-mode . lsp-deferred))

(use-package csproj-mode
  :after yasnippet
  :mode
  (("\\.fsproj\\'" . csproj-mode)
   ("\\.csproj\\'" . csproj-mode))
  :functions yas-load-directory
  :ensure '(csproj-mode :host github :repo "omajid/csproj-mode"))

(use-package sharper
  :ensure t
  :bind (:map csharp-ts-mode-map
	      ("C-c C-c" . sharper-main-transient)))

(use-package dockerfile-mode
  :ensure t
  :mode (("Dockerfile" . dockerfile-mode)
	 ("dockerfile" . dockerfile-mode)))
(use-package docker
  :ensure t
  :commands docker)

(use-package vhdl-ts-mode
  :ensure t
  :mode
  (("\\.vhdl?\\'" . vhdl-ts-mode)))

(use-package vhdl-ext
  :ensure t
  :after vhdl-ts-mode
  :hook vhdl-ts-mode
  :custom
  (vhdl-ext-feature-list '(font-lock xref capf hierarchy lsp flycheck beautify navigation compilation imenu which-func ports))
  :config
  (vhdl-ext-mode-setup))

(use-package robe
  :ensure t
  :after cape
  :hook
  (ruby-ts-mode . robe-mode)
  (robe-mode . robe-start-auto)
  :config
  (defun robe-start-auto ()
    (interactive)
    (robe-start t)))

(use-package sly
  :functions slime-mode
  :ensure t
  :commands sly-mode)

(use-package scala-ts-mode
  :ensure '(scala-ts-mode :host github :repo "KaranAhlawat/scala-ts-mode")
  :hook (scala-ts-mode . lsp-deferred))

(use-package lsp-metals
  :ensure t
  :functions treemacs-define-doubleclick-action dap-variables-expand-in-launch-configuration
  :no-require
  :hook (scala-ts-mode . load-lsp-metals)
  :init
  (defun load-lsp-metals ()
    (require 'lsp-metals)))


(use-package lsp-haskell
  :ensure '(lsp-haskell :host github :repo "emacs-lsp/lsp-haskell")
  :defer 10)

(use-package haskell-mode
  :ensure t
  :hook
  (haskell-mode . lsp-deferred)
  :commands haskell-mode)

(use-package markdown-mode
  :hook
  (markdown-mode . olivetti-mode)
  (markdown-mode . variable-pitch-mode)
  :custom
  (markdown-header-scaling t)
  (markdown-marginalize-headers t)
  (markdown-enable-wiki-links t)
  (markdown-wiki-links-alias-first nil)
  (markdown-enable-math t)
  (markdown-hide-urls t)
  (markdown-hide-markup t)
  (markdown-fontify-code-blocks-natively t)
  (markdown-enable-highlighting-syntax t)
  :mode
  (("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode)))

(use-package cognitive-complexity
  :ensure '(cognitive-complexity :host github :repo "emacs-vs/cognitive-complexity")
  :hook (ruby-ts-mode python-base-mode js-ts-mode csharp-ts-mode))

(provide 'ik-prog)
;;; ik-prog.el ends here
