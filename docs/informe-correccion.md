# Informe de corrección — Taller 1: polinomios dispersos

**Curso:** Fundamentos de Interpretación y Compilación de Lenguajes
de Programación — Universidad del Valle, Sede Tuluá

**Integrantes del grupo:**

| Nombre | Código | Correo institucional |
|--------|--------|----------------------|
| Maria Fernanda Betancourt Montoya | 2459510 | maria.fernanda.betancourt@correounivalle.edu.co |
| Oliver De Jesus Arboleda Baez | 2459684 | oliver.arboleda@correounivalle.edu.co |
| Kevin Andres Rosero Romo | 2459554 | rosero.kevin@correounivalle.edu.co |

---

## 1. Marco formal

### 1.1 Corrección de programas recursivos

Sea $f : A \to B$ una función y $A$ un conjunto definido
recursivamente. Sea $P_f$ un programa recursivo en Racket que pretende
calcular $f$. Decimos que $P_f$ es correcto con respecto a su
especificación si se cumple:

$$
\forall a \in A \,:\, P_f(a) = f(a)
$$

La estrategia de demostración es **inducción estructural** sobre $A$.
Aquí $A$ es el conjunto de listas de términos que genera la gramática:

- **Caso base:** $a = \text{sin-terminos}()$, y se verifica
  $P_f(a) = f(a)$ directamente.
- **Caso inductivo:** $a = \text{mas-terminos}(t, r)$. Se asume la
  **hipótesis de inducción** $P_f(r) = f(r)$ sobre el resto de la
  lista y se demuestra $P_f(a) = f(a)$.

Las funciones auxiliares recursivas de las tres representaciones
(`buscar-coeficiente`, `eliminar-de-lista`, `insertar-en-lista` y sus
equivalentes con datatypes) están escritas con **recursión estructural
sobre la lista de términos**, sin acumuladores. Por eso todas las
demostraciones de este informe usan hipótesis de inducción y no
invariantes de acumulador.

**Notación.** Escribimos $\varepsilon$ para `sin-terminos()` y
$t :: r$ para `mas-terminos(t, r)`. Un término es un par
$t = (c, e)$ con coeficiente concreto $c$ (el número exacto de Racket
que representa `coef-ent` o `coef-rac`) y exponente $e$. Para una lista
$L$ escribimos $\mathrm{exps}(L)$ para el conjunto de sus exponentes y
$|L|$ para su longitud.

### 1.2 El invariante de la representación

Las cuatro condiciones del enunciado se enuncian como una única
propiedad sobre polinomios. Sea $p$ un polinomio con términos
$t_1, t_2, \ldots, t_n$, donde $t_i = (c_i, e_i)$:

$$
\mathrm{Inv}(p) \equiv
\underbrace{\forall i < n : e_i > e_{i+1}}_{\text{orden estricto}}
\ \land\
\underbrace{\forall i : c_i \neq 0}_{\text{sin ceros}}
\ \land\
\underbrace{\forall i : e_i \in \mathbb{N}}_{\text{exponentes naturales}}
\ \land\
\underbrace{\forall i : \mathrm{red}(c_i)}_{\text{racionales reducidos}}
$$

donde $\mathrm{red}\left(\frac{a}{b}\right)$ abrevia
$b > 0 \,\land\, \mathrm{mcd}(|a|, b) = 1$, y un coeficiente entero se
toma como el racional de denominador $1$.

Como la variable no interviene en ninguna de las cuatro condiciones,
$\mathrm{Inv}(p)$ depende solo de la lista de términos de $p$. Por eso
escribimos también $\mathrm{Inv}(L)$ para una lista de términos $L$, y
$\mathrm{Ord}(L)$ para la primera condición (orden estricto).

### 1.3 Hechos sobre el invariante que usaremos

Sea $L = (c_1, e_1) :: r$ con $\mathrm{Inv}(L)$.

- **(H1) Cola.** $\mathrm{Inv}(r)$ vale, porque $r$ es una sublista de $L$ y
  cada una de las cuatro condiciones se hereda a las sublistas.
- **(H2) Cabeza mayor.** $e_1 > e'$ para todo $e' \in \mathrm{exps}(r)$.
  Se sigue de la condición de orden estricto por transitividad.
