#include <Servo.h>

const int PIN_SERVO1 = 2;
const int PIN_SERVO2 = 3;

Servo servo1;
Servo servo2;

float q1 = 0.0;
float q2 = 0.0;
bool packetReady = false;
String inputString = "";

void setup() {
  Serial.begin(9600);
  inputString.reserve(32);

  servo1.attach(PIN_SERVO1);
  servo2.attach(PIN_SERVO2);
}

void loop() {
  while (Serial.available() > 0) {
    char c = Serial.read();

    if (c == '<') {
      inputString = "";
    } else if (c == '>') {
      packetReady = true;
      break;
    } else {
      inputString += c;
    }
  }

  if (packetReady) {
    processPacket(inputString);
    packetReady = false;
  }
}

void processPacket(String packet) {
  // q1,q2
  int commaIndex = packet.indexOf(',');
  if (commaIndex == -1) {
    return;
  }

  String q1_str = packet.substring(0, commaIndex);
  String q2_str = packet.substring(commaIndex + 1);

  q1 = q1_str.toFloat();
  q2 = q2_str.toFloat();

  servo1.write((int)q1); // redondear
  delay(2000);
  servo2.write((int)q2);
}

