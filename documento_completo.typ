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
  #text(size: 12pt)[CHIHUAHUA, CHIHUAHUA A 22 DE NOVIEMBRE DE 2025.] \
  #text(size: 12pt)[MANUEL ALBERTO CHAVEZ SALCIDO] \
  \
  #text(size: 16pt, weight: "bold")[ROBOTICS]
]

= ¿Qué es un robot?

Un robot se describe técnicamente como un manipulador reprogramable con varios grados de libertad, capaz de mover piezas, herramientas u otros dispositivos siguiendo trayectorias variables programadas para realizar tareas diversas.

No se trata simplemente de una “máquina” sino de un sistema interdisciplinario: mecánica, control, informática, sensores, actuadores, etc.

En tiempos contemporaneos, los robots han evolucionado mucho desde su origen en la industria automotriz, para abarcar aplicaciones en entornos no estructurados, robótica de servicio, teleoperación, robótica médica, exploración, etc.

Por lo tanto, un robot puede verse como un sistema mecánico + sensorial + computacional + de control, que recibe órdenes (programadas o autónomas) y realiza acciones físicas en su entorno.

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

=== RRR (Rotacional–Rotacional–Rotacional) Antropomórfico
Tres articulaciones rotacionales. Es un brazo antropomórfico que se asemeja al movimiento de un brazo humano.

=== RRP (Rotacional–Rotacional–Prismático) Scara
Dos articulaciones rotacionales más un eje prismático. Permite rotar y además extender/retraer una parte del brazo.

=== RR (Rotacional–Rotacional)
Dos rotaciones, parecido a un brazo plano de dos grados de libertad.

=== RP (Rotacional–Prismático)
Una rotación y un prismático. Es más limitado debido a la falta de movilidad que se puede presentar con un RR.

== Materiales Necesarios

Para cualquiera de estas configuraciones:

1. *Arduino*. Controlador principal (en nuestro caso optamos por un Arduino Mini).
2. *Servomotores*:
   - RRR → 3 servos rotacionales
   - RRP → 2 servos rotacionales + 1 actuador lineal o servo con mecanismo lineal
   - *RR → 2 servos rotacionales* (utilizamos servomotores SG-90)
   - RP → 1 servo rotacional + 1 actuador lineal
3. *Fuente de alimentación*. Una fuente de poder capaz de alimentar varios servos (utilizamos la HW-131).
4. *Estructura o base*. Uso de palillos de madera y silicón.
5. *Plataforma de dibujo*. Una base plana con un sujetador de lápiz al extremo del efector final.
6. *Cables, protoboard y componentes electrónicos básicos*. Jumpers Macho-Macho y Macho-Hembra.

== Figuras a Realizar

- *Círculo*
- *Cardioide*
- *Interfaz gráfica*

== ¿Por qué un Prismático es más Difícil?

=== Mecánica
Un servomotor da accesibilidad a la rotación, para realizar un movimiento linear sería necesario un actuador linear que permita el movimiento vertical (el cual es comúnmente más caro). O también, se podría utilizar una máquina simple de tornillo, lo cual añadiría complejidad al proyecto.

=== Control
El control de un desplazamiento lineal requiere conversión de pasos en distancia real, mientras que los rotacionales están calibrados en grados.

== Circuito

#align(center, image("./circuito.png", height: 30%, width: 60%, fit: "contain"))

En nuestro robot, el circuito original presentaba una configuración ligeramente distinta. Sin embargo, debido a las limitaciones del software utilizado para su modelado, optamos por representarlo de la manera mostrada.

En la implementación real, en lugar de conectar directamente servomotores al Arduino, empleamos una fuente de poder HW-131, la cual suministraba energía a los servomotores a través de un protoboard, garantizando así una distribución de la alimentación.

#pagebreak()

= Cinemática Inversa

La cinemática es la rama de la robótica que estudia la relación entre los movimientos
de las articulaciones del robot y la posición u orientación del efector final, sin
considerar fuerzas ni dinámicas. Su propósito es describir “dónde está” cada parte
del robot en función de cómo están configuradas sus articulaciones.

En un robot manipulador, la cinemática se divide en dos problemas fundamentales:

- *Cinemática Directa*: determina la posición del efector final a partir de los ángulos de las articulaciones.
- *Cinemática Inversa*: calcula los ángulos de las articulaciones necesarios para que el efector final alcance una posición deseada.

Ambos problemas se encuentran estrechamente relacionados. La cinemática directa
describe cómo se mueve el robot, y la inversa utiliza esa descripción para resolver el
movimiento deseado.

== Cinemática Directa

La cinemática directa permite obtener la posición del efector final partiendo de los
ángulos medidos o asignados a las articulaciones. En otras palabras:
“Si conozco los ángulos del robot, ¿dónde estará la punta?”
Para el caso del brazo robótico con configuración RR (Rotacional–Rotacional)
empleado en este proyecto, el sistema opera en un plano y consta de dos eslabones
de longitudes $l_1$ y $l_2$, y dos articulaciones rotacionales con ángulos $q_1$ y $q_2$.

