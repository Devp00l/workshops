;; make R save and restore instead of using sessions; this gives the input and output as displayed by the R console
(setq-local org-babel-R-command "R --silent --save --restore")
(global-set-key [C-mouse-4] 'text-scale-increase)
(global-set-key [C-mouse-5] 'text-scale-decrease)
;; don't let orgmode resize images (this means you must set them to the correct size when generating!)
(setq-local org-latex-image-default-option "")

;; don't insert default css
(setq-local org-html-head-include-default-style nil)

(setq-local org-confirm-babel-evaluate nil)

;; add license note at the bottom of the page
(setq-local org-html-postamble
            "<p><a rel='license' href='http://creativecommons.org/licenses/by-sa/4.0/'><img alt='Creative Commons Lizenzvertrag' style='border-width:0' src='https://i.creativecommons.org/l/by-sa/4.0/80x15.png' /></a><br />Dieses Werk ist lizenziert unter einer <a rel='license' href='http://creativecommons.org/licenses/by-sa/4.0/'>Creative Commons Namensnennung - Weitergabe unter gleichen Bedingungen 4.0 International Lizenz</a>.</p> <p> Zur Verfügung gestellt von  <a href='http://ferdinand-braun-schule.de'> Jörg Reuter - Ferdinand-Braun-Schule Fulda</a> <br></br> <a href='http://ferdinand-braun-schule.de'><img style='margin-left: auto; margin-right: auto;' alt='Ferdinand-Braun-Schule Fulda' title='FBS Logo' src='http://www.ferdinand-braun-schule.de/fileadmin/files/images/Grafiken/FBS_Logo.gif'></img></a></p>")

;; no section numbers
(setq-local org-export-with-section-numbers nil)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t))) ; this line activates ditaa

;; resize images
(setq org-image-actual-width '(600))

;; present all output in blocks
(setq-local org-babel-min-lines-for-block-output 0)

;; do not re-evaluate source code on export
(set (make-local-variable 'org-export-babel-evaluate) nil)

;; enable source code support in orgmode
(org-babel-do-load-languages
 'org-babel-load-languages
 '(;(stata . t) ;; requires custom ob-stata.el
   (emacs-lisp . t)
   (sh . t)
   (R . t)
   (latex . t)
   (octave . t)
   (ditaa . t)
   (org . t)
   (perl . t)
   (python . t)
   (matlab . t)))

;; display images in the orgmode buffer automatically
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
(global-visual-line-mode t)
;; convenience function to export headings to markdown chapters for upload to datacamp
(defun my-exp-to-datacamp (course)
  "Export org mode file to form suitable for upload to datacamp.org."
  (interactive "sEnter course name: ")
  ;; make datacamp directory if it doesn't exist
  (if (file-directory-p "datacamp") nil (make-directory "datacamp"))
  ;; demarcate code blocks on markdown export (needed for datacamp)
  (defun my-md-src-block-replace (text backend info)
    (when (org-export-derived-backend-p backend 'md)
      (concat "```{r eval = FALSE}\n" text "```\n")))
  (add-to-list 'org-export-filter-src-block-functions
	       'my-md-src-block-replace)
  ;; include html comments
  (defun my-md-keyword-replace (text backend info)
    (when (org-export-derived-backend-p backend 'md)
      (replace-regexp-in-string
       "\\(<!-- MD: \\)\\(.*\\)\\(-->\\)"
       "\\2" text nil nil)))
  (make-local-variable 'org-export-filter-keyword-functions)
  (add-to-list 'org-export-filter-keyword-functions
               'my-md-keyword-replace)
  ;; export headings to separate files
  (org-map-entries
   (lambda ()
     ;; some magic I don't understand written by John Kitchin on the orgmode mailing list
     (let ((level (nth 1 (org-heading-components)))
           (title (nth 4 (org-heading-components))))
       (when (= level 1)
	 ;; add meta data to top of each exported file
	 (defun my-md-filter-add-meta-data (text backend info)
	   "Ensure \" \" are properly handled in Md export."
	   (when (org-export-derived-backend-p backend 'md)
	     (concat 
"--- 
courseTitle       : " course "
chapterTitle      : " title "
description       : 
framework         : datamind
mode              : selfcontained
---

" text)))
	 (add-to-list 'org-export-filter-final-output-functions
		      'my-md-filter-add-meta-data)
	 ;; set up export file names and turn of table of contents 
         (org-entry-put (point) "EXPORT_FILE_NAME" (concat "datacamp/" title))
	 (org-entry-put (point) "EXPORT_OPTIONS" "num:nil toc:nil")
	 ;; export each heading
         (org-md-export-to-markdown nil 1 nil)
	 ;; rename files with .Rmd extension
	 (rename-file (concat "datacamp/" title ".md") (concat "datacamp/" title ".Rmd") t)))))
  ;; remove changed settings
  (setq org-export-filter-final-output-functions (delete 'my-md-filter-add-meta-data org-export-filter-final-output-functions))
  (setq org-export-filter-src-block-functions (delete 'my-md-src-block-replace org-export-filter-src-block-functions))
  (setq org-export-filter-keyword-functions (delete 'my-md-keyword-replace org-export-filter-keyword-functions))
  nil nil)
(require 'org)