- **(H3) Unicidad.** En $L$ no hay dos términos con el mismo exponente,
  porque los exponentes son estrictamente decrecientes.
- **(H4) Subsecuencias.** Toda subsecuencia de $L$ (en el mismo orden)
  cumple $\mathrm{Inv}$.

### 1.4 Traducción entre representación concreta y abstracta

Sea $\mathrm{val}$ la función que lleva un coeficiente del TAD a su número
concreto: $\mathrm{val}(\text{coef-ent}(n)) = n$ y
$\mathrm{val}(\text{coef-rac}(a, b)) = a/b$. Las funciones de la interfaz
construyen coeficientes con `coef-interno` (listas y procedimientos) o
`concreto->coef` (datatypes), que hacen:

$$
\text{coef-interno}(c) =
\begin{cases}
\text{coef-ent}(c) & \text{si } c \in \mathbb{Z} \\
\text{coef-rac}(\mathrm{numerator}(c), \mathrm{denominator}(c)) & \text{en otro caso}
\end{cases}
$$

**(T1)** Para todo número exacto racional $c$ se cumple
$\mathrm{val}(\text{coef-interno}(c)) = c$. Si $c$ es entero es inmediato.
Si no, $\mathrm{numerator}(c)/\mathrm{denominator}(c) = c$.

**(T2)** El coeficiente construido por `coef-interno` cumple
$\mathrm{red}$: Racket guarda los racionales exactos en forma reducida y
con denominador positivo, así que $\mathrm{numerator}(c)$ y
$\mathrm{denominator}(c)$ ya cumplen $b > 0$ y $\mathrm{mcd}(|a|, b) = 1$.

---

## 2. Funciones analizadas

### 2.1 Corrección de `coeficiente-de`

**Especificación.**

- **Tipo:** `coeficiente-de : polinomio × exponente -> coeficiente`
- **Pre-condición:** $\mathrm{Inv}(p)$ y $e \in \mathbb{N}$ (entero exacto
  mayor o igual que cero).
- **Post-condición:** $\text{Post}(p, e, r) \equiv (r, e) \in \mathrm{terms}(p)$
  cuando el exponente $e$ aparece en $p$; y la función levanta
  `eopl:error` cuando no aparece.

Si el exponente aparece, aparece en un único término, así que
$r$ queda determinado.

**Código.**

*Representación con listas:*

```racket
(define coeficiente-de
  (lambda (polinomio exponente)
    (buscar-coeficiente
     (poli->terms polinomio)
     exponente)))

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
```

*Representación con datatypes:*

```racket
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

(define coeficiente-de
  (lambda (pol expo)
    (if (exponente-valido? expo)
        (cases polinomio pol
          (poli (var terms) (buscar-coef terms expo)))
        (eopl:error 'coeficiente-de "El exponente debe ser un entero no negativo"))))
```

*Representación con procedimientos:* es exactamente el mismo código que
con listas. Solo cambian los constructores, predicados y extractores.

Llamamos $B(L, e)$ a la función auxiliar recursiva (`buscar-coeficiente`
en listas y procedimientos, `buscar-coef` en datatypes). Las dos hacen lo
mismo: el único cambio es que una usa predicados y extractores y la otra
usa `cases`. Para el término de cabeza $(c_1, e_1)$ comparan el exponente
buscado $e$ con $e_1$.

**Lema 1.** Para toda lista $L$ con $\mathrm{Ord}(L)$ y todo
$e \in \mathbb{N}$:

- **(a)** si existe $c$ con $(c, e) \in L$, entonces $B(L, e) = c$;
- **(b)** si no existe tal $c$, entonces $B(L, e)$ levanta `eopl:error`.

**Demostración.** Por inducción estructural sobre $L$.

- **Caso base** ($L = \varepsilon$): la lista no tiene términos, así que
  estamos en el caso (b). El programa evalúa `sin-terminos?` (o el
  `cases` cae en la variante `sin-terminos`) y levanta
  `eopl:error`, que es lo que pide (b). El caso (a) es vacío.

