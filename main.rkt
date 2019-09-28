#lang br/quicklang
(require brag/support "grammer.rkt"
         json)
(provide top definition field main category)

(module+ reader
  (provide read-syntax))

(define schema
  (hash
   "$schema" "http://json-schema.org/draft-07/schema#"
   "additionalProperties" #f))

(define-lex-abbrev digits
  (:+ (char-set ".0123456789")))

(define tokenize
  (lexer-srcloc
   [(:= 1 blank) (token 'SP lexeme #:skip? #t)]
   [(:= 2 blank) (token 'TAB lexeme)]
   [":" (token 'COLON lexeme)]
   [(:seq "\"" (:+ alphabetic punctuation numeric " ") "\"")
    (token 'STRING lexeme)]
   ["\n" (token 'NL lexeme)]
   [(:or "main" "category") (token 'QUALIFIER (string->symbol lexeme))]
   [(:+ alphabetic) (token 'ID (string->symbol lexeme))]
   [(:seq digits) (token 'NUMBER (string->number lexeme))]
   ))

(define-macro top #'#%module-begin)

(define-macro (definition ARG ...)
  ;  (println #'(list 'ARG ...))
  #'(list 'ARG ...)) 

(define-macro (field ARG)
  #'ARG)

;(define-macro (qualifier ARG)
;  #'ARG)

(define-macro (main ARG ...)
  #'(list 'ARG ...))

(define-macro (category ARG ...)
  #'(list 'ARG ...)) 

(define (read-syntax src ip)
  (port-count-lines! ip)
  (lexer-file-path ip)

  (define parse-tree (parse src (λ () (tokenize ip))))
;  (println parse-tree)
;  (println schema)

  (strip-bindings
   (with-syntax ([PT parse-tree])
     #'(module hatcher-mod hatcher
         PT))))
