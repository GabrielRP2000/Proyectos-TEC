#include <WiFi.h>
//#include <WiFiClient.h>
#include <HTTPClient.h>

//#include <esp_eap_client.h>

//String line; //variable for response
//const char* ssid = "wTEC"; // Eduroam SSID
//#define EAP_IDENTITY "gabriel2000956@estudiantes.tec.cr" //identity@youruniversity.domain
//#define EAP_PASSWORD "Gsrp27102000+" //your Eduroam password

const char* ssid = "SeslabSC";
const char* password = "Se5labV1e";

//const char* ssid = "Gabriel";
//const char* password = "12345678";

// URL de tu Google Apps Script Web App
const char* serverName = "https://script.google.com/macros/s/AKfycbzpWkyD8LbWA110LrHvaZN9pnlGAzWQsqcCUO8JvY-i_fvASVKOoA5QyW4C-4cBpyt7/exec";

// Crea un cliente UDP y un objeto para NTPClient
#include <NTPClient.h>
#include <WiFiUdp.h>
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", -21600, 60000); // -21600 es el offset para Costa Rica (-6 horas)

///////////////////////////////////////////////////////////
#include "HX711.h"
// Pines del HX710A a la ESP32
#define DOUT 5  // Conectar a DT del HX710A
#define CLK 23  // Conectar a SCK del HX710A
HX711 scale;
////////////////////////////////////////////////////////////
#include <Adafruit_INA228.h>
// Creamos dos objetos INA228 con diferentes direcciones I2C
Adafruit_INA228 ina228_1 = Adafruit_INA228();
Adafruit_INA228 ina228_2 = Adafruit_INA228();
/////////////////////////////////////////////////////////////
#include "max6675.h"
/////////////////////////////////////////////////////////////
#include <DHT.h>

// Definimos el pin digital donde se conecta el sensor
#define DHTPIN 15
// Dependiendo del tipo de sensor
#define DHTTYPE DHT11

// Inicializamos el sensor DHT11
DHT dht(DHTPIN, DHTTYPE);
////////////////////////////////////////////////////////////

// Define pines
const int CS1 = 26, CS2 = 25, CS3 = 33, CS4 = 32;
const int SCK_PIN = 14;
const int SO = 4;  // Pines compartidos

MAX6675 sensor1(SCK_PIN, CS1, SO);
MAX6675 sensor2(SCK_PIN, CS2, SO);
MAX6675 sensor3(SCK_PIN, CS3, SO);
MAX6675 sensor4(SCK_PIN, CS4, SO);

//////////////////////////////////////////////////////////////////////////////////////////
// Parámetros del circuito
const float Vcc = 3.3;     // Voltaje de referencia (3.3V para ESP32)
const int R_fija1 = 8000;  // Resistencia fija en ohmios (10kΩ)
const int R_fija2 = 8000;
const int R_fija3 = 8000;
//Pin donde está conectado el divisor de voltaje
const int pinNTC1 = 34;  // Cambiar según el pin que uses en la ESP32
const int pinNTC2 = 36;  //VP
const int pinNTC3 = 39;  //VN

float temp1 = 0;
float temp2 = 0;
float temp3 = 0;
float temp4 = 0;
float T_NTC1 = 0;
float T_NTC2 = 0;
float T_NTC3 = 0;
float y = 0;
float C0 = 0;
float V0 = 0;
float P0 = 0;
float J0 = 0;
float C1 = 0;
float V1 = 0;
float P1 = 0;
float J1 = 0;
float h = 0;
float t = 0;
float hic = 0;