- **Caso inductivo** ($L = (c_1, e_1) :: r$): por (H1), $\mathrm{Ord}(r)$,
  así que la hipótesis de inducción (HI) vale para $r$. Hay tres
  subcasos, según la comparación entre $e$ y $e_1$:

  1. **$e = e_1$.** El término $(c_1, e)$ está en $L$ y, por (H3), es el
     único con exponente $e$. El programa toma la rama
     `(= exponente expo-actual)` y retorna `coef-concreto` (o
     `coef->concreto`) del coeficiente de la cabeza, que es $c_1$ por
     la definición de $\mathrm{val}$. Se cumple (a). El caso (b) es
     vacío porque $e$ sí aparece.

  2. **$e > e_1$.** Por (H2), todo exponente de $r$ es menor que $e_1$,
     y $e_1 < e$, así que $e \notin \mathrm{exps}(L)$. Estamos en (b).
     El programa toma la rama de corte y levanta `eopl:error` sin
     recorrer $r$, que es lo que pide (b). Este es el uso del orden
     estricto: como los exponentes decrecen, en cuanto la cabeza ya
     es menor que $e$, los que siguen también lo son y la búsqueda
     puede cortarse. El caso (a) es vacío.

  3. **$e < e_1$.** Como $e \neq e_1$, un término con exponente $e$ está
     en $L$ si y solo si está en $r$. El programa hace la llamada
     $B(r, e)$ y retorna lo que ella retorna. Por la HI, si $e$ aparece
     en $r$ con coeficiente $c$, entonces $B(r, e) = c$, y esto da (a)
     para $L$; si no aparece, $B(r, e)$ levanta error, y esto da (b)
     para $L$. $\blacksquare$

- **Levantamiento del error.** El lema da las dos direcciones. Si
  $e$ no aparece, se levanta error por (b). Si $e$ aparece, el lema (a)
  dice que se retorna $c$, y no se levanta ningún error: las
  operaciones usadas (extractores y `coef-concreto`) no fallan sobre
  datos bien formados. Por lo tanto el error se levanta **si y solo si**
  el exponente no está.

**Del lema a la función.** Por la pre-condición, $\mathrm{Inv}(p)$ implica
$\mathrm{Ord}(\mathrm{terms}(p))$. Entonces
$\text{coeficiente-de}(p, e) = B(\mathrm{terms}(p), e)$ cumple $\text{Post}$
por el Lema 1, y por (T1) el coeficiente retornado es el número concreto
$c$, no su representación interna. En la versión con datatypes, un
exponente que no es entero no negativo levanta error en la verificación
inicial. En la versión con listas y procedimientos no existe esa
verificación, pero de todas formas se levanta error porque ningún
término tiene ese exponente, así que (b) cubre ese caso.

**Terminación.** Sea $\mu(L) = |L| \in \mathbb{N}$. En cada llamada
recursiva se pasa de $L = t :: r$ a $r$, con $\mu(r) = \mu(L) - 1 <
\mu(L)$. La medida decrece estrictamente y tiene cota inferior $0$. Cuando
$\mu(L) = 0$ la función no hace llamada recursiva. Por lo tanto no hay
cadenas infinitas de llamadas y la función termina en a lo sumo $|L| + 1$
llamadas, recorriendo la lista una sola vez.

---

### 2.2 Corrección de `eliminar-termino`

**Especificación.**

- **Tipo:** `eliminar-termino : polinomio × exponente -> polinomio`
- **Pre-condición:** $\mathrm{Inv}(p)$ y $e \in \mathbb{N}$.
- **Post-condición:** el resultado contiene **exactamente** los
  términos de $p$ menos el de exponente $e$. Formalmente, si
  $(c, e) \in \mathrm{terms}(p)$:
  $$
  \mathrm{terms}(r) = \mathrm{terms}(p) \setminus \{(c, e)\}
  $$
  y la función levanta `eopl:error` si $e$ no aparece en $p$. Además
  $r$ queda en la misma variable que $p$ y cumple $\mathrm{Inv}(r)$.

**Código.**

*Representación con listas:*

```racket
(define eliminar-termino
  (lambda (polinomio exponente)
    (poli
     (poli->var polinomio)
     (eliminar-de-lista
      (poli->terms polinomio)
      exponente))))

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
```

*Representación con datatypes:*

```racket
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

(define eliminar-termino
  (lambda (pol expo)
    (if (exponente-valido? expo)
        (cases polinomio pol
          (poli (var terms) (poli var (quitar-en terms expo))))
        (eopl:error 'eliminar-termino "El exponente tiene que ser un entero no negativo"))))
```

*Representación con procedimientos:* el mismo código que con listas.

