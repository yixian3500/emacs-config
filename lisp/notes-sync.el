;;; lisp/notes-sync.el -*- lexical-binding: t; -*-
;;; rclone luancher from emacs

(defgroup my/note nil
  "note sync from Emacs."
  :group 'tools)

(defcustom my/note-local
  (cond
  ((eq system-type 'darwin) (expand-file-name "~/Nutstore Files/Obsidian"))
  ((or (eq system-type 'gnu/linux)(string-match-p "android" system-configuration))
   (expand-file-name "/storage/emulated/0/ob/Obsidian"))
  (t
    (expand-file-name "~/notes")))
  "Local note directory"
  :type 'directory)

(defcustom my/note-remote "infini-ob:Obsidian"
  "rclone remote"
  :type 'string)

(defun my/sync-note-via-script (mode)
  "Run ~/dotfiles/sync.sh with env from Emacs"
  (let* ((cmd (format "MODE=%S LOCAL_NOTE_PATH=%s REMOTE=%s ~/dotfiles/sync.sh 2>&1"
                     (shell-quote-argument mode)
                     (shell-quote-argument my/note-local)
                     (shell-quote-argument my/note-remote)))
        (bufname "*rclone-sync*")
        (display-buffer-alist
         '(("\\*rclone-sync\\*" display-buffer-no-window)))
        buf)
      (message "syncing (%s)..." mode)
      (setq buf
      (compilation-start cmd 'compilation-mode (lambda (_) bufname)))
      (with-current-buffer buf
        (setq-local mode-name "Sync") ;; cosmetic if you even openit
        ;;Replace the default finish message
        (setq-local compilation-exit-message-function
                    (lambda (status code _msg)
                      (let* ((ok (and (eq status 'exit) (zerop code)))
                             (m (if ok "sync finished" (format "syncing failed (%s)" code))))
                        (message "%s" m)
                        ;; also return (message . face) for the buffer header
                        (cons m (if ok 'compilation-info 'compilation-error))))))))
;;;###autoload
(defun my/sync-note-push ()
  "Sync push local to remote."
  (interactive)
  (my/sync-note-via-script "push" ))

;;;###autoload
(defun my/sync-note-pull ()
  "Sync pull remote to local."
  (interactive)
  (my/sync-note-via-script "pull" ))
(provide 'notes-sync)
