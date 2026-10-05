#lang eopl
;Autores: Maria Fernanda Betancourt Montoya 2459510, Oliver De Jesus Arboleda Baez 2459684, Kevin Andres Rosero Romo 2459554

;; Taller 1 — Polinomios dispersos
;; Parte 3: representación con define-datatype
;;
;; Gramática (BNF):
;;   <polinomio>   ::= <variable> <terminos>          poli(var, terms)
;;   <variable>    ::= <symbol>                       nombre-var(s)
;;   <terminos>    ::= '()                            sin-terminos()
;;                 ::= <termino> <terminos>           mas-terminos(term, resto)
;;   <termino>     ::= <coeficiente> <exponente>      termino(coef, expo)
;;   <coeficiente> ::= <int>                          coef-ent(n)
;;                 ::= <int> "/" <int>                coef-rac(num, den)
;;   <exponente>   ::= <int>                          expo-nat(k)
;;
;; Invariante: exponentes en orden estrictamente decreciente, sin coeficientes
;; cero, exponentes naturales y racionales reducidos (denominador > 0).
;;
;; Interfaz (valores concretos de Racket en coeficientes y exponentes):
;;   polinomio-cero    : symbol -> polinomio
;;   insertar-termino  : polinomio x coeficiente x exponente -> polinomio
;;   coeficiente-de    : polinomio x exponente -> coeficiente
;;   eliminar-termino  : polinomio x exponente -> polinomio
;;   sumar             : polinomio x polinomio -> polinomio
;;
;; Nota: el tipo <termino> se llama termino-tad porque define-datatype no
;; permite que el tipo se llame igual que su variante

(provide (all-defined-out))

;; ---------------------------------------------------------------------------
;; Datatypes (definidos de las hojas hacia la raíz)

(define-datatype exponente exponente?
  (expo-nat (k integer?)))

(define-datatype coeficiente coeficiente?
  (coef-ent (n integer?))
  (coef-rac (num integer?) (den integer?)))

(define-datatype termino-tad termino-tad?
  (termino (coef coeficiente?) (expo exponente?)))

(define-datatype terminos terminos?
  (sin-terminos)
  (mas-terminos (term termino-tad?) (resto terminos?)))

(define-datatype variable variable?
  (nombre-var (s symbol?)))

(define-datatype polinomio polinomio?
  (poli (var variable?) (terms terminos?)))

;; ---------------------------------------------------------------------------
;; Predicados de variante (nombre del constructor + ?)
;; Contrato: any -> boolean
;; Propósito: decir si el valor es de esa variante