float resistenciasNTC[] = { 14533.3, 14337.6, 14143.2, 13873.8, 13693.3, 13513.9, 13247.9, 13081.6, 12916.0, 12653.7, 12500.5, 12347.9, 12089.5, 11948.5, 11808.0, 11553.5, 
                            11423.9, 11294.6, 11044.2, 10925.2, 10806.4, 10560.2, 10451.0, 10341.9, 10100.0, 10000.0, 9900.0, 9670.9, 9570.9, 9471.0, 9262.3, 9162.6, 9063.0,
                            8873.2, 8773.8, 8674.7, 8502.5, 8403.7, 8305.2, 8149.4, 8051.2, 7953.4, 7812.8, 7715.4, 7618.4, 7491.9, 7395.3, 7299.3, 7185.9, 7090.3, 6995.3,
                            6894.0, 6799.5, 6705.6, 6615.6, 6522.1, 6429.4, 6349.8, 6257.6, 6166.0, 6096.2, 6005.1, 5914.8, 5854.0, 5764.2, 5675.2, 5622.7, 5534.2, 5446.5, 
                            5401.8, 5314.6, 5228.3, 5190.7, 5104.9, 5019.9, 4989.0, 4904.5, 4821.0, 4796.1, 4713.0, 4630.9, 4611.7, 4530.0, 4449.4, 4435.4, 4355.1, 4275.9, 
                            4266.7, 4187.8, 4110.0, 4105.3, 4027.8, 3951.5, 3950.8, 3874.8, 3799.9, 3803.0, 3728.3, 3654.8, 3661.4, 3588.2, 3516.1, 3525.8, 3454.0, 3383.3, 
                            3396.0, 3325.5, 3256.2, 3271.5, 3202.5, 3134.6, 3152.3, 3084.6, 3018.1, 3038.0, 2971.7, 2906.5, 2928.5, 2863.5, 2799.6, 2823.4, 2759.7, 2697.2, 
                            2722.7, 2660.3, 2599.0, 2626.0, 2564.9, 2504.9, 2533.3, 2473.4, 2414.7, 2444.3, 2385.6, 2328.2, 2358.9, 2301.4, 2245.2, 2276.8, 2220.6, 2165.6, 
                            2198.1, 2143.1, 2089.2, 2122.4, 2068.6, 2015.9, 2049.8, 1997.0, 1945.5, 1980.0, 1928.3, 1877.9, 1912.9, 1862.3, 1813.0, 1848.4, 1798.9, 1750.7, 
                            1786.4, 1738.0, 1690.8};  // Resistencias en ohmios
float temperaturas[] = { 17.25, 17.5, 17.75, 18.25, 18.5, 18.75, 19.25, 19.5, 19.75, 20.25, 20.5, 20.75, 21.25, 21.5, 21.75, 22.25, 22.5, 22.75, 23.25, 23.5, 23.75, 24.25, 
                        24.5, 24.75, 25.25, 25.5, 25.75, 26.25, 26.5, 26.75, 27.25, 27.5, 27.75, 28.25, 28.5, 28.75, 29.25, 29.5, 29.75, 30.25, 30.5, 30.75, 31.25, 31.5, 
                        31.75, 32.25, 32.5, 32.75, 33.25, 33.5, 33.75, 34.25, 34.5, 34.75, 35.25, 35.5, 35.75, 36.25, 36.5, 36.75, 37.25, 37.5, 37.75, 38.25, 38.5, 38.75, 
                        39.25, 39.5, 39.75, 40.25, 40.5, 40.75, 41.25, 41.5, 41.75, 42.25, 42.5, 42.75, 43.25, 43.5, 43.75, 44.25, 44.5, 44.75, 45.25, 45.5, 45.75, 46.25, 
                        46.5, 46.75, 47.25, 47.5, 47.75, 48.25, 48.5, 48.75, 49.25, 49.5, 49.75, 50.25, 50.5, 50.75, 51.25, 51.5, 51.75, 52.25, 52.5, 52.75, 53.25, 53.5, 
                        53.75, 54.25, 54.5, 54.75, 55.25, 55.5, 55.75, 56.25, 56.5, 56.75, 57.25, 57.5, 57.75, 58.25, 58.5, 58.75, 59.25, 59.5, 59.75, 60.25, 60.5, 60.75, 
                        61.25, 61.5, 61.75, 62.25, 62.5, 62.75, 63.25, 63.5, 63.75, 64.25, 64.5, 64.75, 65.25, 65.5, 65.75, 66.25, 66.5, 66.75, 67.25, 67.5, 67.75, 68.25, 
                        68.5, 68.75, 69.25, 69.5, 69.75, 70.25, 70.5, 70.75}; // Temperaturas en grados Celsius

