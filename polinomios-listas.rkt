#lang eopl

;Autores: Maria Fernanda Betancourt Montoya 2459510, Oliver De Jesus Arboleda Baez 245984, Kevin Andres Rosero Romo 2459554

;; Taller 1 - Polinomios dispersos.
;; Parte 1: representacion basada en listas.
;;
;; Gramatica:
;; <polinomio>    ::= <variable> <terminos>          poli(var, terms)
;; <variable>     ::= <symbol>                       nombre-var(s)
;; <terminos>     ::= '()                            sin-terminos()
;;                ::= <termino> <terminos>           mas-terminos(term, resto)
;; <termino>      ::= <coeficiente> <exponente>      termino(coef, expo)
;; <coeficiente>  ::= <int>                          coef-ent(n)
;;                ::= <int> "/" <int>                coef-rac(num, den)
;; <exponente>    ::= <int>                          expo-nat(k)
;;
;; Cada variante es una lista cuyo primer elemento es una etiqueta.



;; Constructores
;;-----------------------------------------------------------------------------------------

;; nombre-var : symbol -> variable
;; Crea una variable con el simbolo dado.
(define nombre-var
  (lambda (s)
    (list 'nombre-var s)))


;; poli : variable x terminos -> polinomio
;; Crea un polinomio a partir de una variable y sus terminos.
(define poli
  (lambda (var terms)
    (list 'poli var terms)))


;; sin-terminos : -> terminos
;; Crea la lista vacia de terminos.
(define sin-terminos
  (lambda ()
    (list 'sin-terminos)))


;; mas-terminos : termino x terminos -> terminos
;; Agrega un termino al inicio de una lista de terminos.
(define mas-terminos
  (lambda (term resto)
    (list 'mas-terminos term resto)))


;; termino : coeficiente x exponente -> termino
;; Crea un termino con su coeficiente y su exponente.
(define termino
  (lambda (coef expo)
    (list 'termino coef expo)))


;; coef-ent : integer -> coeficiente
;; Crea un coeficiente entero.
(define coef-ent
  (lambda (n)
    (list 'coef-ent n)))


;; coef-rac : integer x integer -> coeficiente
;; Crea un coeficiente racional con numerador y denominador.
(define coef-rac
  (lambda (num den)
    (list 'coef-rac num den)))


;; expo-nat : integer -> exponente
;; Crea un exponente natural.
(define expo-nat
  (lambda (k)
    (list 'expo-nat k)))



;; Predicados
;;-----------------------------------------------------------------------------------------

;; poli? : cualquier -> boolean
;; Indica si el valor es un polinomio.
(define poli?
  (lambda (x)
    (and (pair? x)
         (eqv? (car x) 'poli))))


;; nombre-var? : cualquier -> boolean
;; Indica si el valor es una variable.
(define nombre-var?
  (lambda (x)
    (and (pair? x)
         (eqv? (car x) 'nombre-var))))


;; sin-terminos? : cualquier -> boolean
;; Indica si el valor es la lista vacia de terminos.
(define sin-terminos?
  (lambda (x)
    (and (pair? x)
         (eqv? (car x) 'sin-terminos))))


;; mas-terminos? : cualquier -> boolean
;; Indica si el valor es una lista de terminos no vacia.
(define mas-terminos?
  (lambda (x)
    (and (pair? x)
         (eqv? (car x) 'mas-terminos))))


;; termino? : cualquier -> boolean
;; Indica si el valor es un termino.
(define termino?
  (lambda (x)
    (and (pair? x)
         (eqv? (car x) 'termino))))


;; coef-ent? : cualquier -> boolean
;; Indica si el valor es un coeficiente entero.
(define coef-ent?
  (lambda (x)
    (and (pair? x)
         (eqv? (car x) 'coef-ent))))


;; coef-rac? : cualquier -> boolean
;; Indica si el valor es un coeficiente racional.
(define coef-rac?
  (lambda (x)
    (and (pair? x)
         (eqv? (car x) 'coef-rac))))


;; expo-nat? : cualquier -> boolean
;; Indica si el valor es un exponente natural.
(define expo-nat?
  (lambda (x)
    (and (pair? x)
         (eqv? (car x) 'expo-nat))))

;; Extractores
;;-----------------------------------------------------------------------------------------

;; poli->var : polinomio -> variable
;; Retorna la variable del polinomio.
(define poli->var
  (lambda (p)
    (cadr p)))


;; poli->terms : polinomio -> terminos
;; Retorna los terminos del polinomio.
(define poli->terms
  (lambda (p)
    (caddr p)))


;; nombre-var->s : variable -> symbol
;; Retorna el simbolo de la variable.
(define nombre-var->s
  (lambda (v)
    (cadr v)))


;; mas-terminos->term : terminos -> termino
;; Retorna el primer termino de la lista.
(define mas-terminos->term
  (lambda (ts)
    (cadr ts)))


;; mas-terminos->resto : terminos -> terminos
;; Retorna el resto de la lista de terminos.
(define mas-terminos->resto
  (lambda (ts)
    (caddr ts)))


;; termino->coef : termino -> coeficiente
;; Retorna el coeficiente del termino.
(define termino->coef
  (lambda (t)
    (cadr t)))


;; termino->expo : termino -> exponente
;; Retorna el exponente del termino.
(define termino->expo
  (lambda (t)
    (caddr t)))


;; coef-ent->n : coeficiente -> integer
;; Retorna el entero del coeficiente entero.
(define coef-ent->n
  (lambda (c)
    (cadr c)))


;; coef-rac->num : coeficiente -> integer
;; Retorna el numerador del coeficiente racional.
(define coef-rac->num
  (lambda (c)
    (cadr c)))


;; coef-rac->den : coeficiente -> integer
;; Retorna el denominador del coeficiente racional.
(define coef-rac->den
  (lambda (c)
    (caddr c)))


;; expo-nat->k : exponente -> integer
;; Retorna el valor entero del exponente.
(define expo-nat->k
  (lambda (e)
    (cadr e)))


;; Funciones Auxiliares
;;-----------------------------------------------------------------------------------------

;; coef-concreto : coeficiente -> numero
;; Convierte un coeficiente del TAD en un numero exacto de Racket.
(define coef-concreto
  (lambda (c)
    (cond
      ((coef-ent? c)
       (coef-ent->n c))

      ((coef-rac? c)
       (/ (coef-rac->num c)
          (coef-rac->den c))))))


;; coef-interno : numero -> coeficiente
;; Convierte un numero exacto de Racket en un coeficiente del TAD.
(define coef-interno
  (lambda (c)
    (if (integer? c)
        (coef-ent c)
        (coef-rac
         (numerator c)
         (denominator c)))))


;; Polinomio 0
;;-----------------------------------------------------------------------------------------

;; polinomio-cero : symbol -> polinomio
;; Retorna el polinomio nulo (sin terminos) en la variable dada.
(define polinomio-cero
  (lambda (variable)
    (poli
     (nombre-var variable)
     (sin-terminos))))



;; Insertar Termino
;;-----------------------------------------------------------------------------------------

;; insertar-termino : polinomio x numero x numero -> polinomio
;; Inserta un termino conservando el orden estricto decreciente.
;; Si el exponente ya existe, suma los coeficientes; si la suma es
;; cero, el termino desaparece. Si el coeficiente es cero, el
;; polinomio no cambia.
;; Error si el coeficiente no es exacto o el exponente no es un
;; entero no negativo.
(define insertar-termino
  (lambda (polinomio coeficiente exponente)
    (cond
      ((not (and (number? coeficiente) (exact? coeficiente)))
       (eopl:error
        'insertar-termino
        "El coeficiente debe ser un numero exacto"))

      ((not (and (integer? exponente)
                 (exact? exponente)
                 (>= exponente 0)))
       (eopl:error
        'insertar-termino
        "El exponente debe ser un entero no negativo"))

      ((= coeficiente 0)
       polinomio)

      (else
       (poli
        (poli->var polinomio)
        (insertar-en-lista
         (poli->terms polinomio)
         coeficiente
         exponente))))))


;; insertar-en-lista : terminos x numero x numero -> terminos
;; Inserta un termino (coeficiente distinto de cero) en la posicion
;; que le corresponde, recorriendo la lista una sola vez.
(define insertar-en-lista
  (lambda (terminos coeficiente exponente)
    (if (sin-terminos? terminos)

        (mas-terminos
         (termino
          (coef-interno coeficiente)
          (expo-nat exponente))
         (sin-terminos))

        (let ((primer-termino
               (mas-terminos->term terminos)))

          (let ((expo-actual
                 (expo-nat->k
                  (termino->expo primer-termino))))

            (cond

              ;; El exponente ya existe: se suman los coeficientes.
              ((= exponente expo-actual)
               (let ((nuevo-coef
                      (+ coeficiente
                         (coef-concreto
                          (termino->coef primer-termino)))))
                 (if (= nuevo-coef 0)
                     (mas-terminos->resto terminos)
                     (mas-terminos
                      (termino
                       (coef-interno nuevo-coef)
                       (expo-nat expo-actual))
                      (mas-terminos->resto terminos)))))

              ;; El nuevo exponente va antes del actual.
              ((> exponente expo-actual)
               (mas-terminos
                (termino
                 (coef-interno coeficiente)
                 (expo-nat exponente))
                terminos))

              ;; El nuevo exponente va despues: se sigue buscando.
              (else
               (mas-terminos
                primer-termino
                (insertar-en-lista
                 (mas-terminos->resto terminos)
                 coeficiente
                 exponente)))))))))


;; Coeficiente
;;-----------------------------------------------------------------------------------------

;; coeficiente-de : polinomio x numero -> numero
;; Retorna el coeficiente concreto del termino con ese exponente.
;; Error si el polinomio no tiene termino con ese exponente.
(define coeficiente-de
  (lambda (polinomio exponente)
    (buscar-coeficiente
     (poli->terms polinomio)
     exponente)))


;; buscar-coeficiente : terminos x numero -> numero
;; Busca el coeficiente concreto de un exponente en la lista de
;; terminos, recorriendola una sola vez.
(define buscar-coeficiente
  (lambda (terminos exponente)
    (if (sin-terminos? terminos)

        (eopl:error
         'coeficiente-de
         "El polinomio no tiene termino con ese exponente")

        (let ((primer-termino
               (mas-terminos->term terminos)))

          (let ((expo-actual
                 (expo-nat->k
                  (termino->expo primer-termino))))

            (cond

              ((= exponente expo-actual)
               (coef-concreto
                (termino->coef primer-termino)))

              ((> exponente expo-actual)
               (eopl:error
                'coeficiente-de
                "El polinomio no tiene termino con ese exponente"))

              (else
               (buscar-coeficiente
                (mas-terminos->resto terminos)
                exponente))))))))



;; Eliminar Termino
;;-----------------------------------------------------------------------------------------

;; eliminar-termino : polinomio x numero -> polinomio
;; Retorna un polinomio nuevo sin el termino con ese exponente.
;; Error si el polinomio no tiene termino con ese exponente.
(define eliminar-termino
  (lambda (polinomio exponente)
    (poli
     (poli->var polinomio)
     (eliminar-de-lista
      (poli->terms polinomio)
      exponente))))


;; eliminar-de-lista : terminos x numero -> terminos
;; Elimina de la lista el termino con ese exponente, recorriendola
;; una sola vez.
(define eliminar-de-lista
  (lambda (terminos exponente)
    (if (sin-terminos? terminos)

        (eopl:error
         'eliminar-termino
         "El polinomio no tiene termino con ese exponente")

        (let ((primer-termino
               (mas-terminos->term terminos)))

          (let ((expo-actual
                 (expo-nat->k
                  (termino->expo primer-termino))))

            (cond

              ((= exponente expo-actual)
               (mas-terminos->resto terminos))

              ((> exponente expo-actual)
               (eopl:error
                'eliminar-termino
                "El polinomio no tiene termino con ese exponente"))

              (else
               (mas-terminos
                primer-termino
                (eliminar-de-lista
                 (mas-terminos->resto terminos)
                 exponente)))))))))



;; Ejemplos De Contruccion De Polinomios
;;-----------------------------------------------------------------------------------------

;; 1. Polinomio nulo en x: 0
(define ejemplo-construccion-1
  (poli (nombre-var 'x) (sin-terminos)))

;; 2. Un solo termino con coeficiente entero: 4x^5
(define ejemplo-construccion-2
  (poli
   (nombre-var 'x)
   (mas-terminos
    (termino (coef-ent 4) (expo-nat 5))
    (sin-terminos))))

;; 3. Dos terminos, uno racional: -3/2 y^2 + 1
(define ejemplo-construccion-3
  (poli
   (nombre-var 'y)
   (mas-terminos
    (termino (coef-rac -3 2) (expo-nat 2))
    (mas-terminos
     (termino (coef-ent 1) (expo-nat 0))
     (sin-terminos)))))

;; 4. Tres terminos con termino independiente: 4x^5 - 3/2x^2 + 7
(define ejemplo-construccion-4
  (poli
   (nombre-var 'x)
   (mas-terminos
    (termino (coef-ent 4) (expo-nat 5))
    (mas-terminos
     (termino (coef-rac -3 2) (expo-nat 2))
     (mas-terminos
      (termino (coef-ent 7) (expo-nat 0))
      (sin-terminos))))))

;; 5. Tres terminos con coeficiente negativo: -x^3 + 1/2x - 9
(define ejemplo-construccion-5
  (poli
   (nombre-var 'z)
   (mas-terminos
    (termino (coef-ent -1) (expo-nat 3))
    (mas-terminos
     (termino (coef-rac 1 2) (expo-nat 1))
     (mas-terminos
      (termino (coef-ent -9) (expo-nat 0))
      (sin-terminos))))))



;; Ejemplos De Uso De Observadores
;;-----------------------------------------------------------------------------------------

;; Predicados
(define ejemplo-obs-1 (poli? ejemplo-construccion-4))                       ; #t
(define ejemplo-obs-2 (sin-terminos? (poli->terms ejemplo-construccion-1))) ; #t
(define ejemplo-obs-3 (mas-terminos? (poli->terms ejemplo-construccion-4))) ; #t
(define ejemplo-obs-4 (coef-rac? (termino->coef
                                  (mas-terminos->term
                                   (mas-terminos->resto
                                    (poli->terms ejemplo-construccion-4)))))) ; #t
(define ejemplo-obs-5 (coef-ent? (termino->coef
                                  (mas-terminos->term
                                   (poli->terms ejemplo-construccion-4)))))  ; #t

;; Extractores
(define ejemplo-obs-6 (nombre-var->s (poli->var ejemplo-construccion-4)))   ; x
(define ejemplo-obs-7 (expo-nat->k (termino->expo
                                    (mas-terminos->term
                                     (poli->terms ejemplo-construccion-4))))) ; 5
(define ejemplo-obs-8 (coef-ent->n (termino->coef
                                    (mas-terminos->term
                                     (poli->terms ejemplo-construccion-4))))) ; 4
(define ejemplo-obs-9 (coef-rac->num (coef-rac -3 2)))                      ; -3
(define ejemplo-obs-10 (coef-rac->den (coef-rac -3 2)))                     ; 2


;; Ejemplos De Las Funciones De La Interfaz
;;-----------------------------------------------------------------------------------------

;; p = 4x^5 - 3/2x^2 + 7
(define p
  (insertar-termino
   (insertar-termino
    (insertar-termino (polinomio-cero 'x) 7 0)
    -3/2 2)
   4 5))

;; ---- polinomio-cero ----
(define ejemplo-cero-1 (polinomio-cero 'x))  ; 0 en x
(define ejemplo-cero-2 (polinomio-cero 'y))  ; 0 en y
(define ejemplo-cero-3 (polinomio-cero 'z))  ; 0 en z
(define ejemplo-cero-4 (polinomio-cero 't))  ; 0 en t
(define ejemplo-cero-5 (polinomio-cero 'w))  ; 0 en w

;; ---- insertar-termino ----
;; Exponente nuevo en un polinomio nulo: 7
(define ejemplo-insertar-1 (insertar-termino (polinomio-cero 'x) 7 0))
;; Exponente existente, la suma no es cero: 4x^5 - 1/2x^2 + 7
(define ejemplo-insertar-2 (insertar-termino p 1 2))
;; Exponente existente, la suma es cero: 4x^5 + 7
(define ejemplo-insertar-3 (insertar-termino p 3/2 2))
;; Exponente nuevo al inicio: 3x^8 + 4x^5 - 3/2x^2 + 7
(define ejemplo-insertar-4 (insertar-termino p 3 8))
;; Exponente nuevo en el medio: 4x^5 + 2x^3 - 3/2x^2 + 7
(define ejemplo-insertar-5 (insertar-termino p 2 3))
;; Coeficiente cero: el polinomio no cambia (4x^5 - 3/2x^2 + 7)
(define ejemplo-insertar-6 (insertar-termino p 0 3))
;; Errores:
;; (insertar-termino p 5 -1)
;;   -> error: "El exponente debe ser un entero no negativo"
;; (insertar-termino p 1 1.5)
;;   -> error: "El exponente debe ser un entero no negativo"
;; (insertar-termino p 0.5 2)
;;   -> error: "El coeficiente debe ser un numero exacto"

;; ---- coeficiente-de ----
(define ejemplo-coef-de-1 (coeficiente-de p 2))   ; -3/2
(define ejemplo-coef-de-2 (coeficiente-de p 5))   ; 4
(define ejemplo-coef-de-3 (coeficiente-de p 0))   ; 7
(define ejemplo-coef-de-4
  (coeficiente-de (insertar-termino p 1 2) 2))    ; -1/2
(define ejemplo-coef-de-5
  (coeficiente-de (insertar-termino p 2 3) 3))    ; 2
;; Errores:
;; (coeficiente-de p 3)
;;   -> error: "El polinomio no tiene termino con ese exponente"
;; (coeficiente-de p 9)
;;   -> error: "El polinomio no tiene termino con ese exponente"
;; (coeficiente-de (polinomio-cero 'x) 0)
;;   -> error: "El polinomio no tiene termino con ese exponente"

;; ---- eliminar-termino ----
(define ejemplo-eliminar-1 (eliminar-termino p 2))  ; 4x^5 + 7
(define ejemplo-eliminar-2 (eliminar-termino p 5))  ; -3/2x^2 + 7
(define ejemplo-eliminar-3 (eliminar-termino p 0))  ; 4x^5 - 3/2x^2
(define ejemplo-eliminar-4
  (eliminar-termino
   (insertar-termino (polinomio-cero 'x) 3 1)
   1))                                              ; 0 (polinomio nulo)
(define ejemplo-eliminar-5
  (eliminar-termino (insertar-termino p 2 3) 3))    ; 4x^5 - 3/2x^2 + 7
;; Errores:
;; (eliminar-termino p 3)
;;   -> error: "El polinomio no tiene termino con ese exponente"
;; (eliminar-termino (polinomio-cero 'x) 0)
;;   -> error: "El polinomio no tiene termino con ese exponente"



;; Provide
;;-----------------------------------------------------------------------------------------

(provide
 polinomio-cero
 insertar-termino
 coeficiente-de
 eliminar-termino)