;;; init-local-yaml.el --- YAML: per-project eglot, yaml-pro -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar-local scotte/yaml-eglot nil
  "Non-nil starts yaml-language-server via eglot in YAML buffers.
Set from a project's .dir-locals.el, since the server is a per-project
mise tool.")
(put 'scotte/yaml-eglot 'safe-local-variable #'booleanp)

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
(add-hook 'yaml-ts-mode-hook #'goto-address-prog-mode)

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

(provide 'init-local-yaml)
;;; init-local-yaml.el ends here