=== Metodología para obtener las ecuaciones

La cinemática directa se obtiene analizando la geometría del robot paso a paso:

==== Representación del sistema
El robot posee:
- Primer eslabón de longitud $l_1$, rotado un ángulo $q_1$ respecto al eje horizontal.
- Segundo eslabón de longitud $l_2$, cuyo ángulo absoluto es $q_1$ + $q_2$ porque parte desde el extremo del primer eslabón.

Esto se puede representar de manera visual de la siguiente manera:

#align(center, image("./robot.jpeg", height: 40%, width: 40%, fit: "contain"))

==== Cálculo de la posición de la articulación intermedia
El extremo del primer eslabón (la articulación que une ambos eslabones) tiene
coordenadas:

- $𝑥_1 = 𝑙_1 cos(𝑞_1)$
- $𝑦_1 = 𝑙_1 sin(𝑞_1)$

Estas ecuaciones provienen directamente de proyectar el primer eslabón sobre los
ejes $x$ y $y$ usando funciones trigonométricas.

==== Contribución del segundo eslabón
El segundo eslabón parte del punto $(x_1, y_1)$ y está orientado a un ángulo total de:

#align(center, $𝑞_1 + 𝑞_2$)

Por tanto, sus componentes en $x$ y $y$ son:

- $𝑥_2 = 𝑙_2 cos (𝑞_1 + 𝑞_2)$
- $𝑦_2 = 𝑙_2 cos (𝑞_1 + 𝑞_2)$

==== Posición final del efector
La posición final se obtiene sumando las contribuciones de ambos eslabones:

- $𝑥 = 𝑥_1 + 𝑥_2 = 𝑙_1 cos(𝑞_1) + 𝑙_2 cos (𝑞_1 + 𝑞_2)$
- $𝑦 = 𝑦_1 + 𝑦_2 = 𝑙_1 sin(𝑞_1) + 𝑙_2 sin (𝑞_1 + 𝑞_2)$
- $𝜃 = 𝑞_1 + 𝑞_2$

Estas ecuaciones representan la cinemática directa del robot RR.

== Cinemática Inversa
La cinemática inversa permite determinar los ángulos $𝑞_1$ y $𝑞_2$ necesarios para que el
punto final del robot alcance una posición objetivo $(x, y)$. A diferencia de la cinemática
directa —donde se calcula la posición a partir de los ángulos— aquí se parte de la
posición deseada y se resuelven los ángulos que producen dicha ubicación.

El método utilizado se basa en analizar la geometría del triángulo formado por los dos
eslabones y el punto final, aplicando trigonometría y la ley de cosenos para obtener
cada ángulo paso a paso.

=== Cálculo del ángulo $q_2$
Para obtener el ángulo $𝑞_2$, se analiza primero el triángulo formado por:
- el origen,
- la articulación intermedia,
- y el punto final $(x, y)$

En este triángulo aparecen las longitudes $𝑙_1$ y $𝑙_2$, junto con la distancia del origen al
punto deseado $sqrt(𝑥_2 + 𝑦_2)$. Esto permite aplicar directamente la ley de cosenos para
relacionar estas longitudes con el ángulo buscado.

==== Aplicación de la Ley de Cosenos
Aquí se aplica la ley de cosenos:

#align(center, $c^2 = a^2 + b^2 - 2a b cos(C)$)

#align(center)[
  $(sqrt(x^2 + y^2))^2 = l_1^2 + l_2^2 - 2 l_1 l_2 cos(180° - q_2)$
]

Donde:
- $sqrt(x^2 + y^2)$ es la distancia del origen al punto final
- $l_1$ y $l_2$ son las longitudes de los eslabones
- $180° - q_2$ es el ángulo interno del triángulo

El ángulo interno del triángulo opuesto a $𝑙_2$ corresponde a $180° − 𝑞_2$. Esto permite
expresar la relación entre los lados y así conectar la posición deseada con la
articulación del segundo eslabón.

==== Desarrollo algebraico
En esta parte se despeja la ecuación de la ley de cosenos usando las longitudes
reales del robot. El objetivo de estos pasos es aislar la expresión donde aparezca el
coseno del ángulo $𝑞_2$.

Este desarrollo no cambia la estructura de la ecuación, solo la reorganiza para dejar
clara la dependencia entre $x$, $y$, $𝑙_1$, $𝑙_2$ y $𝑞_2$

#align(center)[
  $x^2 + y^2 = l_1^2 + l_2^2 - 2 l_1 l_2 cos(180° - q_2)$ \
  $x^2 + y^2 - l_1^2 - l_2^2 = -2 l_1 l_2 cos(180° - q_2)$
]

==== Aplicación de identidades trigonométricas
Para simplificar la expresión obtenida, se utiliza la identidad:

#align(center, $cos(180° - θ) = -cos(θ)$)

