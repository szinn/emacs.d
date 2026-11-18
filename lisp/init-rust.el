;;; init-rust.el --- Support for the Rust language -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Keep rust-mode installed as a fallback if tree-sitter grammar isn't built yet
(maybe-require-package 'rust-mode)

;; Remap .rs files to Emacs 31's built-in Tree-sitter mode
(add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode))

(with-eval-after-load 'rust-ts-mode
  ;; Disable flycheck in Rust buffers so Eglot + Flymake handle diagnostics cleanly
  (add-hook 'rust-ts-mode-hook (lambda () (flycheck-mode -1)))
  ;; Start Eglot automatically
  (add-hook 'rust-ts-mode-hook #'eglot-ensure)
  ;; Format via rust-analyzer (rustfmt) on save
  (add-hook 'rust-ts-mode-hook
            (lambda ()
              (add-hook 'before-save-hook #'eglot-format-buffer nil t))))

;; Configure rust-analyzer for Clippy and multi-crate workspaces
(with-eval-after-load 'eglot
  (setq eglot-events-buffer-config '(:size 0 :format full))
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer" :initializationOptions
                  (:check (:command "clippy"
                                    :workspace t)
                          :cargo (:features "all"
                                            :buildScripts (:enable t))
                          :procMacro (:enable t))))))

;; Old version
;; (when (maybe-require-package 'rust-mode)
;;   (when (maybe-require-package 'flycheck-rust)
;;     (with-eval-after-load 'rust-mode
;;       (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))))

(provide 'init-rust)
;;; init-rust.el ends here
