;;; init-local-terminals.el --- Ghostel and terminal clipboard -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Ghostel: libghostty-vt based terminal.  On first use it offers to
;; download a prebuilt native module.
(when (maybe-require-package 'ghostel)
  (global-set-key (kbd "C-c g") #'scotte/ghostel-dwim)
  (add-hook 'after-init-hook 'ghostel-status-indicator-mode))

;; Share the kill ring with the macOS clipboard from terminal frames.
;; GUI frames already do this; the handlers defer to the defaults there.
(when (and *is-a-mac* (executable-find "pbcopy"))
  (setq interprogram-cut-function #'scotte/pbcopy
        interprogram-paste-function #'scotte/pbpaste))

(provide 'init-local-terminals)
;;; init-local-terminals.el ends here