Llamamos $D(L, e)$ a la función auxiliar (`eliminar-de-lista` o
`quitar-en`).

**Lema 2.** Para toda lista $L$ con $\mathrm{Ord}(L)$ y todo
$e \in \mathbb{N}$:

- **(a)** si existe $c$ con $(c, e) \in L$, entonces $D(L, e)$ es la
  lista que resulta de quitar de $L$ ese término, conservando el orden
  relativo de los demás. En particular
  $\mathrm{terms}(D(L, e)) = \mathrm{terms}(L) \setminus \{(c, e)\}$;
- **(b)** si no existe tal $c$, entonces $D(L, e)$ levanta `eopl:error`.

**Demostración.** Por inducción estructural sobre $L$.

- **Caso base** ($L = \varepsilon$): $e$ no aparece, y el programa
  levanta `eopl:error`. Se cumple (b); (a) es vacío.

- **Caso inductivo** ($L = (c_1, e_1) :: r$): por (H1) vale
  $\mathrm{Ord}(r)$ y por lo tanto la HI sobre $r$.

  1. **$e = e_1$.** El programa retorna $r$. Por (H2), ningún término de
     $r$ tiene exponente $e_1$, luego $(c_1, e_1) \notin r$. Entonces
     $\mathrm{terms}(L) \setminus \{(c_1, e)\} = \mathrm{terms}(r)$, que es
     exactamente lo retornado, y el orden relativo se conserva porque
     $r$ es la cola de $L$. Se cumple (a).

  2. **$e > e_1$.** Igual que en el Lema 1, por (H2) el exponente $e$ no
     aparece en $L$. El programa levanta `eopl:error`. Se cumple (b).

  3. **$e < e_1$.** El programa retorna
     $(c_1, e_1) :: D(r, e)$. Como $e \neq e_1$, el término buscado está
     en $L$ si y solo si está en $r$.
     - Si está en $r$, la HI dice que
       $\mathrm{terms}(D(r, e)) = \mathrm{terms}(r) \setminus \{(c, e)\}$.
       Entonces
       $\mathrm{terms}((c_1, e_1) :: D(r, e)) = \{(c_1, e_1)\} \cup
       (\mathrm{terms}(r) \setminus \{(c, e)\})$, que es igual a
       $\mathrm{terms}(L) \setminus \{(c, e)\}$ porque $(c_1, e_1) \neq
       (c, e)$ (pues $e_1 \neq e$). El orden relativo de los demás
       términos se conserva por la HI y porque la cabeza queda al
       principio. Se cumple (a).
     - Si no está en $r$, la HI dice que $D(r, e)$ levanta error, y ese
       error se propaga porque `eopl:error` aborta la evaluación. Se
       cumple (b). $\blacksquare$

**Preservación del invariante.** El resultado es una subsecuencia de
$L$ (se quitó a lo sumo un término sin mover los demás). Por (H4) cumple
$\mathrm{Inv}$: quitar un término no rompe el orden estricto, no
introduce ceros, no introduce exponentes negativos y no altera la forma
reducida de los coeficientes restantes. La variable no cambia, porque
`eliminar-termino` reconstruye el polinomio con `poli->var` (o `var`).

**Terminación.** Con $\mu(L) = |L|$ el argumento es idéntico al de 2.1:
la llamada recursiva se hace sobre $r$ con $\mu(r) = \mu(L) - 1$, la
medida decrece estrictamente y tiene cota inferior $0$.

**Conclusión:** `eliminar-termino` es correcta: con $\mathrm{Inv}(p)$ y
$e \in \mathbb{N}$, retorna un polinomio con exactamente los términos de
$p$ menos el de exponente $e$ (conservando el invariante) o levanta
`eopl:error` si ese término no existe, y termina en una sola pasada.

---

### 2.3 `insertar-termino` preserva el invariante

**Enunciado.** Si $\mathrm{Inv}(p)$ vale antes de la llamada, entonces
$\mathrm{Inv}(\texttt{insertar-termino}(p, c, e))$ vale sobre el
resultado, siempre que $c$ sea un número exacto y $e \in \mathbb{N}$. Si
no se cumple alguna de esas dos condiciones, la función levanta
`eopl:error` y no retorna ningún polinomio, así que no hay nada que
preservar.

**Código.**

