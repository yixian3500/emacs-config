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

;;;###autoload
(defun my/sync-note-via-script ()
  "Run ~/dotfiles/sync.sh with env from Emacs"
  (interactive)
  (let* ((cmd (format "LOCAL_NOTE_PATH=%s REMOTE=%s ~/dotfiles/sync.sh 2>&1"
                     (shell-quote-argument my/note-local)
                     (shell-quote-argument my/note-remote)))
        (bufname "*rclone-sync*")
        (display-buffer-alist
         '(("\\*rclone-sync\\*" display-buffer-no-window)))
        buf)
      (message "syncing...")
      (setq buf
      (compilation-start cmd 'compilation-mode (lambda (_) bufname)))
      (with-current-buffer buf
        (setq-local mode-name "Sync") ;; cosmetic if you even openit
        ;;Replace the default finish message
        (setq-local compilation-exit-message-fuction
                    (lambda (status code _msg)
                      (let* ((ok (and (eq status 'exit) (zerop code)))
                             (m (if ok "syncing" (format "syncing failed (%s)" code))))
                        (message "%s" m)
                        ;; also return (message . face) for the buffer header
                        (cons m (if ok 'compilation-info 'compilation-error))))))))

;;  (let* ((buf (get-buffer-create "*rclone-sync*"))
 ;;     (process-environment
 ;;        (append
 ;;         (list
 ;;          (concat "LOCAL_NOTE_PATH="my/note-local)
 ;;          (concat "REMOTE=" my/note-remote))
 ;;                      process-environment))
 ;;        (proc nil))
 ;;   (with-current-buffer buf
 ;;     (read-only-mode -1)
 ;;     (erase-buffer)
 ;;     (insert (format "$ LOCAL_NOTE_PATH=%s REMOTE=%s ~/dotfiles/sync.sh\n\n"
 ;;                     my/note-local my/note-remote))
 ;;     (read-only-mode 1))
 ;;   (make-process
 ;;    :name "rclone-sync"
 ;;    :buffer buf
 ;;    :stderr buf
 ;;    :noquery t
 ;;    :command '("/bin/bash" "-lc" "~/dotfiles/sync.sh")
 ;;    :sentinel
 ;;    (lambda (p _event)
 ;;       (when (memq (process-status p) '(exit signal))
 ;;         (let* ((code (process-exit-status p))
 ;;                (msg (if (= code 0) "sync OK" (format "FAILED (%d)" code))))
 ;;            (message "rclone-sync: %s" msg)
 ;;            (display-buffer (process-buffer p))))))))

;;; note-sync.el ends here
