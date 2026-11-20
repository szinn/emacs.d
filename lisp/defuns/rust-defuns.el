;;; rust-defuns.el --- Rust helpers and commands -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun scotte/rust-buffer-p ()
  "Return non-nil if the current buffer is a Rust buffer."
  (derived-mode-p 'rust-mode 'rust-ts-mode))

(defun scotte/rust-format-before-save ()
  "Format the buffer via eglot when it is managing this buffer."
  (when (and (fboundp 'eglot-managed-p) (eglot-managed-p))
    (eglot-format-buffer)))

(defun scotte/cargo-nextest ()
  "Run `cargo nextest run' from the nearest Cargo workspace root."
  (interactive)
  (let ((default-directory
         (or (and (fboundp 'projectile-project-root) (projectile-project-root))
             (locate-dominating-file default-directory "Cargo.toml")
             default-directory)))
    (compile "cargo nextest run")))

(provide 'rust-defuns)
;;; rust-defuns.el ends here
