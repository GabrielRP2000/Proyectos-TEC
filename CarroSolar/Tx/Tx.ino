// Definir los pines analógicos para leer el joystick
const int pinX = A7;
const int pinY = A6;

void setup() {
  // Inicializar puerto serie para visualizar los valores
  Serial.begin(9600);
}

void loop() {
  // Leer los valores analógicos del joystick
  int xValue = analogRead(pinX);
  int yValue = analogRead(pinY);

/* 
  Serial.print("X=");
  Serial.println(xValue);
  Serial.print("Y=");
  Serial.println(yValue);
  delay(1000);
*/
  if (xValue>=0 && xValue<300 && yValue>700 && yValue<=1025){
     // Enviar el mensaje
    Serial.write('dr');
    delay(100);
  }
  //derechaAdelante x=1023 y=1023
  else if (xValue>700 && xValue<1025 && yValue>700 && yValue<1025){
     // Enviar el mensaje
    Serial.write('da');
    delay(100);
  }
  //izquierdareversa x=0 y=0
  else if (xValue>=0 && xValue<300 && yValue>=0 && yValue<300){
     // Enviar el mensaje
    Serial.write('ir');
    delay(100);
  }
  //izquierdaAdelante x=1023 y=0
  else if (xValue>700 && xValue<1025 && yValue>=0 && yValue<300){
     // Enviar el mensaje
    Serial.write('ia');
    delay(100);
  }
  //centro x=523 y=491
  else if (xValue>=300 && xValue<=700 && yValue>=300 && yValue<=700){
     // Enviar el mensaje
    Serial.write('c');
    delay(100);
  }
  //derecha x=523 y=1023
  else if (xValue>=300 && xValue<=700 && yValue>700 && yValue<=1025){
     // Enviar el mensaje
    Serial.write('d');
    delay(100);
  }
  //izquierda x=523 y=0
  else if (xValue>=300 && xValue<=700 && yValue>=0 && yValue<300){
     // Enviar el mensaje
    Serial.write('i');
    delay(100);
  }
  //adelante x=1023 y=491
  else if (xValue>700 && xValue<=1025 && yValue>=300 && yValue<=700){
     // Enviar el mensaje
    Serial.write('a');
    delay(100);
  }
  //reversa x=0 y=491
  else if (xValue>=0 && xValue<300 && yValue>=300 && yValue<=700){
     // Enviar el mensaje
    Serial.write('r');
    delay(100);
  }
  
  else{
   // Enviar el mensaje
    Serial.write('c');
    delay(100);
  }
}

/*
  // Imprimir los valores leídos en el monitor serial
  Serial.print("X: ");
  Serial.print(xValue);
  Serial.print("\tY: ");
  Serial.println(yValue);

  // Esperar un breve tiempo antes de volver a leer
  delay(100);
   // Mensaje a enviar
  const char *message = "Hola, mundo!";

  // Enviar el mensaje
  Serial.println(message);

  // Esperar un tiempo antes de enviar el siguiente mensaje
  delay(1000);
  

//centro x=523 y=491
//derecha x=523 y=1023
//izquierda x=523 y=0
//adelante x=1023 y=491
//reversa x=0 y=491
//derechaReversa x=0 y=1023
//derechaAdelante x=1023 y=1023
//izquierdareversa x=0 y=0
//izquierdaAdelante x=1023 y=0

  


  if (Serial.available() > 0) {
    char receivedChar = Serial.read();
    Serial.print("Caracter recibido: ");
    Serial.println(receivedChar);
  }

  delay(1000);


*/
