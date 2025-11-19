#set page(paper: "a4", margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm))
#set text(size: 11pt)
#set par(justify: true, leading: 0.65em)

#set heading(numbering: "1.")

#align(center)[
  #text(size: 16pt, weight: "bold")[UNIVERSIDAD AUTÓNOMA DE CHIHUAHUA] \
  #text(size: 14pt, weight: "bold")[FACULTAD DE INGENIERÍA] \
  \
  #text(size: 12pt)[OSCAR JOAQUIN MARQUEZ ORTEGA - 367726] \
  #text(size: 12pt)[BRAULIO SEBASTIAN PORRAS OLIVAS - 344175] \
  \
  #text(size: 14pt, weight: "bold")[Avances Proyecto] \
  \
  #text(size: 12pt)[CHIHUAHUA, CHIHUAHUA A 18 DE OCTUBRE DE 2025.] \
  #text(size: 12pt)[MANUEL ALBERTO CHAVEZ SALCIDO] \
  \
  #text(size: 16pt, weight: "bold")[ROBOTICS]
]

= Eleccion de Proyecto

== RR con GUI

Para el desarrollo de la interfaz gráfica se utilizará Python por su facilidad de uso y porque permite integrar tanto la parte visual como la comunicación con el brazo autónomo de manera muy simple. La GUI será implementada con Tkinter, que ofrece las herramientas necesarias para crear ventanas y botones.

=== Librerías

- La librería de `Tkinter` será suficiente para representar en pantalla las opciones que después el brazo reproducirá físicamente. Además, se utilizará `matplotlib` para crear la interfaz mediante la cual se obtendra el dibujo que podra ser dibujado con el mouse.
- La librería de PySerial se usara para establecer la conexión entre la interfaz y el Arduino para poder proprcionar los ángulos calculados, de manera que las instrucciones generadas en la aplicación puedan enviarse directamente al hardware que con anterioridad se le cargo el programa.

== Protocolo de Datos

A recomendacion de nuestro tutor decidimos utilizar un protocolo simple de datos que transferira los ángulos con el formato de `<q1, q2>`.

#pagebreak()

= Definiciones de las Configuraciones y Materiales del Proyecto

== Configuraciones

== RRR (Rotacional–Rotacional–Rotacional) Antropomórfico
Tres articulaciones rotacionales. Es un brazo antropomórfico que se asemeja al movimiento de un brazo humano.

== RRP (Rotacional–Rotacional–Prismático) Scara
Dos articulaciones rotacionales más un eje prismático. Permite rotar y además extender/retraer una parte del brazo.

== RR (Rotacional–Rotacional)
Dos rotaciones, parecido a un brazo plano de dos grados de libertad.

== RP (Rotacional–Prismático)
Una rotación y un prismático. Es más limitado debido a la falta de movilidad que se puede presentar con un RR.

== Materiales Necesarios

Para cualquiera de estas configuraciones:

1. *Arduino UNO*. Controlador principal.
2. *Servomotores*:
   - RRR → 3 servos rotacionales
   - RRP → 2 servos rotacionales + 1 actuador lineal o servo con mecanismo lineal
   - RR → 2 servos rotacionales
   - RP → 1 servo rotacional + 1 actuador lineal
3. *Fuente de alimentación*. Una batería capaz de alimentar varios servos.
4. *Estructura o base*. Uso de palillos de madera (buscando la posibilidad de utilizar una impresora 3D).
5. *Plataforma de dibujo*. Una base plana con un sujetador de lápiz al extremo del efector final.
6. *Cables, protoboard y componentes electrónicos básicos*. Resistencias, capacitores para estabilizar, etc.

== Figuras a Realizar

- *Círculo*
- *Cardioide*
- *Interfaz gráfica*

== ¿Por qué un Prismático es más Difícil?

=== Mecánica
Un servomotor da accesibilidad a la rotación, para realizar un movimiento linear sería necesario un actuador linear que permita el movimiento vertical (el cual es comúnmente más caro). O también, se podría utilizar una máquina simple de tornillo, lo cual añadiría complejidad al proyecto.

=== Control
El control de un desplazamiento lineal requiere conversión de pasos en distancia real, mientras que los rotacionales están calibrados en grados.

= Cinemática Inversa

== Cálculo del ángulo q₂

Para obtener el ángulo $q_2$:

=== Aplicación de la Ley de Cosenos

