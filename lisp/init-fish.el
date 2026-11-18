;;; init-fish.el --- Support for the fish shell -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(when (maybe-require-package 'fish-mode)
  ;; Templated fish scripts (e.g. chezmoi's foo.fish.tmpl)
  (add-to-list 'auto-mode-alist '("\\.fish\\.tmpl\\'" . fish-mode))

  (add-hook 'fish-mode-hook
            (lambda ()
              ;; Skip fish_indent on templates: it would mangle the template directives.
              (when (and (executable-find "fish_indent")
                         (not (and buffer-file-name
                                   (string-suffix-p ".tmpl" buffer-file-name))))
                (add-hook 'before-save-hook 'fish_indent-before-save nil t)))))

(provide 'init-fish)
;;; init-fish.el ends here
