import numpy as np


def generar_circulo(c1: int, c2: int, r: int, n: int = 64) -> tuple:
    t = np.linspace(0, 2 * np.pi, n)
    return c1 + r * np.cos(t), c2 + r * np.sin(t)


def generar_cardioide(c1: int, c2: int, escala: float = 0.5, n: int = 64) -> tuple:
    t = np.linspace(0, 2 * np.pi, n)
    x = escala * (16 * (np.sin(t) ** 3))
    y = escala * (
        13 * np.cos(t) - 5 * np.cos(2 * t) - 2 * np.cos(3 * t) - np.cos(4 * t)
    )
    return c1 + x, c2 + y
