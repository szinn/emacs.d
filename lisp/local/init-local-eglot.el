;;; init-local-eglot.el --- Shared eglot settings -*- lexical-binding: t -*-
;;; Commentary:

;; `eglot-workspace-configuration' is a single plist shared by every
;; server, so all servers' sections live here together.

;;; Code:

(setq-default eglot-workspace-configuration
              '(:rust-analyzer
                (:check (:command "clippy")
                 :cargo (:features "all")
                 :procMacro (:enable t)
                 :inlayHints (:closureReturnTypeHints (:enable "with_block")))
                :yaml
                (:format (:enable t)
                 :validate t
                 :hover t
                 :completion t
                 :schemaStore (:enable t))))

(with-eval-after-load 'eglot
  (setq eglot-events-buffer-config '(:size 0 :format full)))

(provide 'init-local-eglot)
;;; init-local-eglot.el ends here
