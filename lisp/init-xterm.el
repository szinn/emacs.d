;;; init-xterm.el --- Integrate with terminals such as xterm -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'init-frame-hooks)

(global-set-key [mouse-4] (lambda () (interactive) (scroll-down 1)))
(global-set-key [mouse-5] (lambda () (interactive) (scroll-up 1)))

(autoload 'mwheel-install "mwheel")

(defun sanityinc/console-frame-setup ()
  (xterm-mouse-mode 1) ; Mouse in a terminal (Use shift to paste with middle button)
  (mwheel-install))



(add-hook 'after-make-console-frame-hooks 'sanityinc/console-frame-setup)


;; Share the kill ring with the macOS clipboard from terminal frames.
;; GUI frames already do this, so defer to the default handlers there.
(when (and *is-a-mac* (executable-find "pbcopy"))
  (defun sanityinc/pbcopy (text)
    (if (display-graphic-p)
        (gui-select-text text)
      (let* ((process-connection-type nil)
             (process-environment (cons "LANG=en_US.UTF-8" process-environment))
             (proc (start-process "pbcopy" nil "pbcopy")))
        (set-process-coding-system proc 'utf-8 'utf-8)
        (process-send-string proc text)
        (process-send-eof proc))))

  (defun sanityinc/pbpaste ()
    (if (display-graphic-p)
        (gui-selection-value)
      (let* ((process-environment (cons "LANG=en_US.UTF-8" process-environment))
             (coding-system-for-read 'utf-8)
             (text (shell-command-to-string "pbpaste")))
        (unless (or (string-empty-p text)
                    (string= text (car kill-ring)))
          text))))

  (setq interprogram-cut-function #'sanityinc/pbcopy
        interprogram-paste-function #'sanityinc/pbpaste))

(provide 'init-xterm)
;;; init-xterm.el ends here