De la ley de cosenos $c^2 = a^2 + b^2 - 2a b cos(C)$, aplicada al triángulo formado por los eslabones:

#align(center)[
  $(sqrt(x^2 + y^2))^2 = l_1^2 + l_2^2 - 2 l_1 l_2 cos(180° - q_2)$
]

Donde:
- $sqrt(x^2 + y^2)$ es la distancia del origen al punto final
- $l_1$ y $l_2$ son las longitudes de los eslabones
- $180° - q_2$ es el ángulo interno del triángulo

=== Desarrollo algebraico

#align(center)[
  $x^2 + y^2 = l_1^2 + l_2^2 - 2 l_1 l_2 cos(180° - q_2)$ \
  $x^2 + y^2 - l_1^2 - l_2^2 = -2 l_1 l_2 cos(180° - q_2)$
]

=== Aplicación de identidades trigonométricas

Usando la identidad $cos(180° - θ) = -cos(θ)$:

#align(center)[
  $x^2 + y^2 - l_1^2 - l_2^2 = -2 l_1 l_2 (-cos(q_2))$ \
  $x^2 + y^2 - l_1^2 - l_2^2 = 2 l_1 l_2 cos(q_2)$
]

=== Resolución para q₂

#align(center)[
  $cos(q_2) = frac(x^2 + y^2 - l_1^2 - l_2^2, 2 l_1 l_2)$
]

Finalmente:

#align(center)[
  $q_2 = cos^(-1) [frac(x^2 + y^2 - l_1^2 - l_2^2, 2 l_1 l_2)]$
]

== Cálculo del ángulo q₁

Para obtener el ángulo $q_1$:

=== Ecuaciones de cinemática

Definiendo $alpha = tan^-1(frac(B, A)) = tan^-1(frac(l_2 sin(q_2), l_1 + l_2 cos(q_2)))$, donde:
- $A$ representa la proyección efectiva del primer eslabón más la componente horizontal del segundo
- $B$ representa la componente vertical del segundo eslabón

=== Resolución final

Por lo tanto:

#align(center)[
  $q_1 + alpha = tan^-1(frac(y, x))$
]

Despejando $q_1$:

#align(center)[
  $q_1 = tan^-1(frac(y, x)) - alpha$
]

Sustituyendo el valor de $alpha$:

#align(center)[
  $q_1 = tan^(-1)(frac(y, x)) - tan^(-1)(frac(l_2 sin(q_2), l_1 + l_2 cos(q_2)))$
]


== Coordenadas de los puntos

=== Posición de la articulación intermedia

Una vez calculados los ángulos $q_1$ y $q_2$, podemos determinar las coordenadas de todos los puntos del sistema:

==== Articulación intermedia (punto de unión entre eslabones)

#align(center)[
  $x_1 = l_1 cos(q_1)$ \
  $y_1 = l_1 sin(q_1)$
]

Donde $(x_1, y_1)$ es la posición de la articulación intermedia.

==== Componentes del segundo eslabón

Las componentes del segundo eslabón en el sistema de coordenadas global son:

#align(center)[
  $x_2 = l_2 cos(q_1 + q_2)$ \
  $y_2 = l_2 sin(q_1 + q_2)$
]

Donde $(x_2, y_2)$ son las componentes del segundo eslabón.

=== Posición del punto final

El punto final del brazo robótico se obtiene sumando las contribuciones de ambos eslabones:

#align(center)[
  $x = x_1 + x_2 = l_1 cos(q_1) + l_2 cos(q_1 + q_2)$ \
  $y = y_1 + y_2 = l_1 sin(q_1) + l_2 sin(q_1 + q_2)$
]

=== Verificación geométrica

Para verificar que los cálculos son correctos, se debe cumplir:

#align(center)[
  $sqrt(x^2 + y^2) = sqrt(l_1^2 + l_2^2 + 2 l_1 l_2 cos(q_2))$
]

Esta relación se deriva de la ley de cosenos aplicada al triángulo formado por los eslabones.

= Ecuaciones Parametricas

== Definiciones

- $r$. Radio
- $(c_1, c_2)$. Centro
- $t$. Parametro con rango de $0$ a $2 pi$

== Circulo

- x: $c_1 r cos(t)$
- y: $c_2 + r sin(t))$

== Cardioide

- x: $16 sin(t)^3$
- y: $13 cos(t) - 5 cos(2t) - 2 cos(3t) - cos(4t)$

