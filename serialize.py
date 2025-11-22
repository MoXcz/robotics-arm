import serial
import numpy as np
import time

from cinematica_inversa import cinematica_inversa


def init_serial(port="/dev/ttyACM0", baudrate=9600, timeout=1):
    try:
        ser = serial.Serial(port, baudrate, timeout=timeout)
        time.sleep(3)  # Espera a que Arduino reinicie
        print(f"Conectado a {port} a {baudrate} baudios.")
        return ser
    except serial.SerialException as e:
        print(f"Error al abrir puerto serial: {e}")
        return None


def serialize_angulos(q1, q2):
    return f"<{q1:.2f},{q2:.2f}>\n".encode("ascii")


def enviar_angulos(ser, q1, q2):
    if ser is None:
        print("Serial no inicializado.")
        return

    q1_deg = np.degrees(q1)
    q2_deg = np.degrees(q2)

    # Ajustar q1 para que el rango sea 0-180
    x_deg = np.clip(np.round(q1_deg), 0, 180).astype(int)
    y_deg = np.clip(np.round(q2_deg), 0, 180).astype(int)

    packet = serialize_angulos(x_deg, y_deg)
    ser.write(packet)
    ser.flush()
    print(f"Enviado: {packet.decode().strip()}")
    time.sleep(5)


def enviar_informacion(
    ser: serial.Serial, x: np.ndarray, y: np.ndarray, l1: int, l2: int
):
    """
    Calcula la cinemática inversa y envía los ángulos al Arduino.
    Envía los datos punto por punto con delays apropiados.
    """
    q1, q2 = cinematica_inversa(x, y, l1, l2)

    # Filtrar puntos inválidos (NaN)
    valid = ~np.isnan(q1) & ~np.isnan(q2)
    q1, q2 = q1[valid], q2[valid]

    print(f"Enviando {len(q1)} puntos al Arduino...")

    for a, b in zip(q1, q2):
        if ser:
            enviar_angulos(ser, a, b)
