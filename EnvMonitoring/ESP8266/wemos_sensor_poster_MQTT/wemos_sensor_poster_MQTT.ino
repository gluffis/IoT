
#include <Adafruit_MQTT.h>
#include <Adafruit_MQTT_Client.h>

#include <ESP8266HTTPClient.h>
#include <ESP8266WiFi.h>
#include <DHT.h>


#define DHTTYPE DHT11
#define DHTPIN D4

const char* ssid  = "TheHouseOnTheHill"; // set ssid 
const char* mqtt_host  = "192.168.10.4";  // set reporting host
const int port = 1883;  // set port on webserver
const char* sensorname = "Sensor1"; // set sensor name , no whitespaces


// Initialize DHT sensor
DHT dht(DHTPIN, DHTTYPE);

float humidity, temperature;                 // Raw float values from the sensor
char str_humidity[10], str_temperature[10];  // Rounded sensor values and as strings

void setup() {

  // Connect D0 to RST to wake up
  pinMode(D0, WAKEUP_PULLUP);

  // Open the Arduino IDE Serial Monitor to see what the code is doing
  // Will be disabled in production version
  Serial.begin(115200);
  dht.begin();
}

void loop() {
  
  initWifi();  // connect to wifi
    
  //  Read from sensor
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

   // Convert the floats to strings and round to 2 decimal places
  dtostrf(humidity, 1, 2, str_humidity);
  dtostrf(temperature, 1, 2, str_temperature);

  // Post to MQTT queue for Domoticz
  MQTT_connect()

   WiFi.disconnect(); // disconnect from wifi
   WiFi.mode(WIFI_OFF);
   
   // sleep for  while 
   delay(297000);  // adapt for 3-4 seconds time to connect to wifi

  }
  
void initWifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid);
  Serial.print("Connecting");

  // Wait for successful connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to: ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  Serial.println("");
}

