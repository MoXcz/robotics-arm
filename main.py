import tkinter as tk
from tkinter import ttk
from animacion import animar_brazo
from dibujo import Draw
from ecuaciones_parametricas import generar_circulo, generar_cardioide
from serialize import (
    init_serial,
    enviar_informacion,
)


def run_gui():
    root = tk.Tk()
    root.title("Simulador de Figuras")
    frame = ttk.Frame(root, padding=20)
    frame.grid()

    ttk.Label(frame, text="Seleccionar Figura:", font=("Helvetica", 14)).grid(
        column=0, row=0, pady=10
    )

    def run_circulo():
        x, y = generar_circulo(10, 10, 2)
        animar_brazo(x, y, 10, 10)
        ser = init_serial("/dev/ttyUSB0", 9600)
        if ser:
            enviar_informacion(ser, x, y, 10, 10)
            ser.close()

    def run_cardioide():
        x, y = generar_cardioide(10, 10, 0.2)
        animar_brazo(x, y, 10, 10)
        ser = init_serial("/dev/ttyUSB0", 9600)
        if ser:
            enviar_informacion(ser, x, y, 10, 10)
            ser.close()

    def run_draw():
        ser = init_serial("/dev/ttyUSB0", 9600)
        app = Draw(ser)
        app.run()

    ttk.Button(frame, text="Circulo", width=20, command=run_circulo).grid(
        column=0, row=1, pady=5
    )
    ttk.Button(frame, text="Cardioide", width=20, command=run_cardioide).grid(
        column=0, row=3, pady=5
    )
    ttk.Button(frame, text="Dibujar", width=20, command=run_draw).grid(
        column=0, row=4, pady=5
    )

    root.mainloop()


if __name__ == "__main__":
    run_gui()