*Representación con listas:*

```racket
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
```

*Representación con datatypes:*

```racket
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
```

*Representación con procedimientos:* el mismo código que con listas.

Llamamos $I(L, c, e)$ a la función auxiliar (`insertar-en-lista` o
`insertar-en`). El recorrido es el siguiente: la función copia los
términos cuyo exponente es mayor que $e$ y, en cuanto llega a la
posición del exponente $e$, hace la inserción, la suma o la eliminación.
Nunca se ordena al final: el invariante **se conserva** en cada paso.

**Lema 3.** Sea $L$ con $\mathrm{Inv}(L)$, $c$ un número exacto y
$e \in \mathbb{N}$ (en la versión con listas y procedimientos, además
$c \neq 0$, que garantiza el `cond` de `insertar-termino` antes de llamar
al auxiliar). Entonces:

- **(i)** $\mathrm{Inv}(I(L, c, e))$;
- **(ii)** $\mathrm{exps}(I(L, c, e)) \subseteq \mathrm{exps}(L) \cup \{e\}$.

La parte (ii) es un refuerzo necesario para que la inducción funcione:
al copiar la cabeza hay que saber que el resto no introduce exponentes
mayores.

**Demostración.** Por inducción estructural sobre $L$.

- **Caso base** ($L = \varepsilon$). El resultado es el único término
  $(c, e)$ (si $c = 0$, en datatypes el resultado es $\varepsilon$; ver el
  subcaso $c = 0$ más abajo). Una lista de un solo término cumple el orden
  estricto de forma vacía; $c \neq 0$; $e \in \mathbb{N}$; y por (T2) el
  coeficiente queda reducido. Vale (i). Vale (ii) porque
  $\mathrm{exps}(I) = \{e\}$.

- **Caso inductivo** ($L = (c_1, e_1) :: r$): por (H1) vale $\mathrm{Inv}(r)$
  y la HI para $r$. Los tres casos del enunciado se reparten así:

**Caso A — el exponente es nuevo.**
El exponente $e$ no está en $L$. Se presenta por dos caminos:

- **$e > e_1$** (el nuevo exponente va antes de la cabeza). El resultado
  es $(c, e) :: L$. El orden estricto se conserva porque $e > e_1$ y los
  siguientes ya están en orden por $\mathrm{Inv}(L)$, y por (H2) $e_1$
  es mayor que todos los de $r$. Además $c \neq 0$, $e \in \mathbb{N}$ y,
  por (T2), el coeficiente de $(c, e)$ está reducido; el resto de los
  términos no cambia. Vale (i). Vale (ii) porque
  $\mathrm{exps}(I) = \{e\} \cup \mathrm{exps}(L)$.

- **$e < e_1$** (hay que seguir buscando). El resultado es
  $(c_1, e_1) :: I(r, c, e)$. Por la HI, $\mathrm{Inv}(I(r, c, e))$ y
  $\mathrm{exps}(I(r, c, e)) \subseteq \mathrm{exps}(r) \cup \{e\}$. Ahora
  bien, $e_1$ es mayor que todo exponente de $r$ por (H2), y mayor que
  $e$ por la condición de este subcaso. Entonces $e_1$ es mayor que todo
  exponente de la cola del resultado, y como la cola cumple el orden
  estricto, la lista completa lo cumple. Los demás términos mantienen
  coeficientes no nulos, exponentes naturales y coeficientes reducidos
  porque son los de $L$ o los de $I(r, c, e)$, que cumplen $\mathrm{Inv}$
  por la HI. Vale (i). Vale (ii) porque
  $\mathrm{exps}(I) \subseteq \{e_1\} \cup \mathrm{exps}(r) \cup \{e\}
  \subseteq \mathrm{exps}(L) \cup \{e\}$.

La recursión del segundo subcaso termina en alguno de los casos
base o en uno de los casos B y C. Si el exponente es nuevo, termina en
$L = \varepsilon$ o en un término de exponente menor que $e$, y en
ambos casos se inserta $(c, e)$ en la posición que le corresponde.

**Caso B — el exponente ya existía y la suma no es cero.**
$e = e_1$ y $s = c_1 + c \neq 0$. El resultado es $(s, e_1) :: r$, donde
el coeficiente se reconstruye con `coef-interno` (o `concreto->coef`).

