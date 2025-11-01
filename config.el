;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-



;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
;;
;; ANDRIOD Specail Setting
(when (or (string-match-p "android" system-configuration)
          (getenv "TERMUX_VERSION")
          (file-directory-p "/data/data/com.termux/files"))
 (after! vc
        (setq vc-gzip-switches '("-c")))
;;Termux/Android setting vc-gzip-switches
  (after! dired
    ;; Hide owner/group columns on the narrow Termux display.
    (add-hook 'dired-mode-hook #'dired-hide-details-mode)))

;; add lisp dir
(add-to-list 'load-path (expand-file-name "lisp" doom-user-dir))
(autoload 'my/sync-note-via-script "notes-sync")
(map! :leader
      (:desc "Sync notes" "r s" #'my/sync-note-via-script))
;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-one)
(setq doom-theme 'doom-challenger-deep)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!

;; change `org-directory'. It must be set before org loads!
(defconst yx-home
  (or (getenv "HOME") (getenv "USERPROFILE"))
  "Portable home directory")

(defun yx-path (&rest parts)
 (apply (if (fboundp 'file-name-concat) #'file-name-concat
        (lambda (a b)(expand-file-name b a)))
        parts))

(defconst yx-org-base
  (cond
   ((eq system-type 'darwin) (yx-path yx-home "Nutstore Files/Obsidian/org"))
   ((or (eq system-type 'gnu/linux)
        (string-match-p "android" system-configuration))
;;    "/storage/emulated/0/Documents/obsidian/Obsidian/org")
      "/storage/emulated/0/ob/Obsidian/org")
   (t (yx-path yx-home "org")))
  "Root of all org file across platforms.")

(defconst yx-org-inbox (expand-file-name "inbox.org" yx-org-base))
(setq org-directory yx-org-base)

(after! org
  ;;  (setq org-directory "/Users/longgongmeishi/Nutstore Files/Obsidian/org/")
  (setq! org-agenda-files (directory-files-recursively org-directory "\\.org\\'"))
  (setq! org-capture-templates
        `(("t" "Todo" entry
           (file+headline ,yx-org-inbox "Inbox")
           "* TODO %?")))
  (setq! org-refile-targets '((org-agenda-files . (:maxlevel . 3))))
  (setq! org-refile-use-outline-path t)
  (setq! org-outline-path-complete-in-steps nil)
  )

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;(setq doom-theme 'doom-challenger-deep)
;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
;;set markdown color
(when (not (display-graphic-p))
  (custom-set-faces!
   '(default :foreground "#ffd8af")))
;;set the clipboard for macos
;;; --- macOS Specific Settings ---
(when (and (string-equal system-type "darwin") (not (display-graphic-p)))
  (defun copy-to-osx-clipboard (text &optional push)
    "Write TEXT to the macOS clipboard."
    (with-temp-buffer
      (insert text)
      (call-process-region (point-min) (point-max) "pbcopy" nil 0 nil)))

  (defun paste-from-osx-clipboard ()
    "Read and return content from the macOS clipboard."
    (with-temp-buffer
      (call-process "pbpaste" nil t nil)
      (buffer-string)))

  (setq interprogram-cut-function #'copy-to-osx-clipboard)
  (setq interprogram-paste-function #'paste-from-osx-clipboard))
;;; ================================================================
(setq evil-default-command-delay 0.05)
;;
(after! geiser
  (setq geiser-active-implementations '(racket)
      geiser-default-implementation 'racket
      geiser-racket-binary "/Applications/Racket v8.18/bin/racket"
      geiser-repl-per-project-p t)
)
