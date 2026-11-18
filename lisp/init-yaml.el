;;; init-yaml.el --- Support Yaml files -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(when (maybe-require-package 'yaml-mode)
  (add-auto-mode 'yaml-mode "\\.yml\\.erb\\'")
  (add-hook 'yaml-mode-hook 'goto-address-prog-mode))

;; Prefer Emacs 31's built-in Tree-sitter mode for standard YAML files
(add-to-list 'major-mode-remap-alist '(yaml-mode . yaml-ts-mode))

(with-eval-after-load 'yaml-ts-mode
  ;; Preserve clickable URLs from your original setup
  (add-hook 'yaml-ts-mode-hook #'goto-address-prog-mode)
  ;; Disable Flycheck so Eglot + Flymake handle schema diagnostics cleanly
  (add-hook 'yaml-ts-mode-hook (lambda () (flycheck-mode -1)))
  ;; Ensure dir-locals are read before starting Eglot so eglot-workspace-configuration is active
  (add-hook 'yaml-ts-mode-hook
            (lambda ()
              (hack-dir-local-variables-non-file-buffer)
              (eglot-ensure))))

;; Configure yaml-language-server for Kubernetes and SchemaStore
(with-eval-after-load 'eglot
  (setq-default eglot-workspace-configuration
                '(:yaml (:format (:enable t)
                                 :validate t
                                 :hover t
                                 :completion t
                                 :schemaStore (:enable t)))))

;; Old way
;; (when (maybe-require-package 'yaml-mode)
;;   (add-auto-mode 'yaml-mode "\\.yml\\.erb\\'")
;;   (add-hook 'yaml-mode-hook 'goto-address-prog-mode))


(provide 'init-yaml)
;;; init-yaml.el ends here
