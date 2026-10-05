#lang eopl
;Autores: Maria Fernanda Betancourt Montoya 2459510, Oliver De Jesus Arboleda Baez 2459684, Kevin Andres Rosero Romo 2459554

;; Taller 1 — Polinomios dispersos.
;; Parte 4: la misma batería de pruebas sobre las tres representaciones.

(require rackunit)
(require (prefix-in listas: "polinomios-listas.rkt"))
(require (prefix-in procs:  "polinomios-procedimientos.rkt"))
(require (prefix-in dt:     "polinomios-datatypes.rkt"))

;; Una prueba tiene esta forma; la batería completa está descrita en la
;; Parte 4 del enunciado.
;;
;; (check-equal?
;;   (listas:coeficiente-de
;;     (listas:insertar-termino (listas:polinomio-cero 'x) 7 0) 0)
;;   7)



;; REPRESENTACION CON LISTAS


;; Casos funcionales de las cuatro operaciones

(check-equal?
 (listas:coeficiente-de
  (listas:insertar-termino (listas:polinomio-cero 'x) 7 0)
  0)
 7)

(define p-listas
  (listas:insertar-termino
   (listas:insertar-termino
    (listas:insertar-termino
     (listas:polinomio-cero 'x)
     7
     0)
    -3/2
    2)
   4
   5))

(check-equal?
 (listas:coeficiente-de p-listas 5)
 4)

(check-equal?
 (listas:coeficiente-de p-listas 2)
 -3/2)

(check-equal?
 (listas:coeficiente-de p-listas 0)
 7)

(check-equal?
 (listas:coeficiente-de
  (listas:eliminar-termino p-listas 2)
  0)
 7)


;; Polinomio nulo como caso base

(define listas-nulo
  (listas:polinomio-cero 'x))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (listas:coeficiente-de listas-nulo 0)))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (listas:eliminar-termino listas-nulo 0)))


;; Insercion que cancela un termino existente

(define listas-cancelado
  (listas:insertar-termino p-listas 3/2 2))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (listas:coeficiente-de listas-cancelado 2)))


;; Insercion con coeficiente cero

(check-equal?
 (listas:coeficiente-de
  (listas:insertar-termino p-listas 0 2)
  2)
 -3/2)


;; Tres casos de error

;; Exponente negativo

(check-exn
 (lambda (e) #t)
 (lambda ()
   (listas:insertar-termino p-listas 5 -1)))

;; Exponente no registrado en coeficiente-de

(check-exn
 (lambda (e) #t)
 (lambda ()
   (listas:coeficiente-de p-listas 3)))

;; Exponente no registrado en eliminar-termino

(check-exn
 (lambda (e) #t)
 (lambda ()
   (listas:eliminar-termino p-listas 3)))



;; REPRESENTACION CON PROCEDIMIENTOS


;; Casos funcionales de las cuatro operaciones

(check-equal?
 (procs:coeficiente-de
  (procs:insertar-termino (procs:polinomio-cero 'x) 7 0)
  0)
 7)

(define p-procs
  (procs:insertar-termino
   (procs:insertar-termino
    (procs:insertar-termino
     (procs:polinomio-cero 'x)
     7
     0)
    -3/2
    2)
   4
   5))

(check-equal?
 (procs:coeficiente-de p-procs 5)
 4)

(check-equal?
 (procs:coeficiente-de p-procs 2)
 -3/2)

(check-equal?
 (procs:coeficiente-de p-procs 0)
 7)

(check-equal?
 (procs:coeficiente-de
  (procs:eliminar-termino p-procs 2)
  0)
 7)


;; Polinomio nulo como caso base

(define procs-nulo
  (procs:polinomio-cero 'x))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (procs:coeficiente-de procs-nulo 0)))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (procs:eliminar-termino procs-nulo 0)))


;; Insercion que cancela un termino existente

(define procs-cancelado
  (procs:insertar-termino p-procs 3/2 2))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (procs:coeficiente-de procs-cancelado 2)))


;; Insercion con coeficiente cero

(check-equal?
 (procs:coeficiente-de
  (procs:insertar-termino p-procs 0 2)
  2)
 -3/2)


;; Tres casos de error

;; Exponente negativo

(check-exn
 (lambda (e) #t)
 (lambda ()
   (procs:insertar-termino p-procs 5 -1)))

;; Exponente no registrado en coeficiente-de

(check-exn
 (lambda (e) #t)
 (lambda ()
   (procs:coeficiente-de p-procs 3)))

;; Exponente no registrado en eliminar-termino

(check-exn
 (lambda (e) #t)
 (lambda ()
   (procs:eliminar-termino p-procs 3)))



;; REPRESENTACION CON DATATYPES


;; Casos funcionales de las cuatro operaciones

(check-equal?
 (dt:coeficiente-de
  (dt:insertar-termino (dt:polinomio-cero 'x) 7 0)
  0)
 7)

(define p-dt
  (dt:insertar-termino
   (dt:insertar-termino
    (dt:insertar-termino
     (dt:polinomio-cero 'x)
     7
     0)
    -3/2
    2)
   4
   5))

(check-equal?
 (dt:coeficiente-de p-dt 5)
 4)

(check-equal?
 (dt:coeficiente-de p-dt 2)
 -3/2)

(check-equal?
 (dt:coeficiente-de p-dt 0)
 7)

(check-equal?
 (dt:coeficiente-de
  (dt:eliminar-termino p-dt 2)
  0)
 7)


;; Polinomio nulo como caso base

(define dt-nulo
  (dt:polinomio-cero 'x))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (dt:coeficiente-de dt-nulo 0)))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (dt:eliminar-termino dt-nulo 0)))


;; Insercion que cancela un termino existente

(define dt-cancelado
  (dt:insertar-termino p-dt 3/2 2))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (dt:coeficiente-de dt-cancelado 2)))


;; Insercion con coeficiente cero

(check-equal?
 (dt:coeficiente-de
  (dt:insertar-termino p-dt 0 2)
  2)
 -3/2)


;; Tres casos de error

;; Exponente negativo

(check-exn
 (lambda (e) #t)
 (lambda ()
   (dt:insertar-termino p-dt 5 -1)))

;; Exponente no registrado en coeficiente-de

(check-exn
 (lambda (e) #t)
 (lambda ()
   (dt:coeficiente-de p-dt 3)))

;; Exponente no registrado en eliminar-termino

(check-exn
 (lambda (e) #t)
 (lambda ()
   (dt:eliminar-termino p-dt 3)))


;; Suma de dos polinomios que se cancelan por completo

(define dt-cancelacion-1
  (dt:insertar-termino
   (dt:insertar-termino
    (dt:polinomio-cero 'x)
    4
    5)
   -3/2
   2))

(define dt-cancelacion-2
  (dt:insertar-termino
   (dt:insertar-termino
    (dt:polinomio-cero 'x)
    -4
    5)
   3/2
   2))

(define dt-resultado-cancelacion
  (dt:sumar dt-cancelacion-1 dt-cancelacion-2))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (dt:coeficiente-de dt-resultado-cancelacion 5)))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (dt:coeficiente-de dt-resultado-cancelacion 2)))


;; Suma de polinomios en variables distintas

(define dt-y
  (dt:polinomio-cero 'y))

(check-exn
 (lambda (e) #t)
 (lambda ()
   (dt:sumar p-dt dt-y)))