;;; yaml-defuns.el --- YAML helpers -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun scotte/yaml-sops-file-p ()
  "Return non-nil if the current buffer visits a SOPS-encrypted file."
  (and buffer-file-name
       (string-match-p "\\.sops\\.[^/]*\\'" buffer-file-name)))

(provide 'yaml-defuns)
;;; yaml-defuns.el ends here
