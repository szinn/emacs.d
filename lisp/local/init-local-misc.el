;;; init-local-misc.el --- Bookmarks, scratch, debugging -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;; Bookmarks

;; Jump with completion and on-demand preview (M-P).
(with-eval-after-load 'consult
  (global-set-key [remap bookmark-jump] #'consult-bookmark))


;;; Scratch

;; *scratch* has no file, so Emacs 30+ treats it as untrusted and the
;; elisp byte-compile flymake backend refuses to run (with a message).
(defun scotte/disable-flymake ()
  "Turn off `flymake-mode' in the current buffer."
  (flymake-mode -1))
(add-hook 'lisp-interaction-mode-hook #'scotte/disable-flymake)


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

(provide 'init-local-misc)
;;; init-local-misc.el ends here
