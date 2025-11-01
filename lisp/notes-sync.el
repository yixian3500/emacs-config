;;; lisp/notes-sync.el -*- lexical-binding: t; -*-
;;; rclone luancher from emacs

(defgroup my/note nil
  "note sync from Emacs."
  :group 'tools)

(defcustom my/note-local (expand-file-name "~/Nutstore Files/Obsidian")
  "Local note directory"
  :type 'directory)

(defcustom my/note-remote "infini-ob:Obsidian"
  "rclone remote"
  :type 'string)

;;;###autoload
(defun my/sync-note-via-script ()
  "Run ~/dotfiles/sync.sh with env from Emacs"
  (interactive)
  (let* ((buf (get-buffer-create "*rclone-sync*"))
      (process-environment
         (append
          (list
           (concat "LOCAL_NOTE_PATH="my/note-local)
           (concat "REMOTE=" my/note-remote))
                       process-environment))
         (proc nil))
    (with-current-buffer buf
      (read-only-mode -1)
      (erase-buffer)
      (insert (format "$ LOCAL_NOTE_PATH=%s REMOTE=%s ~/dotfiles/sync.sh\n\n"
                      my/note-local my/note-remote))
      (read-only-mode 1))
    (make-process
     :name "rclone-sync"
     :buffer buf
     :stderr buf
     :noquery t
     :command '("/bin/bash" "-lc" "~/dotfiles/sync.sh")
     :sentinel
     (lambda (p _event)
        (when (memq (process-status p) '(exit signal))
          (let* ((code (process-exit-status p))
                 (msg (if (= code 0) "sync OK" (format "FAILED (%d)" code))))
             (message "rclone-sync: %s" msg)
             (display-buffer (process-buffer p))))))))

;;; note-sync.el ends here
