; Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

; basic functions
(define lambda (native "lambda"))
(define quote (native "quote"))
(define let (native "let"))
(define eval (native "eval"))
(define set! (native "set!"))
(define print (native "print"))

; control structures
(define if (native "if"))
(define while (native "while"))
(define and (native "and"))
(define or (native "or"))
(define not (native "not"))

; arithmetic methods
(define + (native "add"))
(define - (native "sub"))
(define * (native "mul"))
(define / (native "div"))
(define % (native "mod"))

; arithmetic comparators
(define < (native "less"))
(define <= (native "less_equal"))
(define == (native "equal"))
(define != (native "not_equal"))
(define >= (native "larger"))
(define > (native "larger_equal"))

; list operations
(define cons (native "cons"))
(define car (native "car"))
(define cdr (native "cdr"))