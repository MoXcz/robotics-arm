import numpy as np


def cinematica_inversa(
    x: np.ndarray, y: np.ndarray, l1: int, l2: int
) -> tuple[np.ndarray, np.ndarray]:
    """
    Calcula los ángulos articulares (q1, q2) de un robot de dos eslabones (RR)
    que necesita alcanzar una serie de puntos cartesianos (x, y).

    Parámetros
    ----------
    x, y : Arrays (x, y)
        Coordenadas del extremo del efector final (trayectoria a alcanzar).
    l1, l2 : float
        Longitudes de los eslabones del brazo.

    Retorna
    -------
    (q1, q2) : tuple of np.ndarray
        Listas con los ángulos de las articulaciones en radianes.
        Si un punto no es alcanzable, se devuelve np.nan en su lugar.
    """

    puntos_q1, puntos_q2 = [], []

    # Recorre todos los puntos de la trayectoria (se obtuvieron con las ecuaciones parametricas)
    for px, py in zip(x, y):
        D = (px**2 + py**2 - (l1**2 + l2**2)) / (2 * l1 * l2)

        # Si |D| > 1 el punto está fuera del alcance físico del brazo
        if D < -1 or D > 1:
            puntos_q1.append(np.nan)
            puntos_q2.append(np.nan)
            continue

        # ángulo del brazo l2
        q2 = np.arccos(D)

        # ángulo del brazo l1
        q1 = np.arctan2(py, px) - np.arctan2(l2 * np.sin(q2), l1 + l2 * np.cos(q2))

        puntos_q1.append(q1)
        puntos_q2.append(q2)

    return np.array(puntos_q1), np.array(puntos_q2)