// Calculamos el tamaño del array
int SizeR = sizeof(resistenciasNTC) / sizeof(resistenciasNTC[0]);
int SizeT = sizeof(temperaturas) / sizeof(temperaturas[0]);
//////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  Serial.begin(9600);
//////////////////////////////////////////////////////////////////////////////
  WiFi.begin(ssid, password);
  // Conexión a WiFi
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Conectando a WiFi...");
  }
  Serial.println("Conectado a WiFi");
  // Iniciar el cliente NTP
  timeClient.begin();
//////////////////////////////////////////////////////////////////////////////
//  Iniciamos el HX710
  scale.begin(DOUT, CLK);
  scale.set_scale();  // Calibración inicial
//////////////////////////////////////////////////////////////////////////////
  // Comenzamos el sensor DHT
  dht.begin();

  while (!Serial) {
    delay(10);
  }
//////////////////////////////////////////////////////////////////////////////
  Serial.println("Adafruit INA228 Test");

  // Iniciar el primer módulo INA228 (A0 y A1 conectados a GND - dirección 0x40)
  if (!ina228_1.begin(0x40)) {
    Serial.println("No se encontró el chip INA228 en dirección 0x40");
    while (1)
      ;
  }
  Serial.println("Chip INA228 encontrado en dirección 0x40");
  ina228_1.setShunt(0.1, 1.0);

  // Iniciar el segundo módulo INA228 (A0 en Vcc y A1 en GND - dirección 0x41)
  if (!ina228_2.begin(0x41)) {
    Serial.println("No se encontró el chip INA228 en dirección 0x41");
    while (1)
      ;
  }
  Serial.println("Chip INA228 encontrado en dirección 0x41");
  ina228_2.setShunt(0.1, 1.0);

  // Configuraciones comunes para ambos módulos
  ina228_1.setAveragingCount(INA228_COUNT_16);
  ina228_2.setAveragingCount(INA228_COUNT_16);
  //////////////////////////////////////////////////////////////////////////////
}

