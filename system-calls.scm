;; Primitive log system
(define *log-level* 'warning)

(define-syntax DEBUG
  (syntax-rules ()
    ((_ cmd)
     (if (eq? *log-level* 'debug)
         cmd))))

(define (ok? return-code)
  (eq? 0 return-code))

(define (command-exists? command)
  (ok? (system (format "command -v ~a" command))))

(define (download url outfile)
  (let ((result
         (cond ((command-exists? "wget")
                (system (format "wget --quiet --show-progress --progress=bar:force:noscroll -O ~a ~a" outfile url)))
               ((command-exists? "curl")
                (system (format "curl -s -L ~a --output ~a" url outfile)))
               (else (error (format "Could not find curl/wget. Please install one of those programs to continue~%"))))))
    (if (ok? result)
        (begin (DEBUG (display (format "[OK] Downloaded ~a~%" outfile)))
               outfile)
        (error (format "Could not download ~a. Lack of permissions? Return code" outfile) result))))

(define (validate-sha256sum sha256sum file)
  (let ((result
         (cond ((command-exists? "sha256sum")
                (system (format "echo ~a ~a | sha256sum --status --check -" sha256sum file)))
               ((command-exists? "sha256")
                (system (format "sha256 -q -c ~a ~a" sha256sum file)))
               (else (error (format "Could not find sha256/sha256sum. Please install one of those programs to continue~%"))))))
    (if (ok? result)
        (begin (DEBUG (display (format "[OK] Passed sha256sum verification~%" )))
               file)
        (error (format "Incorrect sha256sum for file ~a. Return code~%" file) result))))

(define (extract file dir)
  (let ((result (system (format "tar zxf ~a --strip=1 -C ~a" file dir))))
    (if (ok? result)
        (begin (DEBUG (display (format "[OK] Extracted ~a into ~a~%" file dir)))
               dir)
        (error (format "Could not extract ~a into ~a. Lack of permissions? Return code" file dir) result))))

(define (delete file-or-dir)
  (let ((result (system (format "rm -Rf ~a" file-or-dir))))
    (if (ok? result)
        (begin (DEBUG (display (format "[OK] Deleted ~a~%" file-or-dir)))
               file-or-dir)
        (error (format "Could not delete ~a. Lack of permissions? Return code" file-or-dir) result))))

(define (compile file . dir)
  (let* ((dir (if (null? dir) "." (car dir)))
         (result (system (format "cyclone -Wno-unused-command-line-argument -A ~a -A ~a ~a" dir (path-dir file) file))))
    (if (ok? result)
        (begin (DEBUG (display (format "[OK] File ~a compiled~%" file)))
               file)
        (error (format "Could not compile file ~a. Return code" file) result))))

(define (make-dir path)
  (let ((result (system (format "mkdir -p ~a" path))))
    (if (ok? result)
        path
        (error (format "Could not create path ~a. Lack of permissions? Return code" path) result))))

(define (copy-file-to-dir file to-dir)
  (make-dir to-dir)
  (let ((result (system (format "cp ~a ~a" file to-dir))))
    (if (ok? result)
        (begin (DEBUG (display (format "[OK] File ~a copied into ~a~%" file to-dir)))
               file)
        (error (format "Could not copy file ~a into ~a. Lack of permissions? Return code" file to-dir) result))))

(define (copy-dir-to-dir dir to-dir)
  (make-dir to-dir)
  (let ((result (system (format "cp -Rf ~a ~a" dir to-dir))))
    (if (ok? result)
        (begin (DEBUG (display (format "[OK] Dir ~a copied into ~a~%" dir to-dir)))
               dir)
        (error (format "Could not copy dir ~a into ~a. Lack of permissions? Return code" dir to-dir) result))))

(define (copy-file file to-file)
  (let ((result (system (format "cp ~a ~a" file to-file))))
    (if (ok? result)
        (begin (DEBUG (display (format "[OK] File ~a copied to ~a~%" file to-file)))
               file)
        (error (format "Could not copy file ~a to ~a. Lack of permissions? Return code" file to-file) result))))

(define (touch file)
  (let ((result (system (format "touch ~a" file))))
    (if (ok? result)
        file
        (error (format "Could not touch file ~a. Lack of permissions? Return code" file) result))))
