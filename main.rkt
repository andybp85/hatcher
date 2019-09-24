#lang br/quicklang
(require brag/support "grammer.rkt")
(provide top definition field)

(module+ reader
  (provide read-syntax))

(define tokenize
  (lexer-srcloc
   [(:= 1 blank) (token 'SP lexeme #:skip? #t)]
   [(:= 2 blank) (token 'TAB lexeme)]
   [":" (token 'COLON lexeme)]
   [(:seq "\"" (:+ alphabetic) "\"") (token 'STRING lexeme)]
   ["\n" (token 'NL lexeme)] 
   [(:+ alphabetic) (token 'ID (string->symbol lexeme))]
   ))

(define-macro top #'#%module-begin)

(define-macro (definition ARG)
  (println #'ARG))

(define-macro (field ARG)
  (println #'ARG))

(define (read-syntax src ip)
  (port-count-lines! ip)
  (lexer-file-path ip)

  (define parse-tree (parse src (λ () (tokenize ip))))
  (println parse-tree)

  (strip-bindings
   (with-syntax ([PT parse-tree])
     #'(module hatcher-mod hatcher
         PT))))
