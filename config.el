;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
;; ANDRIOD Specail Setting
(defconst +on-termux-android
  (or (string-match-p "android" system-configuration)
          (getenv "TERMUX_VERSION")
          (file-directory-p "/data/data/com.termux/files")))

(after! dired
  (ignore-errors
    (advice-remove #'dired-find-file #'dirvish-find-entry-a)))

;; Hide owner/group columns on the narrow Termux display.
(when +on-termux-android
  (after! dired
  (setq dired-hide-details-initially t)
  (add-hook! 'dired-mode-hook :append #'dired-hide-details-mode )
  (add-hook! 'dired-after-readin-hook :append #'dired-hide-details-mode)

  (setq dired-listing-switches "-Alh --group-directories-first -g -o"))
)

;; add lisp dir
(add-to-list 'load-path (expand-file-name "lisp" doom-user-dir))
(require 'notes-sync)
(map! :leader
      (:prefix ("r" . "Run/Sync")
       :desc "Sync notes push" "s" #'my/sync-note-push
       :desc "Sync notes pull" "p" #'my/sync-note-pull))
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
(setq doom-theme 'doom-dracula)

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
  ;;  "Prompt for a project and set capture target to its Daily Progress Log heading."
(defun yx/org-capture-progress-file ()
  "Prompt for a project and set capture target to its Daily Progress Log heading."
  (let* ((project-list '("guanyin25"
                         "coca-2w-words"
                         "kiss-grd-100h"
                         ))
         (project (completing-read "Choose Project: " project-list nil t))
         (file (expand-file-name (format "projects/%s.org" project)
                                 org-directory)))
    (unless (file-exists-p file)
      (make-directory (file-name-directory file) t)
      (with-temp-buffer
        (insert "* Daily Progress Log\n")
        (write-file file)))
      file))
    ;; Ensure file exists and, if empty, initialize it with the heading
(after! org
  ;;  (setq org-directory "/Users/longgongmeishi/Nutstore Files/Obsidian/org/")
  (setq! org-agenda-files (directory-files-recursively org-directory "\\.org\\'"))
  (setq! org-capture-templates
        `(("t" "Todo" entry
           (file+headline ,yx-org-inbox "Inbox")
           "* TODO %?")
        ("p" "Progress" entry
         (file+headline yx/org-capture-progress-file "Progress Log")
         "* %<%Y-%m-%d %a> - %? \n:PROPERTIES:\n:Date: %<%Y-%m-%d>\n:Count: \n:END:"
         :empty-lines 1)
                    ))
  (setq! org-refile-targets '((org-agenda-files . (:maxlevel . 3))))
  (setq! org-refile-use-outline-path t)
  (setq! org-outline-path-complete-in-steps nil)
  ;; add done-log for org
  (setq org-log-done 'time)
  ;; setting GTD workflow
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
          (sequence "WAITING(w)" "BLOCKED(b)" "|" "CANCELLED(c)")))
  )

;; Configure Org-Roam and Org-Roam Dailies
;; -------------------------------------------------------------------------
(after! org-roam
  ;; -----------------------------------------------------------------------
  ;; 1. basic path setting
  ;; -----------------------------------------------------------------------
  (setq org-roam-directory yx-org-base
        org-roam-db-location (expand-file-name "org-roam.db" yx-org-base))
  ;; -----------------------------------------------------------------------
  ;; 2. Normal Note  Capture template
  ;; -----------------------------------------------------------------------
 (setq org-roam-capture-templates
        `(("d" "default" plain "%?"
           :if-new (file+head "${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)))
 ;; -----------------------------------------------------------------------
 ;; 3. Dailies Setting
 ;; -----------------------------------------------------------------------
  (setq org-roam-dailies-directory "daily/"
        org-roam-dailies-capture-templates
        `(("d" "daily" plain
           (file ,(expand-file-name "daily/template_2025.org" yx-org-base))
           :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n")
           ;;:unnarrowed t
           :immediate-finish nil
           )))
  ;; -----------------------------------------------------------------------
  (map! :leader
        (:prefix ("t" . "Notes")
         :desc "Find daily"      "d" #'org-roam-dailies-goto-date
         :desc "Find tomorrow"   "t" #'org-roam-dailies-goto-tomorrow
         :desc "Find yesterday"  "y" #'org-roam-dailies-goto-yesterday
         :desc "Find today"      "n" #'org-roam-dailies-goto-today
         :desc "Capture today"   "N" #'org-roam-dailies-capture-today
         :desc "Find node"       "f" #'org-roam-node-find
         :desc "Insert node"     "i" #'org-roam-node-insert)))

;; for the org-babel python3 setting
(setq org-babel-python-command "python3")
(setq python-shell-interpreter "python3")

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
;(when (not (display-graphic-p))
;  (custom-set-faces!
;   '(default :foreground "#ffd8af")))
 (custom-set-faces!
  '(region :background "#44475a" :foreground "#ffffff")
  ;; '(region :background "#6272a4" :foreground "#ffffff")
)
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
;;
(when (string-equal system-type "darwin")

(use-package! exec-path-from-shell
  :when (memq window-system '(mac ns))
  :config
  (dolist (var '("PATH" "HW_API_KEY" "OPENROUTER_API_KEY"))
    (add-to-list 'exec-path-from-shell-variables var))
  (exec-path-from-shell-initialize))

(after! geiser
  (setq geiser-active-implementations '(racket)
      geiser-default-implementation 'racket
      geiser-racket-binary "/Applications/Racket v8.18/bin/racket"
      geiser-repl-per-project-p t)
)
;; for agent-shell
(after! agent-shell
(setq agent-shell-google-authentication (agent-shell-google-make-authentication :login t)))

;; for minuet
(use-package! minuet
  :defer t
  :init
  (add-hook 'prog-mode-hook #'minuet-auto-suggestion-mode)
  :config
  (setq minuet-provider 'openai-compatible
        minuet-request-timeout 10
        minuet-show-error-message-on-minibuffer t
        minuet-auto-suggestion-throttle-delay 1.5
        minuet-auto-suggestion-debounce-delay 0.6
        minuet-n-completions 1
        minuet-context-window 768)

  (plist-put minuet-openai-compatible-options :name "Huawei-DeepSeek-V3.2")
  (plist-put minuet-openai-compatible-options
             :end-point "https://api.modelarts-maas.com/v2/chat/completions")
  (plist-put minuet-openai-compatible-options :api-key "HW_API_KEY")
  (plist-put minuet-openai-compatible-options :model "deepseek-v3.2-vy7ggp")
  (minuet-set-optional-options minuet-openai-compatible-options :max_tokens 96)
  (minuet-set-optional-options minuet-openai-compatible-options :top_p 0.9)

  (map! :map minuet-active-mode-map
        "M-p" #'minuet-previous-suggestion
        "M-n" #'minuet-next-suggestion
        "M-]" #'minuet-accept-suggestion
        "M-[" #'minuet-accept-suggestion-line
        "M-e" #'minuet-dismiss-suggestion)

  (map! :i "M-i" #'minuet-show-suggestion
        :i "M-y" #'minuet-complete-with-minibuffer))

;; for gptel
(use-package! gptel
  :init
  (load! "gptel-prompts.el")
  :config
  (setq gptel-api-key (getenv "HW_API_KEY"))
  (setq gptel-model 'deepseek-v3.2)

  (gptel-make-openai "Huawei-DeepSeek-V3.2"
    :host "api.modelarts-maas.com"
    :endpoint "/v2/chat/completions"
    :stream t
    :key (getenv "HW_API_KEY")
    :models '(
              (deepseek-v3.2-exp . "deepseek-v3.2-exp-BUN0bx")
              (deepseek-v3.2     . "deepseek-v3.2-vy7ggp")))

  (gptel-make-ollama "Ollama"
    :host "localhost:11434"
    :stream t
    :models '(
              (qwen3:8b    . "qwen3:8b")
              (qwen3.5:9b  . "qwen3.5:9b")
              (qwen-vl-8b . "qwen3-vl:8b")))

  (gptel-make-openai "openrouter"
    :host "openrouter.ai"
    :endpoint "/api/v1/chat/completions"
    :stream t
    :key (getenv "OPENROUTER_API_KEY")
    :models '(
            (gpt-5.2    . "openai/gpt-5.2")
            (gemini-3-pro-preview . "google/gemini-3-pro-preview")
            (minimax-m2.5 . "minimax/minimax-m2.5")
            (grok-4.1-fast . "x-ai/grok-4.1-fast")
            (gemini-3-flash-preview . "google/gemini-3-flash-preview")))

  (setq gptel-backend (gptel-get-backend "Huawei-DeepSeek-V3.2")
        gptel-default-mode 'org-mode)

  (map! :map gptel-mode-map
        "C-c m" #'gptel-menu)
  )

(map! :leader
      :desc "GPTel send"
      "v s" #'gptel-send)

(map! :leader
      (:prefix ("v" . "ai")
       :desc "Minuet complete" "m" #'minuet-complete-with-minibuffer
       :desc "Minuet suggest" "i" #'minuet-show-suggestion
       :desc "Minuet configure" "M" #'minuet-configure-provider))

(add-to-list 'auto-mode-alist '("\\.ets\\'" . tsx-ts-mode))
(setq treesit-font-lock-level 4)

(use-package! sdcv
  :config
  (setq sdcv-say-word-p nil)
  (map! :leader
    (:prefix ("d" . "dictionary")
     :desc "Lookup typed word" "s" #'sdcv-search-input
     :desc "Lookup word at point" "S" #'sdcv-search-pointer))
  )
)
