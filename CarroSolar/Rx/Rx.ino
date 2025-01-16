void setup() {
  Serial.begin(9600);
}

void loop() {

  if (Serial.available() > 0) {
    char receivedChar = Serial.read();
    Serial.print("Caracter recibido: ");
    Serial.println(receivedChar);
  }
  delay(100);
}
