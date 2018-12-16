#include <PubSubClient.h>
#include <ESP8266WiFi.h>
#include <DHT.h>

#define DHTTYPE DHT11  // what sensor we use
#define DHTPIN D4  // what pin to use

const char* ssid  = "TheHouseOnTheHill"; // set ssid 
const char* mqtt_host  = "192.168.10.4";  // point to MQTT server
const int port = 1883;  // set MQTT port
const char* sensorname = "Sensor1"; // set sensor name , no whitespaces

// Initialize DHT sensor
DHT dht(DHTPIN, DHTTYPE);
float humidity, temperature;                 // Raw float values from the sensor
char str_humidity[10], str_temperature[10];  // Rounded sensor values and as strings

void setup() {

  // Connect D0 to RST to wake up
  pinMode(D0, WAKEUP_PULLUP);

  // Open the Arduino IDE Serial Monitor to see what the code is doing
  // Can be disabled in order to save memory
  Serial.begin(115200);
  dht.begin();

}

void loop() {
  
  initWifi();  // connect to wifi
  
  //  Read from sensor
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  // Convert the floats to strings and round to 1 decimal places for domoticz
  dtostrf(humidity, 1, 1, str_humidity);
  dtostrf(temperature, 1, 1, str_temperature);


  WiFiClient wifiClient;  // set client name
  PubSubClient client(mqtt_host,port,wifiClient);  // define client
  client.setServer(mqtt_host,port); // set server

  // connect to server, and print some debug output 
  while (!client.connected()) {
    Serial.println("Connecting to MQTT...");
     if (client.connect("ESP8266Client")) {
       Serial.println("connected");  
     } else {
       Serial.print("failed with state ");
      Serial.print(client.state());
      delay(2000);
     }
  }

  Serial.println("Sending temperature and humidity to MQTT server...");
  // the idx value is the sensor idx number inte domoticz
  // create properly formatted string for posting to MQTT and Domoticz to understand
  String pubStringTemperature = "{ \"idx\" : 36, \"nvalue\" : 0, \"svalue\" : \""+String(str_temperature)+"\" }";
  String pubStringHumidity = "{ \"idx\" : 37, \"nvalue\" : " +String(str_humidity)+ ", \"svalue\" : \"0\" }";
  
  // publish temperature , need to convert to char array for publish to work.
  client.publish("domoticz/in",(char*) pubStringTemperature.c_str());
  client.publish("domoticz/in",(char*) pubStringHumidity.c_str()); 

  Serial.println("All done");
   
   WiFi.disconnect(); // disconnect from wifi
   WiFi.mode(WIFI_OFF);
   
   // sleep for  while 
  delay(297000);  // adapt for 3-4 seconds time to connect to wifi
  }


  
void initWifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid);
  // Serial.print("Connecting");

  // Wait for successful connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    //Serial.print(".");
  }
/*  Use for debugging
    
  Serial.println("");
  Serial.print("Connected to: ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  Serial.println("");
*/
}

