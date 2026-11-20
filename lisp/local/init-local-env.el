;;; init-local-env.el --- Personal environment setup -*- lexical-binding: t -*-
;;; Commentary:

;; The shell uses `mise activate', which Emacs only sees for the home
;; directory (global tools).  Shims resolve per-project tool versions
;; from the subprocess's working directory, so project-local tools
;; (helm_ls, kubeconform, yaml-language-server, ...) become reachable.

;;; Code:

(let ((shims (expand-file-name "~/.local/share/mise/shims")))
  (when (file-directory-p shims)
    (add-to-list 'exec-path shims t)
    (setenv "PATH" (concat (getenv "PATH") path-separator shims))))

(provide 'init-local-env)
;;; init-local-env.el ends here