- *Orden estricto:* el término nuevo tiene el mismo exponente $e_1$ que el
  que reemplaza y está en la misma posición. Por (H2), $e_1$ sigue
  siendo mayor que todo exponente de $r$, y $\mathrm{Ord}(r)$ vale por
  (H1). El orden no cambia.
- *Sin ceros:* $s \neq 0$ por hipótesis del caso, y los términos de $r$
  siguen igual.
- *Exponentes naturales:* $e_1$ es el mismo exponente que ya estaba en $L$.
- *Racionales reducidos:* $s$ es la suma de dos números exactos de
  Racket, así que es un número exacto. Esta condición **no** se obtiene
  de que $c_1$ y $c$ estén reducidos, porque la suma de dos fracciones
  reducidas puede dar una fracción sin reducir si se calculara con
  numeradores y denominadores. Se obtiene porque la suma se hace sobre
  números concretos de Racket, que ya guarda en forma reducida y con
  denominador positivo, y luego se reconvierte con `coef-interno`, que
  por (T2) produce `coef-ent` si $s$ es entero y `coef-rac` con
  $\mathrm{numerator}(s)$ y $\mathrm{denominator}(s)$ en otro caso.

Vale (i). Vale (ii) porque
$\mathrm{exps}(I) = \mathrm{exps}(L) \subseteq \mathrm{exps}(L) \cup \{e\}$.

**Caso C — el exponente ya existía y la suma es cero.**
$e = e_1$ y $c_1 + c = 0$. El resultado es $r$. Por (H1), $\mathrm{Inv}(r)$
vale, lo que cubre las cuatro condiciones de una vez. En particular, el
término con coeficiente $0$ **no** se deja en la lista (no se construye
$(0, e_1)$), que es justo lo que exige la segunda condición. Vale (i).
Vale (ii) porque $\mathrm{exps}(r) \subseteq \mathrm{exps}(L)$. $\blacksquare$

**Subcaso $c = 0$ (coeficiente cero).** En las versiones con listas y
procedimientos, `insertar-termino` retorna $p$ sin tocarlo, y
$\mathrm{Inv}(p)$ es la pre-condición. En la versión con datatypes el
auxiliar maneja el cero: sobre $\varepsilon$ o con $e > e_1$ retorna la
lista de entrada sin cambios; con $e = e_1$ la suma es $s = c_1 \neq 0$,
así que se reconstruye el mismo término (Caso B con $s = c_1$); y con
$e < e_1$ se aplica la HI. Por inducción, el resultado es siempre la lista
original, que cumple $\mathrm{Inv}$.

**De los lemas a la función.** Para el polinomio completo:
`insertar-termino` retorna `poli` con la misma variable y la lista
$I(\mathrm{terms}(p), c, e)$. La variable no interviene en $\mathrm{Inv}$,
luego $\mathrm{Inv}$ del resultado es (i) del Lema 3 aplicado a
$\mathrm{terms}(p)$, que cumple $\mathrm{Inv}$ por la pre-condición.

**Terminación.** Con $\mu(L) = |L|$: la llamada recursiva solo ocurre en
el subcaso $e < e_1$, sobre $r$, con $\mu(r) = \mu(L) - 1$. La medida
decrece estrictamente, tiene cota inferior $0$, y cuando $\mu(L) = 0$
no hay llamada recursiva. La función termina en a lo sumo $|L| + 1$
llamadas, y recorre la lista una sola vez.

---

## 3. Equivalencia de las dos representaciones

La sección 2.2 de EOPL plantea que un tipo abstracto de datos tiene
una **interfaz**: un conjunto de constructores y observadores con un
comportamiento especificado. Quien usa el tipo trabaja contra esa
interfaz y no contra la forma en que están guardados los datos. Los dos
archivos, el de listas y el de procedimientos, implementan la misma
interfaz.

**Qué ve el cliente de un polinomio.** Solo tiene disponibles los
constructores (`poli`, `nombre-var`, `sin-terminos`, `mas-terminos`,
`termino`, `coef-ent`, `coef-rac`, `expo-nat`), los predicados
(`poli?`, `sin-terminos?`, etc.) y los extractores (`poli->var`,
`poli->terms`, `mas-terminos->term`, etc.), junto con las cuatro
funciones de la interfaz. No puede abrir el dato para ver cómo está
guardado, porque no hay ninguna operación del TAD que lo permita. Todo
lo que hace con un polinomio lo hace pidiéndoselo a un observador.

