; Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

; native functions
(native-import-all)

(define null '())
(define (null? x) (= '() x))

; list functions
(define (length list)
  (if (null? list)
      0
      (+ 1 (length (cdr list)))))

(define (append list1 list2)
  (if (null? list1)
    list2
    (cons (car list1) (append (cdr list1) list2))))

(define (for-each list proc)
  (while (null? list)
    (proc (car list))
    (set! list (cdr list))))

(define (list-head list index)
  (if (= index 0)
    (car list)
    (list-head
      (cdr list)
      (- index 1))))

(define (list-tail list index)
  (if (= index 0)
    (cdr list)
    (list-tail
      (cdr list)
      (- index 1))))

(define (map list proc)
  (if (null? list)
    '()
    (cons (proc (car list))
          (map (cdr list) proc))))

(define (inject list value proc)
  (while (not (null? list))
    (set! value (proc value (car list)))
    (set! list (cdr list)))
  value)