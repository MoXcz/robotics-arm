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
    x_servo = np.clip(np.round(q1_deg), 0, 180).astype(int)
    y_servo = np.clip(np.round(q2_deg), 0, 180).astype(int)

    packet = serialize_angulos(x_servo, y_servo)
    ser.write(packet)
    ser.flush()
    print(f"Enviado: {packet.decode().strip()}")
    time.sleep(5)


def enviar_informacion(ser, x, y, l1, l2):
    """
    Calcula la cinemática inversa y envía los ángulos al Arduino.
    Envía los datos punto por punto con delays apropiados.
    """
    q1, q2 = cinematica_inversa(x, y, l1, l2)

    # Filtrar puntos inválidos (NaN)
    valid = ~np.isnan(q1) & ~np.isnan(q2)
    q1_valid = q1[valid]
    q2_valid = q2[valid]

    print(f"Enviando {len(q1_valid)} puntos al Arduino...")

    for i, (a, b) in enumerate(zip(q1_valid, q2_valid)):
        if ser:
            enviar_angulos(ser, a, b)
        else:
            # Si no hay serial, solo imprimir
            q1_deg = int(np.clip(np.round(np.degrees(a) + 90), 0, 180))
            q2_deg = int(np.clip(np.round(np.degrees(b)), 0, 180))
            print(
                f"Punto {i+1}/{len(q1_valid)}: {serialize_angulos(q1_deg, q2_deg).decode().strip()}"
            )
