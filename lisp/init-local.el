;;; init-local.el --- Personal settings -*- lexical-binding: t -*-
;;; Commentary:

;; Loaded last from init.el.  Keeps personal changes out of the
;; upstream-tracked files:
;;
;;   lisp/defuns/  personal functions and commands; every file is loaded
;;   lisp/local/   personal configuration, one init-local-<feature>.el each

;;; Code:

(let ((dir (expand-file-name "defuns" (file-name-directory load-file-name))))
  (dolist (file (directory-files dir t "\\`[^.#].*\\.el\\'"))
    (load (file-name-sans-extension file) nil t)))

(add-to-list 'load-path
             (expand-file-name "local" (file-name-directory load-file-name)))

(require 'init-local-env)
(require 'init-local-eglot)
(require 'init-local-projectile)
(require 'init-local-terminals)
(require 'init-local-jj)
(require 'init-local-fish)
(require 'init-local-rust)
(require 'init-local-yaml)
(require 'init-local-misc)

(provide 'init-local)
;;; init-local.el ends here
