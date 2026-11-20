;;; init-local-projectile.el --- Projectile tweaks -*- lexical-binding: t -*-
;;; Commentary:

;; Keep projectile out of project.el.  Its `project-files' ignores the DIRS
;; argument, so eglot's per-directory watch registrations (rust-analyzer
;; sends one per crate) each watch the whole tree, exhausting kqueue fds
;; on macOS.  project.el's own VC backend honours DIRS and .gitignore.

;;; Code:

(defun scotte/projectile-leave-project-el-alone ()
  "Remove projectile from `project-find-functions'."
  (remove-hook 'project-find-functions #'project-projectile))
(add-hook 'projectile-mode-hook #'scotte/projectile-leave-project-el-alone)

(provide 'init-local-projectile)
;;; init-local-projectile.el ends here
