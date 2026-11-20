;;; init-local-rust.el --- Rust via tree-sitter + eglot -*- lexical-binding: t -*-
;;; Commentary:

;; flymake + eglot supply diagnostics; flycheck is kept out of Rust buffers.

;;; Code:

;; rust-mode stays installed as a fallback if the grammar isn't built yet.
(maybe-require-package 'rust-mode)
(add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode))

(with-eval-after-load 'rust-mode
  (remove-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(defun scotte/rust-setup ()
  "Per-buffer Rust setup."
  (eglot-ensure))

(defun scotte/rust-ts-setup ()
  "Extra setup for `rust-ts-mode' buffers."
  (when (fboundp 'flycheck-mode)
    (flycheck-mode -1))
  ;; Format via rust-analyzer (rustfmt) on save.
  (add-hook 'before-save-hook #'scotte/rust-format-before-save nil t))

(add-hook 'rust-mode-hook #'scotte/rust-setup)
(add-hook 'rust-ts-mode-hook #'scotte/rust-setup)
(add-hook 'rust-ts-mode-hook #'scotte/rust-ts-setup)

(defun scotte/rust-eglot-features ()
  "Re-enable semantic tokens and enable inlay hints in Rust buffers."
  (when (and (eglot-managed-p) (scotte/rust-buffer-p))
    (eglot-semantic-tokens-mode 1)
    (eglot-inlay-hints-mode 1)))

(with-eval-after-load 'eglot
  ;; Depth 90 so this runs after the global semantic-tokens disable.
  (add-hook 'eglot-managed-mode-hook #'scotte/rust-eglot-features 90)
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer" :initializationOptions
                  (:check (:command "clippy" :workspace t)
                   :cargo (:features "all" :buildScripts (:enable t))
                   :procMacro (:enable t))))))

(with-eval-after-load 'rust-mode
  (define-key rust-mode-map (kbd "C-c C-c C-n") #'scotte/cargo-nextest))
(with-eval-after-load 'rust-ts-mode
  (define-key rust-ts-mode-map (kbd "C-c C-c C-n") #'scotte/cargo-nextest))

(provide 'init-local-rust)
;;; init-local-rust.el ends here