(define poli?
  (lambda (x)
    (and (polinomio? x)
         (cases polinomio x
           (poli (var terms) #t)))))

(define nombre-var?
  (lambda (x)
    (and (variable? x)
         (cases variable x
           (nombre-var (s) #t)))))

(define sin-terminos?
  (lambda (x)
    (and (terminos? x)
         (cases terminos x
           (sin-terminos () #t)
           (mas-terminos (term resto) #f)))))

(define mas-terminos?
  (lambda (x)
    (and (terminos? x)
         (cases terminos x
           (sin-terminos () #f)
           (mas-terminos (term resto) #t)))))

(define termino?
  (lambda (x)
    (and (termino-tad? x)
         (cases termino-tad x
           (termino (coef expo) #t)))))

(define coef-ent?
  (lambda (x)
    (and (coeficiente? x)
         (cases coeficiente x
           (coef-ent (n) #t)
           (coef-rac (num den) #f)))))

(define coef-rac?
  (lambda (x)
    (and (coeficiente? x)
         (cases coeficiente x
           (coef-ent (n) #f)
           (coef-rac (num den) #t)))))

(define expo-nat?
  (lambda (x)
    (and (exponente? x)
         (cases exponente x
           (expo-nat (k) #t)))))

;; Extractores (nombre de la variante -> nombre del campo)
;; Contrato: dato de esa variante -> valor del campo
;; Propósito: obtener el campo, error si el dato es de otra variante

(define poli->var
  (lambda (p)
    (cases polinomio p
      (poli (var terms) var))))

(define poli->terms
  (lambda (p)
    (cases polinomio p
      (poli (var terms) terms))))

(define nombre-var->s
  (lambda (v)
    (cases variable v
      (nombre-var (s) s))))

(define mas-terminos->term
  (lambda (ts)
    (cases terminos ts
      (mas-terminos (term resto) term)
      (else (eopl:error 'mas-terminos->term "No es mas terminos: ~s" ts)))))

(define mas-terminos->resto
  (lambda (ts)
    (cases terminos ts
      (mas-terminos (term resto) resto)
      (else (eopl:error 'mas-terminos->resto "No es mas terminos: ~s" ts)))))

(define termino->coef
  (lambda (t)
    (cases termino-tad t
      (termino (coef expo) coef))))

(define termino->expo
  (lambda (t)
    (cases termino-tad t
      (termino (coef expo) expo))))

(define coef-ent->n
  (lambda (c)
    (cases coeficiente c
      (coef-ent (n) n)
      (else (eopl:error 'coef-ent->n "No es coef-ent: ~s" c)))))

(define coef-rac->num
  (lambda (c)
    (cases coeficiente c
      (coef-rac (num den) num)
      (else (eopl:error 'coef-rac->num "No es coef-rac: ~s" c)))))

(define coef-rac->den
  (lambda (c)
    (cases coeficiente c
      (coef-rac (num den) den)
      (else (eopl:error 'coef-rac->den "No es coef-rac: ~s" c)))))

(define expo-nat->k
  (lambda (e)
    (cases exponente e
      (expo-nat (k) k))))

;; ---------------------------------------------------------------------------
;; Traducción concreto <-> abstracto

;; concreto->coef : número exacto -> coeficiente
;; Propósito: 4 -> (coef-ent 4); -3/2 -> (coef-rac -3 2).

(define concreto->coef
  (lambda (c)
    (if (integer? c)
        (coef-ent c)
        (coef-rac (numerator c) (denominator c)))))

;; coef->concreto : coeficiente -> número exacto
;; Propósito: camino inverso de concreto->coef
(define coef->concreto
  (lambda (c)
    (cases coeficiente c
      (coef-ent (n) n)
      (coef-rac (num den) (/ num den)))))

;; coeficiente-valido? : any -> boolean
;; Propósito: #t si es un número exacto y racional
(define coeficiente-valido?
  (lambda (c)
    (and (number? c) (exact? c) (rational? c))))

;; exponente-valido? : any -> boolean
;; Propósito: #t si es un entero exacto mayor o igual que cero.
(define exponente-valido?
  (lambda (e)
    (and (number? e) (integer? e) (exact? e) (>= e 0))))


;; Interfaz
;; ---------------------------------------------------------------------------

;; polinomio-cero : symbol -> polinomio
;; Propósito: retorna el polinomio nulo en la variable dada
(define polinomio-cero
  (lambda (sym)
    (if (symbol? sym)
        (poli (nombre-var sym) (sin-terminos))
        (eopl:error 'polinomio-cero "La variable debe ser un simbolo: ~s" sym))))

;; insertar-en : terminos x número x entero -> terminos
;; Propósito: inserta (coef, expo) en la lista ordenada con una sola pasada
;; Exponente nuevo: lo coloca en su sitio (si coef = 0 no hace nada)
;; Exponente existente: suma coeficientes, si es cero el término desaparece
(define insertar-en
  (lambda (ts coef expo)
    (cases terminos ts
      (sin-terminos ()
        (if (zero? coef)
            ts
            (mas-terminos (termino (concreto->coef coef) (expo-nat expo))
                          (sin-terminos))))
      (mas-terminos (t resto)
        (cases termino-tad t
          (termino (c e)
            (let ((k (expo-nat->k e)))
              (cond
                ((> expo k)
                 (if (zero? coef)
                     ts
                     (mas-terminos (termino (concreto->coef coef) (expo-nat expo))
                                   ts)))
                ((= expo k)
                 (let ((s (+ (coef->concreto c) coef)))
                   (if (zero? s)
                       resto
                       (mas-terminos (termino (concreto->coef s) e) resto))))
                (else
                 (mas-terminos t (insertar-en resto coef expo)))))))))))

;; insertar-termino : polinomio x coeficiente x exponente -> polinomio
;; Propósito: inserta el término respetando el invariante, suma si el
;; exponente ya existe. Error si expo < 0 o si coef no es número exacto

(define insertar-termino
  (lambda (pol coef expo)
    (cond
      ((not (exponente-valido? expo))
       (eopl:error 'insertar-termino "El exponente debe ser un entero no negativo"))
      ((not (coeficiente-valido? coef))
       (eopl:error 'insertar-termino "El coeficiente debe ser un numero exacto"))
      (else
       (cases polinomio pol
         (poli (var terms)
           (poli var (insertar-en terms coef expo))))))))

;; buscar-coef : terminos x entero -> número exacto
;; Propósito: recorre la lista una vez; como está ordenada, se detiene en cuanto pasa del exponente buscado
(define buscar-coef
  (lambda (ts expo)
    (cases terminos ts
      (sin-terminos ()
        (eopl:error 'coeficiente-de "El polinomio no tiene termino con ese exponente"))
      (mas-terminos (t resto)
        (cases termino-tad t
          (termino (c e)
            (let ((k (expo-nat->k e)))
              (cond
                ((= k expo) (coef->concreto c))
                ((< k expo)
                 (eopl:error 'coeficiente-de
                             "El polinomio no tiene termino con ese exponente"))
                (else (buscar-coef resto expo))))))))))

;; coeficiente-de : polinomio x exponente -> número exacto
;; Propósito: coeficiente concreto del término con ese exponente; error si el polinomio no tiene tal término

(define coeficiente-de
  (lambda (pol expo)
    (if (exponente-valido? expo)
        (cases polinomio pol
          (poli (var terms) (buscar-coef terms expo)))
        (eopl:error 'coeficiente-de "El exponente debe ser un entero no negativo"))))

;; quitar-en : terminos x entero -> terminos
;; Propósito: elimina el término con ese exponente en una sola pasada

(define quitar-en
  (lambda (ts expo)
    (cases terminos ts
      (sin-terminos ()
        (eopl:error 'eliminar-termino "El polinomio no tiene termino con ese exponente"))
      (mas-terminos (t resto)
        (cases termino-tad t
          (termino (c e)
            (let ((k (expo-nat->k e)))
              (cond
                ((= k expo) resto)
                ((< k expo)
                 (eopl:error 'eliminar-termino
                             "El polinomio no tiene termino con ese exponente"))
                (else (mas-terminos t (quitar-en resto expo)))))))))))

;; eliminar-termino : polinomio x exponente -> polinomio
;; Propósito: retorna un polinomio nuevo sin el término de ese exponente, error si no existe

(define eliminar-termino
  (lambda (pol expo)
    (if (exponente-valido? expo)
        (cases polinomio pol
          (poli (var terms) (poli var (quitar-en terms expo))))
        (eopl:error 'eliminar-termino "El exponente tiene que ser un entero no negativo"))))

;; sumar-terminos : terminos x terminos -> terminos
;; Propósito: mezcla dos listas ordenadas recorriéndolas en paralelo una sola vez, combina exponentes iguales y descarta los que suman cero

(define sumar-terminos
  (lambda (ta tb)
    (cases terminos ta
      (sin-terminos () tb)
      (mas-terminos (t1 r1)
        (cases terminos tb
          (sin-terminos () ta)
          (mas-terminos (t2 r2)
            (let ((e1 (expo-nat->k (termino->expo t1)))
                  (e2 (expo-nat->k (termino->expo t2))))
              (cond
                ((> e1 e2) (mas-terminos t1 (sumar-terminos r1 tb)))
                ((< e1 e2) (mas-terminos t2 (sumar-terminos ta r2)))
                (else
                 (let ((s (+ (coef->concreto (termino->coef t1))
                             (coef->concreto (termino->coef t2)))))
                   (if (zero? s)
                       (sumar-terminos r1 r2)
                       (mas-terminos (termino (concreto->coef s) (termino->expo t1))
                                     (sumar-terminos r1 r2)))))))))))))

;; sumar : polinomio x polinomio -> polinomio
;; Propósito: suma de dos polinomios en la misma variable, error si las variables difieren

(define sumar
  (lambda (p q)
    (let ((vp (nombre-var->s (poli->var p)))
          (vq (nombre-var->s (poli->var q))))
      (if (eq? vp vq)
          (poli (poli->var p)
                (sumar-terminos (poli->terms p) (poli->terms q)))
          (eopl:error 'sumar "Los polinomios deben estar en la misma variable: ~s ~s"
                      vp vq)))))

;; polinomio->lista : polinomio -> (symbol (coef expo) ...)
;; Propósito: (auxiliar) vista concreta del polinomio para imprimirlo

(define polinomio->lista
  (lambda (pol)
    (cons (nombre-var->s (poli->var pol))
          (terminos->lista (poli->terms pol)))))

(define terminos->lista
  (lambda (ts)
    (cases terminos ts
      (sin-terminos () '())
      (mas-terminos (t resto)
        (cons (list (coef->concreto (termino->coef t))
                    (expo-nat->k (termino->expo t)))
              (terminos->lista resto))))))

;; ---------------------------------------------------------------------------
;; Ejemplos
 
;; Construcción de datos con los constructores
(define ej-coef-entero (coef-ent 4))
(define ej-coef-racional (coef-rac -3 2))
(define ej-termino (termino (coef-ent 7) (expo-nat 0)))
(define ej-terminos
  (mas-terminos (termino (coef-rac -3 2) (expo-nat 2))
                (mas-terminos (termino (coef-ent 7) (expo-nat 0))
                              (sin-terminos))))
(define ej-poli-nulo (poli (nombre-var 'x) (sin-terminos)))
 
(display (coef-ent? ej-coef-entero)) (newline)           ; #t
(display (coef-rac->num ej-coef-racional)) (newline)     ; -3
(display (coef-rac->den ej-coef-racional)) (newline)     ; 2
(display (expo-nat->k (termino->expo ej-termino))) (newline) ; 0
(display (sin-terminos? (poli->terms ej-poli-nulo))) (newline) ; #t
 
;; Polinomios de prueba
;; p = 4x^5 - (3/2)x^2 + 7      q = -4x^5 + (1/2)x^2 + 2x
(define p
  (insertar-termino
   (insertar-termino
    (insertar-termino (polinomio-cero 'x) 7 0)
    -3/2 2)
   4 5))
(define q
  (insertar-termino
   (insertar-termino
    (insertar-termino (polinomio-cero 'x) 2 1)
    1/2 2)
   -4 5))
 
;; polinomio-cero
(display (polinomio->lista (polinomio-cero 'x))) (newline) ; (x)
(display (polinomio->lista (polinomio-cero 'y))) (newline) ; (y)
(display (sin-terminos? (poli->terms (polinomio-cero 'z)))) (newline) ; #t
 
;; insertar-termino
(display (polinomio->lista p)) (newline)                        ; (x (4 5) (-3/2 2) (7 0))
(display (polinomio->lista (insertar-termino p 1 2))) (newline)   ; (x (4 5) (-1/2 2) (7 0))
(display (polinomio->lista (insertar-termino p 3/2 2))) (newline) ; (x (4 5) (7 0))
;; (insertar-termino p 5 -1)  ; Error: El exponente debe ser un entero no negativo
 
;; coeficiente-de
(display (coeficiente-de p 2)) (newline) ; -3/2
(display (coeficiente-de p 5)) (newline) ; 4
(display (coeficiente-de p 0)) (newline) ; 7
;; (coeficiente-de p 3)  ; Error: El polinomio no tiene termino con ese exponente
 
;; eliminar-termino
(display (polinomio->lista (eliminar-termino p 2))) (newline) ; (x (4 5) (7 0))
(display (polinomio->lista (eliminar-termino p 5))) (newline) ; (x (-3/2 2) (7 0))
(display (polinomio->lista (eliminar-termino p 0))) (newline) ; (x (4 5) (-3/2 2))
;; (eliminar-termino p 3)  ; Error: El polinomio no tiene termino con ese exponente
 
;; sumar
(display (polinomio->lista (sumar p q))) (newline)                      ; (x (-1 2) (2 1) (7 0))
(display (polinomio->lista (sumar p (polinomio-cero 'x)))) (newline)    ; (x (4 5) (-3/2 2) (7 0))
(display (polinomio->lista (sumar p (eliminar-termino p 5)))) (newline) ; (x (4 5) (-3 2) (14 0))
;; (sumar p (polinomio-cero 'y))  ; Error: Los polinomios deben estar en la misma variable