;;; terminal-defuns.el --- Terminal and clipboard helpers -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun scotte/ghostel-dwim (&optional arg)
  "Open Ghostel in the project root if in a project, else `default-directory'.
ARG is passed through to `ghostel-project' or `ghostel'."
  (interactive "P")
  (if (project-current)
      (ghostel-project arg)
    (ghostel arg)))

(defun scotte/pbcopy (text)
  "Copy TEXT to the macOS clipboard; GUI frames use the default handler."
  (if (display-graphic-p)
      (gui-select-text text)
    (let* ((process-connection-type nil)
           (process-environment (cons "LANG=en_US.UTF-8" process-environment))
           (proc (start-process "pbcopy" nil "pbcopy")))
      (set-process-coding-system proc 'utf-8 'utf-8)
      (process-send-string proc text)
      (process-send-eof proc))))

(defun scotte/pbpaste ()
  "Return the macOS clipboard if new; GUI frames use the default handler."
  (if (display-graphic-p)
      (gui-selection-value)
    (let* ((process-environment (cons "LANG=en_US.UTF-8" process-environment))
           (coding-system-for-read 'utf-8)
           (text (shell-command-to-string "pbpaste")))
      (unless (or (string-empty-p text)
                  (string= text (car kill-ring)))
        text))))

(provide 'terminal-defuns)
;;; terminal-defuns.el ends here
