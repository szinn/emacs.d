;;; init-projectile.el --- Use Projectile for navigation within projects -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(when (maybe-require-package 'projectile)
  (add-hook 'after-init-hook 'projectile-mode)

  ;; Shorter modeline
  (setq-default projectile-mode-line-prefix " Proj")

  (when (executable-find "rg")
    (setq-default projectile-generic-command "rg --files --hidden -0"))

  (with-eval-after-load 'projectile
    (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

  ;; Keep projectile out of project.el.  Its `project-files' ignores the DIRS
  ;; argument, so eglot's per-directory watch registrations (rust-analyzer
  ;; sends one per crate) each watch the whole tree, exhausting kqueue fds
  ;; on macOS.  project.el's own VC backend honours DIRS and .gitignore.
  (defun sanityinc/projectile-leave-project-el-alone ()
    (remove-hook 'project-find-functions #'project-projectile))
  (add-hook 'projectile-mode-hook #'sanityinc/projectile-leave-project-el-alone)

  (maybe-require-package 'ibuffer-projectile))


(provide 'init-projectile)
;;; init-projectile.el ends here
