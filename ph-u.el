;; -*- lexical-binding: t -*-

(require 'cl-lib)

(defconst ph-meta-name "ph")
(defconst ph-meta-version "0.0.1")

(defvar ph-verbose 2 "Verbosity level")

(defconst ph-vcs-list '((git . ".git")))
(defvar ph-vcs-def 'git)



(defun ph-warn (level str)
  "Print a message via (message) according to LEVEL."
  (if (<= level ph-verbose) (message (concat ph-meta-name ": " str))))

(defun ph-chomp (str)
  "Chomp leading and tailing whitespace from STR."
  (if (not str) ""
	(while (string-match "\\`\n+\\|^\\s-+\\|\\s-+$\\|\n+\\'" str)
	  (setq str (replace-match "" t t str)))
	str))

(defun ph-dirname (d)
  "A robust dirname(1). Return '.' on error."
  (cl-block nil
	(if (not d) (cl-return "."))
	(setq d (ph-chomp d))
	(if (equal "" d) (cl-return "."))

	(let ((tmp (file-name-directory (directory-file-name d))))
	  (if (not tmp) (cl-return ".")
		(directory-file-name tmp))
	  )))

(defun ph-file-relative (file dir)
  "Return FILE name transformed as relative to DIR.
Raise error if DIR isn't a substring of FILE."
  (cl-block nil
	(unless file (error "FILE is nil"))
	(unless dir (cl-return file))

	(setq file (ph-chomp file))
	(setq dir (ph-chomp dir))
	(if (equal "" dir) (cl-return file))

	(unless (string-prefix-p dir file)
	  (error "%s must be a prefix of %s" dir file))

	(let ((path (substring file (length dir))))
	  ;; remove possible leading '/' in the result
	  (if (and (> (length path) 0) (equal "/" (substring path 0 1)))
		  (substring path 1)
		path)
	  )))



(defun ph-vcs-init (dir &optional type)
  "Create a new TYPE repo and add all files to it from DIR.
Don't make a commit. Return t on success."
  (unless type (setq type ph-vcs-def))

  ;; FIXME: write it
  (mkdir (concat dir "/.git"))
  t
  )

(defun ph-vcs-detect (dir)
  "Check for specific files in DIR, return a symbol if found."
  (cl-block here
	(if (not dir) (cl-return-from here nil))

	(cl-loop for idx in ph-vcs-list do
			 (if (file-directory-p (concat dir "/" (cdr idx)))
				 (cl-return-from here (car idx))))
	nil
	))



(provide 'ph-u)