**Qué cambia entre las dos representaciones.**

- *Con listas*, cada dato es una lista cuyo primer elemento es una
  etiqueta. Por ejemplo, `(list 'poli var terms)`. Los observadores son
  `car`, `cadr` y `caddr` sobre esa lista.
- *Con procedimientos*, cada dato es un procedimiento que recibe un
  mensaje (`'tipo`, `'var`, `'terms`, etc.) y responde. Los observadores
  son la aplicación del procedimiento al mensaje correspondiente.

Ese cambio queda **del lado de adentro de la interfaz**: ocurre solo en
el bloque de constructores, predicados y extractores. El texto de
`polinomio-cero`, `insertar-termino`, `coeficiente-de`,
`eliminar-termino` y de sus auxiliares (`coef-concreto`, `coef-interno`,
`insertar-en-lista`, `buscar-coeficiente`, `eliminar-de-lista`) es el
mismo en los dos archivos, y ninguna de esas funciones llama a `car`,
`cdr`, `list?` ni aplica un dato a un mensaje: todo lo hacen a través
de los observadores.

**Qué propiedad de la interfaz hace que no se distingan.** Los
constructores y observadores de las dos representaciones cumplen las
mismas ecuaciones, que son las que especifica la gramática:

$$
\begin{aligned}
\text{poli->var}(\text{poli}(v, ts)) &= v, &
\text{poli->terms}(\text{poli}(v, ts)) &= ts \\
\text{mas-terminos->term}(\text{mas-terminos}(t, r)) &= t, &
\text{mas-terminos->resto}(\text{mas-terminos}(t, r)) &= r \\
\text{termino->coef}(\text{termino}(c, e)) &= c, &
\text{termino->expo}(\text{termino}(c, e)) &= e
\end{aligned}
$$

y análogamente para `nombre-var->s`, `coef-ent->n`, `coef-rac->num`,
`coef-rac->den` y `expo-nat->k`. Además, cada predicado es verdadero
sobre su propio constructor y falso sobre los demás. Como las cuatro
funciones solo usan estas operaciones, y las demostraciones de la
sección 2 solo usan estas ecuaciones y el invariante, las mismas
demostraciones valen para ambas representaciones: reemplazar una por
otra es reemplazar cada observador por otro que cumple las mismas
ecuaciones. Esta es la propiedad de la interfaz que importa:
**independencia de la representación**.

**Qué habría que hacer para que el cliente notara la diferencia.**
Tendría que usar algo que **no** es parte de la interfaz:

- aplicar `car` o `cadr` directamente a un polinomio (funciona con
  listas y falla con procedimientos), o aplicar el polinomio a un
  mensaje (funciona con procedimientos y falla con listas);
- usar `list?`, `pair?` o `procedure?` sobre el dato, o compararlo con
  `equal?`;
- imprimirlo con `display`: con listas se ve su estructura, y con
  procedimientos se ve un valor opaco.

Cualquiera de esas cosas supone que el cliente conoce la
representación y depende de ella, que es exactamente lo que la
abstracción debía impedir. Si el cliente lo hace, su código deja de
funcionar al cambiar de representación, y eso significa que rompió la
abstracción, no que las dos representaciones sean distintas respecto
de la interfaz. Por eso, para mostrar resultados, la representación con
datatypes agrega un auxiliar, `polinomio->lista`, que traduce el
polinomio a una lista concreta usando solo observadores.

La representación con datatypes, que es la tercera del taller, respeta
la misma regla: `define-datatype` también oculta la estructura interna
y obliga a pasar por `cases` o por los extractores, y las cuatro
funciones de la interfaz tienen la misma lógica allí.

---

## 4. Referencias

- Friedman, D. P., & Wand, M. *Essentials of Programming Languages*,
  3.ª ed., MIT Press, 2008. Sección 2.1 (especificación de datos),
  sección 2.2 (representación basada en listas y basada en
  procedimientos), sección 2.4 (`define-datatype` y `cases`).
- The Racket Reference, *Numbers*:
  <https://docs.racket-lang.org/reference/numbers.html> (sobre la forma
  reducida de los racionales exactos: `numerator`, `denominator`).
