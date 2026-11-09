;;; init-local.el --- Personal settings -*- lexical-binding: t -*-
;;; Commentary:

;; Loaded last from init.el.  Keeps personal changes out of the
;; upstream-tracked files.

;;; Code:

;;; mise

;; The shell uses `mise activate', which Emacs only sees for the home
;; directory (global tools).  Shims resolve per-project tool versions
;; from the subprocess's working directory, so project-local tools
;; (helm_ls, kubeconform, yaml-language-server, ...) become reachable.
(let ((shims (expand-file-name "~/.local/share/mise/shims")))
  (when (file-directory-p shims)
    (add-to-list 'exec-path shims t)
    (setenv "PATH" (concat (getenv "PATH") path-separator shims))))

;;; Rust

;; flymake + eglot supply diagnostics; flycheck-mode is never enabled.
(with-eval-after-load 'rust-mode
  (remove-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(defun scotte/rust-buffer-p ()
  "Return non-nil if the current buffer is a Rust buffer."
  (derived-mode-p 'rust-mode 'rust-ts-mode))

(defun scotte/rust-format-before-save ()
  "Format the buffer via eglot when it is managing this buffer."
  (when (and (fboundp 'eglot-managed-p) (eglot-managed-p))
    (eglot-format-buffer)))

(defun scotte/rust-setup ()
  "Per-buffer Rust setup."
  ;; (add-hook 'before-save-hook #'scotte/rust-format-before-save nil t)
  (eglot-ensure))

(add-hook 'rust-mode-hook #'scotte/rust-setup)
(add-hook 'rust-ts-mode-hook #'scotte/rust-setup)

(defun scotte/rust-eglot-features ()
  "Re-enable semantic tokens and enable inlay hints in Rust buffers."
  (when (and (eglot-managed-p) (scotte/rust-buffer-p))
    (eglot-semantic-tokens-mode 1)
    (eglot-inlay-hints-mode 1)))

(with-eval-after-load 'eglot
  ;; Depth 90 so this runs after the global semantic-tokens disable.
  (add-hook 'eglot-managed-mode-hook #'scotte/rust-eglot-features 90))

(setq-default eglot-workspace-configuration
              '(:rust-analyzer
                (:check (:command "clippy")
                 :cargo (:features "all")
                 :procMacro (:enable t)
                 :inlayHints (:closureReturnTypeHints (:enable "with_block")))))

(defun scotte/cargo-nextest ()
  "Run `cargo nextest run' from the nearest Cargo workspace root."
  (interactive)
  (let ((default-directory
         (or (and (fboundp 'projectile-project-root) (projectile-project-root))
             (locate-dominating-file default-directory "Cargo.toml")
             default-directory)))
    (compile "cargo nextest run")))

(with-eval-after-load 'rust-mode
  (define-key rust-mode-map (kbd "C-c C-c C-n") #'scotte/cargo-nextest))
(with-eval-after-load 'rust-ts-mode
  (define-key rust-ts-mode-map (kbd "C-c C-c C-n") #'scotte/cargo-nextest))


;;; YAML

(defvar-local scotte/yaml-eglot nil
  "Non-nil starts yaml-language-server via eglot in YAML buffers.
Set from a project's .dir-locals.el, since the server is a per-project
mise tool.")
(put 'scotte/yaml-eglot 'safe-local-variable #'booleanp)

(defun scotte/yaml-sops-file-p ()
  "Return non-nil if the current buffer visits a SOPS-encrypted file."
  (and buffer-file-name
       (string-match-p "\\.sops\\.[^/]*\\'" buffer-file-name)))

(defun scotte/yaml-setup ()
  "Start eglot or silence linting, after dir-locals are applied."
  (when (derived-mode-p 'yaml-mode 'yaml-ts-mode)
    (cond
     ;; Encrypted: yamllint's ignore list doesn't apply to stdin, and
     ;; the sops: block fails schema validation.
     ((scotte/yaml-sops-file-p)
      (flymake-mode -1))
     (scotte/yaml-eglot
      (eglot-ensure)))))

(defun scotte/yaml-hack-locals-hook ()
  "Defer YAML setup until dir-locals are in effect."
  (add-hook 'hack-local-variables-hook #'scotte/yaml-setup nil t))

(add-hook 'yaml-mode-hook #'scotte/yaml-hack-locals-hook)
(add-hook 'yaml-ts-mode-hook #'scotte/yaml-hack-locals-hook)

(defun scotte/yaml-keep-yamllint ()
  "Re-add flycheck checkers (yamllint) after eglot replaces them."
  (when (and (eglot-managed-p)
             (derived-mode-p 'yaml-mode 'yaml-ts-mode)
             (fboundp 'flymake-flycheck-auto))
    (flymake-flycheck-auto)))

(with-eval-after-load 'eglot
  (add-hook 'eglot-managed-mode-hook #'scotte/yaml-keep-yamllint 90))

;; Stay on yaml-mode even with the YAML grammar installed:
;; Emacs 31's yaml-ts-mode has no indentation rules.
;; init-treesitter (loaded before this file) adds the remap.
(setq major-mode-remap-alist
      (assq-delete-all 'yaml-mode major-mode-remap-alist))

;; yaml-pro-ts-mode creates its own YAML parser, so it works on top
;; of yaml-mode.  Structural navigation/editing; jump by path with
;; `consult-imenu' (M-g i).
(when (maybe-require-package 'yaml-pro)
  (defun scotte/yaml-pro-maybe-enable ()
    "Enable `yaml-pro-ts-mode' when the YAML grammar is available."
    (when (and (fboundp 'treesit-ready-p) (treesit-ready-p 'yaml t))
      (yaml-pro-ts-mode 1)))
  (add-hook 'yaml-mode-hook #'scotte/yaml-pro-maybe-enable))


;;; Scratch

;; *scratch* has no file, so Emacs 30+ treats it as untrusted and the
;; elisp byte-compile flymake backend refuses to run (with a message).
(add-hook 'lisp-interaction-mode-hook
          (lambda () (flymake-mode -1)))


;;; Debugging

(when (maybe-require-package 'dape)
  (setq dape-buffer-window-arrangement 'right)
  ;; lldb-dap ships with Xcode but isn't on PATH.
  ;; Resolved lazily so startup doesn't pay for the xcrun call.
  (with-eval-after-load 'dape
    (let ((lldb-dap (and *is-a-mac*
                         (string-trim
                          (shell-command-to-string "xcrun -f lldb-dap 2>/dev/null"))))
          (cfg (alist-get 'lldb-dap dape-configs)))
      (when (and cfg lldb-dap (file-executable-p lldb-dap))
        (setf (alist-get 'lldb-dap dape-configs)
              (plist-put cfg 'command lldb-dap))))))


(provide 'init-local)
;;; init-local.el ends here