Esto permite expresar el resultado directamente en función de $cos (𝑞_2)$ lo cual facilita
el cálculo del valor final.

#align(center)[
  $x^2 + y^2 - l_1^2 - l_2^2 = -2 l_1 l_2 (-cos(q_2))$ \
  $x^2 + y^2 - l_1^2 - l_2^2 = 2 l_1 l_2 cos(q_2)$
]

==== Resolución para $q_2$
Después de sustituir y simplificar, se obtiene:

#align(center)[
  $cos(q_2) = frac(x^2 + y^2 - l_1^2 - l_2^2, 2 l_1 l_2)$
]

Finalmente:

#align(center)[
  $q_2 = cos^(-1) [frac(x^2 + y^2 - l_1^2 - l_2^2, 2 l_1 l_2)]$
]

Este es el ángulo del “codo”, determinado exclusivamente por la posición objetivo del
efector final y las longitudes del robot.

Aquí termina el cálculo del segundo ángulo, que es esencial antes de pasar al cálculo
de $𝑞_1$.

=== Cálculo del ángulo $q_1$

Una vez conocido $𝑞_2$, se procede a calcular $𝑞_1$. Este ángulo depende de dos
componentes:
- La dirección general hacia el punto $(x,y)$
- La corrección necesaria por el aporte del segundo eslabón (dependiendo de $𝑞_2$).
La combinación de ambos elementos determina cómo debe orientarse el primer
eslabón para que el segundo pueda completar el movimiento.

==== Ecuaciones de cinemática

Definiendo $alpha = tan^-1(frac(B, A)) = tan^-1(frac(l_2 sin(q_2), l_1 + l_2 cos(q_2)))$, donde:
- $A$ representa la proyección efectiva del primer eslabón más la componente horizontal del segundo
- $B$ representa la componente vertical del segundo eslabón

==== Resolución final

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
Una vez obtenidos los ángulos, es posible reconstruir las posiciones de cada
articulación mediante trigonometría directa. Esta parte confirma geométricamente
que los valores calculados permiten alcanzar el punto objetivo y sirve también para
animación o simulación del robot.

=== Posición de la articulación intermedia
Esta sección calcula la ubicación del punto donde se unen los dos eslabones.
Se aplican las funciones coseno y seno al ángulo $𝑞_1$, tal como se hace en la
cinemática directa.

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
Finalmente, la posición del efector final se obtiene sumando las componentes del
primer y segundo eslabón.
Este paso funciona como verificación de que los ángulos calculados permiten llegar
al punto deseado.

#align(center)[
  $x = x_1 + x_2 = l_1 cos(q_1) + l_2 cos(q_1 + q_2)$ \
  $y = y_1 + y_2 = l_1 sin(q_1) + l_2 sin(q_1 + q_2)$
]

==== Verificación geométrica
Esta ecuación reúsa la ley de cosenos para confirmar que las coordenadas obtenidas
son coherentes con la geometría del sistema. Si la igualdad se cumple, la solución
hallada para $𝑞_1$ y $𝑞_2$ es consistente.

#align(center)[
  $sqrt(x^2 + y^2) = sqrt(l_1^2 + l_2^2 + 2 l_1 l_2 cos(q_2))$
]

Esta relación se deriva de la ley de cosenos aplicada al triángulo formado por los eslabones.

== Ecuaciones Parametricas
Las ecuaciones paramétricas permiten describir una figura en el plano utilizando
parámetro $t$, que normalmente varía en el intervalo de $0$ a $2 pi$. En lugar de expresar
una curva mediante una sola ecuación, se definen dos funciones:
#align(center, [$𝑥 = 𝑥(𝑡)$ \ $𝑦 = 𝑦(𝑡)$])

De esta manera, al recorrer valores de t, se generan los pares $(x,y)$ que pertenecen a la
figura.

En el contexto del proyecto, estas ecuaciones proporcionan los puntos que el efector
final debe seguir para dibujar trayectorias como círculos o cardioides. Cada punto
generado por las ecuaciones paramétricas se envía posteriormente al bloque de
cinemática inversa, que calcula los ángulos necesarios de las articulaciones para
que el robot pueda moverse correctamente a lo largo de la curva. Así, las ecuaciones
paramétricas describen la forma de la figura, mientras que la cinemática inversa
permite que el robot la reproduzca físicamente.

== Definiciones

- $r$. Radio
- $(c_1, c_2)$. Centro
- $t$. Parametro con rango de $0$ a $2 pi$

== Circulo
Estas ecuaciones generan los puntos de un círculo conforme el parámetro $t$ recorre el
intervalo de $0$ a $2 pi$. El valor de $r$ determina el tamaño del círculo y $(𝑐_1, 𝑐_2)$ representan
el centro de la figura.

- x: $c_1 r cos(t)$
- y: $c_2 + r sin(t))$

== Cardioide

- x: $16 sin(t)^3$
- y: $13 cos(t) - 5 cos(2t) - 2 cos(3t) - cos(4t)$

