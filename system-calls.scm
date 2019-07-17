(define (ok? return-code)
  (eq? 0 return-code))

(define (download url outfile)
  (let ((result (system (format "wget --quiet --show-progress --progress=bar:force:noscroll -O ~a ~a" outfile url))))
    (if (ok? result)
        (begin (display (format "[OK] File ~a downloaded~%" outfile))
               outfile)
        (error (format "Could not download ~a. Lack of permissions? Return code" outfile) result))))

(define (validate-sha256sum sha256sum file)
  (let ((result (system (format "echo ~a ~a | sha256sum --status --check -" sha256sum file))))
    (if (ok? result)
        (begin (display (format "[OK] Passed sha256sum verification~%" ))
               file)
        (error (format "Incorrect sha256sum for file ~a. Return code~%" file) result))))

(define (extract file dir)
  (let ((result (system (format "tar zxf ~a --strip=1 -C ~a" file dir))))
    (if (ok? result)
        (begin (display (format "[OK] Extracted ~a into ~a~%" file dir))
               dir)
        (error (format "Could not extract ~a into ~a. Lack of permissions? Return code" file dir) result))))

(define (delete file-or-dir)
  (let ((result (system (format "rm -Rf ~a" file-or-dir))))
    (if (ok? result)
        (begin (display (format "[OK] Deleted ~a~%" file-or-dir))
               file-or-dir)
        (error (format "Could not delete ~a. Lack of permissions? Return code" file-or-dir) result))))

(define (compile file . dir)
  (let* ((dir (if (null? dir) "." (car dir)))
         (result (system (format "cyclone -A ~a -A ~a ~a" dir (path-dir file) file))))
    (if (ok? result)
        (begin (display (format "[OK] File ~a compiled~%" file))
               file)
        (error (format "Could not compile file ~a. Return code" file) result))))

(define (make-dir path)
  (let ((result (system (format "mkdir -p ~a" path))))
    (if (ok? result)
        path
        (error (format "Could not create path ~a. Lack of permissions? Return code" path) result))))

(define (copy-file file to-dir)
  (make-dir to-dir)
  (let ((result (system (format "cp ~a ~a" file to-dir))))
    (if (ok? result)
        (begin (display (format "[OK] File ~a copied to ~a~%" file to-dir))
               file)
        (error (format "Could not copy file ~a into ~a. Lack of permissions? Return code" file to-dir) result))))


