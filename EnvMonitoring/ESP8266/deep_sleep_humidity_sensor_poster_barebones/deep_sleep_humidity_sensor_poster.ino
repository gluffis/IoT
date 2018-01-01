#include <ESP8266HTTPClient.h>
#include <ESP8266WiFi.h>
#include <DHT.h>

#define DHTTYPE DHT11
#define DHTPIN D4

const char* ssid  = "YourSSIDHere"; // set ssid 
const char* host  = "YourServerHere";  // set reporting host
const int port = 80;  // set port on webserver
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
//  Serial.begin(115200);
  dht.begin();

  initWifi();  // connect to wifi
    
  //  Read from sensor
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

   // Convert the floats to strings and round to 2 decimal places
  dtostrf(humidity, 1, 2, str_humidity);
  dtostrf(temperature, 1, 2, str_temperature);


    // Do http post 
   HTTPClient http;
   String url = "/report.php?humidity=";  // the reporting url on the host
    url += str_humidity;
    url += "&temp=";
    url += str_temperature;
    url += "&sensorname=";
    url += sensorname;
   http.begin(host,port,url);
   http.setUserAgent("SEtYourUserAgentHere");
   int httpCode = http.GET();
   //String payload = http.getString();                  //Get the response payload
 
 //  Serial.println(httpCode);   //Print HTTP return code
  // Serial.println(payload);    //Print request response payload
   
   http.end();  // close HTTP socket
   WiFi.disconnect(); // disconnect from wifi
   WiFi.mode(WIFI_OFF);

   ESP.deepSleep(300e6); // sleep for 300 seconds
}

void loop() {
  // we will never get here whe deep sleeping
  }
  
void initWifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid);
//  Serial.print("Connecting");

  // Wait for successful connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
 //   Serial.print(".");
  }
//  Serial.println("");
//  Serial.print("Connected to: ");
//  Serial.println(ssid);
//  Serial.print("IP address: ");
//  Serial.println(WiFi.localIP());
//  Serial.println("");
}



