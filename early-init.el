;;; early-init.el --- Emacs 27+ pre-initialisation config  -*- lexical-binding: t; -*-

;;; Commentary:

;; Emacs 27+ loads this file before (normally) calling
;; `package-initialize'.  We use this file to suppress that automatic
;; behaviour so that startup is consistent across Emacs versions.

;;; Code:

(setq package-enable-at-startup nil)

;; Emacs.app bundles libgccjit 14, which derives -mmacosx-version-min
;; from the Darwin version (Darwin 27 -> "18.0"), and clang rejects it.
;; Pass an explicit value so the driver doesn't compute its own.
(require 'comp)
(setq native-comp-driver-options (cons "-mmacosx-version-min=11" native-comp-driver-options))

;; So we can detect this having been loaded
(provide 'early-init)

;;; early-init.el ends here