void loop() {
  timeClient.update();  // Actualiza la hora desde el servidor NTP
  // Obtén la hora actual (en segundos desde la medianoche)
  int currentHour = timeClient.getHours();
  if (WiFi.status() != WL_CONNECTED) {
      Serial.println("Conexión WiFi perdida, intentando reconectar...");
      connectToWiFi();  // Intentar reconectar si la conexión se pierde
    }
  if (currentHour >= 8 && currentHour < 16) { //toma datos de 8am a 4pm
  ///////////////////////////////////////Modulo MAX6675//////////////////////////////////////////////////////////////////
    // Leer temperatura
    temp1 = sensor1.readCelsius();
    temp2 = sensor2.readCelsius();
    temp3 = sensor3.readCelsius();
    temp4 = sensor4.readCelsius();
    //double temperature = thermocouple.readCelsius();

    // Mostrar temperatura
    Serial.print("Temperatura 1: ");
    Serial.print(temp1);
    Serial.println(" °C");

    Serial.print("Temperatura 2: ");
    Serial.print(temp2);
    Serial.println(" °C");

    Serial.print("Temperatura 3: ");
    Serial.print(temp3);
    Serial.println(" °C");

    Serial.print("Temperatura 4: ");
    Serial.print(temp4);
    Serial.println(" °C");
    Serial.println();

    ///////////////////////////////////////Modulo HX710//////////////////////////////////////////////////////////////////
    if (scale.is_ready()) {
      long x = scale.read();
      Serial.print("Lectura del sensor: ");
      Serial.println(x);

      // Convertir la lectura en mV
      float voltage = (x / 128.0) * (3.3 / 6000000.0);  // Ganancia de 128 y resolución de 24 bits-16 777 215 - 23 bits-8 388 607
      Serial.print("Voltaje Spektron: ");
      Serial.print(voltage, 6);
      Serial.println(" mV");

      // Convertir el voltaje a irradiancia en W/m^2
      //float irradiance = (voltage / 0.0803) * 1000;  // 80.3 mV = 1000 W/m²
      //y = -3e-17 * pow(x, 3) + 3e-10 * pow(x, 2) - 0.0006 * x + 426.05;
      y = -2e-15 * pow(x, 3) + 5e-9 * pow(x, 2) - 0.0026 * x + 390;

      //if (x > 5300000) {
      //  float y = 1150;
      //  Serial.print("Irradiancia: ");
      //  Serial.print(y);
      //  Serial.println(" W/m²");
      //} else 
      if (x < 200000) {
        y = 0;
        Serial.print("Irradiancia: ");
        Serial.print(y);
        Serial.println(" W/m²");
      } else {
        Serial.print("Irradiancia: ");
        Serial.print(y, 2);
        Serial.println(" W/m²");
      }
    } else {
      Serial.println("Esperando el sensor HX710...");
    }
    Serial.println();

    ////////////////////////////////////////////Modulo INA228/////////////////////////////////////////////////////////////
    //Lectura del primer módulo (0x40)
    Serial.println("Lecturas del INA228 en dirección 0x40:");
    C0 = ina228_1.readCurrent();
    Serial.print("Corriente: ");
    Serial.print(C0);
    Serial.println(" mA");
    V0 = ina228_1.readBusVoltage();
    Serial.print("Voltaje del bus: ");
    Serial.print(V0);
    Serial.println(" mV");
    P0 = ina228_1.readPower();
    Serial.print("Voltaje del bus: ");
    Serial.print(P0);
    Serial.println(" W");
    J0 = ina228_1.readEnergy();
    Serial.print("Voltaje del bus: ");
    Serial.print(J0);
    Serial.println(" J");

    // Lectura del segundo módulo (0x41)
    Serial.println("Lecturas del INA228 en dirección 0x41:");
    C1 = ina228_2.readCurrent();
    Serial.print("Corriente: ");
    Serial.print(C1);
    Serial.println(" mA");
    V1 = ina228_2.readBusVoltage();
    Serial.print("Voltaje del bus: ");
    Serial.print(V1);
    Serial.println(" mV");
    P1 = ina228_2.readPower();
    J1 = ina228_2.readEnergy();
    float T1 = ina228_2.readDieTemp();
    Serial.print("Temperatura INA: ");
    Serial.print(T1);
    Serial.println(" C");

    Serial.println();

    /////////////////////////////Modulo DHT11/////////////////////////////////////////////////////////////////////////

    // Leemos la humedad relativa
    h = dht.readHumidity();
    // Leemos la temperatura en grados centígrados (por defecto)
    t = dht.readTemperature();
    // Leemos la temperatura en grados Fahreheit
    float f = dht.readTemperature(true);

    // Comprobamos si ha habido algún error en la lectura
    if (isnan(h) || isnan(t) || isnan(f)) {
      Serial.println("Error obteniendo los datos del sensor DHT11");
      return;
    }

    // Calcular el índice de calor en Fahreheit
    //float hif = dht.computeHeatIndex(f, h);
    // Calcular el índice de calor en grados centígrados
    hic = dht.computeHeatIndex(t, h, false);

    Serial.print("Humedad: ");
    Serial.print(h);
    Serial.println(" %");
    Serial.print("Temperatura: ");
    Serial.print(t);
    Serial.println(" *C");
    //Serial.print(f);
    //Serial.print(" *F\t");
    Serial.print("Índice de calor: ");
    Serial.print(hic);
    Serial.println(" *C");
    Serial.println();

    //Serial.print(hif);
    //Serial.println(" *F");

    /////////////////////////////Termistor NTC/////////////////////////////////////////////////////////////////////////

    // Leer el valor del ADC
    int ADC_valor1 = analogRead(pinNTC1);
    // Convertir el valor del ADC a voltaje
    float Vout1 = (ADC_valor1 / 4095.0) * Vcc;
    // Calcular la resistencia del NTC
    float R_NTC1 = R_fija1 * (Vcc / Vout1 - 1);
    Serial.print("Voltaje Vout: ");
    Serial.println(Vout1);
    Serial.print("Resistencia NTC: ");
    Serial.println(R_NTC1);
    for (int i = 0; i < SizeR; i++) {
      if (R_NTC1 <= resistenciasNTC[i] && R_NTC1 >= resistenciasNTC[i + 1]) {
        //Serial.print("onicha");
        T_NTC1 = temperaturas[i];
        Serial.print("Temperatura: ");
        Serial.println(T_NTC1);
      }
    }

    // Leer el valor del ADC
    int ADC_valor2 = analogRead(pinNTC2);
    // Convertir el valor del ADC a voltaje
    float Vout2 = (ADC_valor2 / 4095.0) * Vcc;
    // Calcular la resistencia del NTC
    float R_NTC2 = R_fija2 * (Vcc / Vout2 - 1);
    Serial.print("Voltaje Vout: ");
    Serial.println(Vout2);
    Serial.print("Resistencia NTC: ");
    Serial.println(R_NTC2);
    for (int i = 0; i < SizeR; i++) {
      if (R_NTC2 <= resistenciasNTC[i] && R_NTC2 >= resistenciasNTC[i + 1]) {
        //Serial.print("onicha");
        T_NTC2 = temperaturas[i];
        Serial.print("Temperatura: ");
        Serial.println(T_NTC2);
      }
    }

    // Leer el valor del ADC
    int ADC_valor3 = analogRead(pinNTC1);
    // Convertir el valor del ADC a voltaje
    float Vout3 = (ADC_valor3 / 4095.0) * Vcc;
    // Calcular la resistencia del NTC
    float R_NTC3 = R_fija3 * (Vcc / Vout3 - 1);
    Serial.print("Voltaje Vout: ");
    Serial.println(Vout3);
    Serial.print("Resistencia NTC: ");
    Serial.println(R_NTC3);
    for (int i = 0; i < SizeR; i++) {
      if (R_NTC3 <= resistenciasNTC[i] && R_NTC3 >= resistenciasNTC[i + 1]) {
        T_NTC3 = temperaturas[i];
        Serial.print("Temperatura: ");
        Serial.println(T_NTC3);
      }
    }
    Serial.println(T_NTC2);
  //////////////////////////////////////Enviar JSON//////////////////////////////////////////////////////////////////
    
    if (WiFi.status() == WL_CONNECTED) {
      // Crear JSON para enviar los datos
      String jsonData = "{\"MAXsensor1\":" + String(temp1) + 
                            ",\"MAXsensor2\":" + String(temp2) + 
                            ",\"MAXsensor3\":" + String(temp3) + 
                            ",\"MAXsensor4\":" + String(temp4) + 
                            ",\"NTCsensor1\":" + String(T_NTC1) + 
                            ",\"NTCsensor2\":" + String(T_NTC2) + 
                            ",\"NTCsensor3\":" + String(T_NTC3) + 
                            ",\"DHTsensorTemp\":" + String(t) + 
                            ",\"DHTsensorHume\":" + String(h) + 
                            ",\"DHTsensorIndi\":" + String(hic) + 
                            ",\"Irradiancia\":" + String(y) + 
                            ",\"VoltajePanel1\":" + String(V0) + 
                            ",\"CorrientePanel1\":" + String(C0) + 
                            ",\"PotenciaPanel1\":" + String(P0) + 
                            ",\"EnergiaPanel1\":" + String(J0) + 
                            ",\"VoltajePanel2\":" + String(V1) + 
                            ",\"CorrientePanel2\":" + String(C1) + 
                            ",\"PotenciaPanel2\":" + String(P1) + 
                            ",\"EnergiaPanel2\":" + String(J1) + "}";

        // Enviar los datos al servidor Google Sheets
      HTTPClient http;
      http.begin(serverName);
      http.addHeader("Content-Type", "application/json");

      int httpResponseCode = http.POST(jsonData);

      if (httpResponseCode > 0) {
        String response = http.getString();
        Serial.println(httpResponseCode);
        Serial.println(response);
      } else {
        Serial.println("Error en la conexión");
      }
      http.end();
    }
  } else {
    Serial.println("Es de noche, no se recogen datos.");
  }

  delay(15000);  // Esperar 1 segundo entre lecturas
}


void connectToWiFi() {
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Conectando a WiFi...");
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Conectado a WiFi");
  } else {
    Serial.println("Error: No se pudo conectar a WiFi después de varios intentos");
  }
}