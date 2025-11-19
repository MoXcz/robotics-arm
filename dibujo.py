import time
import numpy as np
from cinematica_inversa import cinematica_inversa
import matplotlib.pyplot as plt
from animacion import animar_brazo


class Draw:
    def __init__(self, ser, l1=8, l2=10):
        self.l1 = l1
        self.ser = ser
        self.l2 = l2
        self.drawing = False
        self.x_path, self.y_path = [], []

        self.fig, self.ax = plt.subplots(figsize=(7, 7))
        self.ax.set_xlim(-25, 25)
        self.ax.set_ylim(-25, 25)
        self.ax.set_aspect("equal")
        self.ax.grid(True)
        self.ax.set_title("Dibujar con mouse")
        (self.path_line,) = self.ax.plot([], [], "--", color="gray", alpha=0.4)
        (self.arm_line,) = self.ax.plot([], [], "o-", lw=3, color="blue")
        (self.trace,) = self.ax.plot([], [], color="red", lw=2)

        self.fig.canvas.mpl_connect("button_press_event", self.on_press)
        self.fig.canvas.mpl_connect("motion_notify_event", self.on_motion)
        self.fig.canvas.mpl_connect("button_release_event", self.on_release)

    def on_press(self, event):
        if event.inaxes != self.ax:
            return
        self.drawing = True
        self.x_path, self.y_path = [event.xdata], [event.ydata]

    def on_motion(self, event):
        if not self.drawing or event.inaxes != self.ax:
            return
        self.x_path.append(event.xdata)
        self.y_path.append(event.ydata)
        self.path_line.set_data(self.x_path, self.y_path)
        self.fig.canvas.draw_idle()

    def on_release(self, _):
        if not self.drawing:
            return
        self.drawing = False

        # Calcular ángulos
        q1, q2 = cinematica_inversa(
            np.array(self.x_path), np.array(self.y_path), self.l1, self.l2
        )

        # Filtrar puntos inválidos
        valid = ~np.isnan(q1) & ~np.isnan(q2)
        q1, q2 = q1[valid], q2[valid]

        # Enviar al Arduino
        if self.ser:
            print(f"Enviando {len(q1)} puntos al Arduino...")
            for i, (a1, a2) in enumerate(zip(q1, q2)):
                # Convertir de radianes a grados y ajustar para servos
                x_deg = int(np.clip(np.round(np.degrees(a1) + 90), 0, 180))
                y_deg = int(np.clip(np.round(np.degrees(a2)), 0, 180))
                packet = f"<{x_deg:.2f},{y_deg:.2f}>\n"
                self.ser.write(packet.encode("ascii"))
                self.ser.flush()
                print(f"→ Enviado ({i+1}/{len(q1)}): {packet.strip()}")
                time.sleep(5)
        self.anim = animar_brazo(self.x_path, self.y_path, self.l1, self.l2)

    def run(self):
        plt.show()
