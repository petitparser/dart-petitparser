part of lisp;

/**
 * The standard library.
 */
class Standard {

  /** Imports the standard library into the [environment]. */
  static Environment import(Environment environment) {
    evalString(new LispParser(), environment, _standardLibrary);
    return environment;
  }

  /** A simple standard library, should be moved to external file. */
  static String _standardLibrary = """
; null functions
(define null '())
(define (null? x) (= '() x))

; booleans
(define true (and))
(define false (or))

; list functions
(define (length list)
  (if (null? list)
      0
      (+ 1 (length (cdr list)))))

(define (append list1 list2)
  (if (null? list1)
    list2
    (cons (car list1) (append (cdr list1) list2))))

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

(define (for-each list proc)
  (while (not (null? list))
    (proc (car list))
    (set! list (cdr list))))

(define (map list proc)
  (if (null? list)
    '()
    (cons (proc (car list))
          (map (cdr list) proc))))

(define (inject list value proc)
  (if (null? list)
    value
    (inject
      (cdr list)
      (proc value (car list))
      proc)))
""";

}
