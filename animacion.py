import numpy as np
import math
from matplotlib.animation import FuncAnimation
import matplotlib.pyplot as plt
from cinematica_inversa import cinematica_inversa


def animar_brazo(x, y, l1, l2):
    q1, q2 = cinematica_inversa(x, y, l1, l2)
    print_res(x, y, q1, q2, True)

    fig, ax = plt.subplots(figsize=(7, 7))
    ax.set_xlim(-25, 25)
    ax.set_ylim(-25, 25)
    ax.set_aspect("equal")
    ax.grid(True)
    ax.set_title("Cinemática inversa con trazo")
    ax.set_xlabel("x")
    ax.set_ylabel("y")

    (linea_brazo,) = ax.plot([], [], "o-", lw=3, color="blue", label="Eslabones")

    _ = ax.plot(x, y, "--", color="gray", alpha=0.4, label="Trayectoria objetivo")

    (trazo,) = ax.plot([], [], color="red", lw=2, label="Trayectoria real")

    ax.legend()

    x_trazo, y_trazo = [], []

    def update(i):
        if np.isnan(q1[i]) or np.isnan(q2[i]):
            return linea_brazo, trazo
        x1 = l1 * np.cos(q1[i])
        y1 = l1 * np.sin(q1[i])
        x2 = x1 + l2 * np.cos(q1[i] + q2[i])
        y2 = y1 + l2 * np.sin(q1[i] + q2[i])
        linea_brazo.set_data([0, x1, x2], [0, y1, y2])
        x_trazo.append(x2)
        y_trazo.append(y2)
        trazo.set_data(x_trazo, y_trazo)
        return linea_brazo, trazo

    anim = FuncAnimation(fig, update, frames=len(x), interval=40, blit=True)
    plt.show()
    return anim


def print_res(x, y, q1, q2, deg: bool):
    print("\n--- Resultados de Primeros 10 puntos de Cinematica Inversa ---")
    count = 0
    for px, py in zip(x, y):
        if count == 10:
            break
        print(f"({math.floor(px)},{math.floor(py)}):")
        count += 1

    if deg:
        q1 = np.degrees(q1)
        q2 = np.degrees(q2)

    print("q1:", np.round(q1[:10], 3))
    print("q2:", np.round(q2[:10], 3))
    print("--------------------------------------------------------------\n")
