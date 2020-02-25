#include <OneButton.h>
#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>

#define GREEN_LED 2
#define RED_LED 13

// edit the SSID & password to match your local network
const char* ssid = "<insert_ssid_here>";
const char* password = "<insert_pwd_here>";
const char* host = "hooks.zapier.com"; // edit the host adress, ip address etc. 
String url = "<insert_hook_url>"; // edit the hook url 
const int httpsPort = 443;
// SHA1 fingerprint of the certificate
// if you use another provider, be sure to change the fingerprint
const char fingerprint[] PROGMEM = "AF 21 4A 6C 2C E4 CE 6E 99 7B B8 EA 58 CF 57 6B C2 35 A4 0D";
const String request = "POST " + url + " HTTP/1.1\r\n" +
               "Host: " + host + "\r\n" +
               "Content-Type: application/x-www-form-urlencoded" + "\r\n" +
               "Content-Length: 21" + "\r\n\r\n" +
               "body=BringOnTheCoffee" + "\r\n" +
               "Connection: close\r\n\r\n";

OneButton button(D6, true);
WiFiClientSecure httpsClient;

void connectAndSendRequest() {
  // Connecting to host and send request
  Serial.print("HTTPS Connecting");
  int r=0; //retry counter
  while((!httpsClient.connect(host, httpsPort)) && (r < 30)){
      delay(100);
      Serial.print(".");
      r++;
  }
  if (r==30) {
    koLed();
    Serial.println("Connection failed");
  }
  else {
    Serial.println("Connected to host");
  }
  String address = host + url;
  //POST Data
  Serial.print("Requesting URL: ");
  Serial.println(address);
  blinkLeds();

  httpsClient.print(request);

  Serial.println("request sent");

  while (httpsClient.connected()) {
    String line = httpsClient.readStringUntil('\n');
    if (line == "\r") {
      Serial.println("headers received");
      break;
    }
  }

  Serial.println("reply was:");
  Serial.println("==========");
  String line;
  while(httpsClient.available()){
    line = httpsClient.readStringUntil('\n');  //Read Line by Line
    Serial.println(line); //Print response
    if (line.startsWith("{\"status\": \"success\"")) {
      Serial.println("Command was sent!");
      okLed();
    } else {
      Serial.println("Something went wrong!");
      koLed();
    }
  }
  Serial.println("==========");
  Serial.println("closing connection");
}

void setup() {
  // Initializing LEDs
  pinMode(GREEN_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  digitalWrite(GREEN_LED, LOW);
  digitalWrite(RED_LED, LOW);

  button.attachClick(connectAndSendRequest);

  // Initializing Wifi-connection
  Serial.begin(115200);
  // We start by connecting to a WiFi network
  Serial.print("Connecting to ");
  Serial.println(ssid);
  /* Explicitly set the ESP8266 to be a WiFi-client, otherwise, it by default,
    would try to act as both a client and an access-point and could cause
    network-issues with your other WiFi-devices on your WiFi-network. */
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  // Setting up connexion to host
 
  Serial.println(host);
 
  Serial.printf("Using fingerprint '%s'\n", fingerprint);
  httpsClient.setFingerprint(fingerprint);
  httpsClient.setTimeout(15000); // 15 Seconds
  flashLed(GREEN_LED);
}

void okLed() {
  digitalWrite(GREEN_LED, HIGH);
  delay(3000);
  digitalWrite(GREEN_LED, LOW);
}

void koLed() {
  digitalWrite(RED_LED, HIGH);
  delay(3000);
  digitalWrite(RED_LED, LOW);
}

void flashLed(int led) {
  for (int i=0;i<4;i++) {
    digitalWrite(led, HIGH);
    delay(250);
    digitalWrite(led, LOW);
    delay(250);
  }
}

void blinkLeds() {
  for (int i=0;i<11;i++) {
    digitalWrite(GREEN_LED, HIGH);
    digitalWrite(RED_LED, LOW);
    delay(125);
    digitalWrite(GREEN_LED, LOW);
    digitalWrite(RED_LED, HIGH);
    delay(125);
  }
  digitalWrite(GREEN_LED, LOW);
  digitalWrite(RED_LED, LOW);
}

void loop() {
  button.tick();
  delay(10);
}
