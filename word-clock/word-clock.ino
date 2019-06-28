#include <OneWire.h>
#include <Vector.h>
#include <Wire.h>
#include <TimeLib.h>
#include <FastLED.h>
#include <SPI.h>
#include <WiFiNINA.h>
#include <FastLED.h>
#include <aREST.h>
#include <WiFiUdp.h>

#include "ClockElement.h"

#define NUM_LEDS 125
#define HEART_LEDS 10
#define NUM_CLOCK_ELEMENTS 19

#define DATA_PIN 5
#define pResistor A5
#define ONE_WIRE_BUS 7

aREST rest = aREST();
int brightness = 255;
// Define the array of leds
CRGB leds[NUM_LEDS];
String CLOCK_TYPE = "word-clock";
String ROOM_NAME = "Wohnzimmer"; //Needs to be configurable
int status = WL_IDLE_STATUS;

unsigned int localPort = 2390;  
const int NTP_PACKET_SIZE = 48; // NTP time stamp is in the first 48 bytes of the message
byte packetBuffer[ NTP_PACKET_SIZE]; //buffer to hold incoming and outgoing packets

WiFiServer server(80);
WiFiClient client;
WiFiUDP udp;

char ssid[] = "Seip"; //Needs to be configurable
char pass[] = "connect.me"; //Needs to be configurable

ClockElement timeClockElements[NUM_CLOCK_ELEMENTS];

                                                //   Eins, Zwei, Drei, Vier, Fünf, Sechs, Sieben, Acht, Neun, Zehn, Elf, Zwölf, Null, Fünf, Zehn, Viertel, Zwanzig, Halb
int timeClockElementRangeFrom[NUM_CLOCK_ELEMENTS] = { 44,    51,   40,   33,   55,   22,    26,     18,   3,    0,    58,  13,  -1,   117,  106,  92,      99,      62  };
int timeClockElementRangeTo[NUM_CLOCK_ELEMENTS]   = { 48,    55,   44,   37,   59,   27,    32,     22,   7,    4,    61,  18,  -1,   121,  110,  99,      106,     66  };
int heartLEDs[HEART_LEDS] = {38, 48, 62, 69, 83, 71, 81, 73, 58, 50 };

void createClockElements()
{
  Serial.println("Creating Clock Elements");

  for (int i = 1; i <= 12; i++)
  {
    int *numericValues = new int[2];
    numericValues[0] = i;
    numericValues[1] = i + 12;
    
    if (i + 12 == 24)
    {
      numericValues[1] = 0;
    }

    timeClockElements[i] = ClockElement(numericValues, timeClockElementRangeFrom[i - 1], timeClockElementRangeTo[i - 1], HOUR);
  }

  //Create the ClockElements for the minutes
  int minuteDistance = 60;
  int rangeIndex = 12;
  for (int i = 0; i <= 30; i += 5)
  {
    int *numericValues = new int[2];
    numericValues[0] = i;
    numericValues[1] = i + minuteDistance;

    if (i == 30) {
      rangeIndex--;
    }

    timeClockElements[rangeIndex] = ClockElement(numericValues, timeClockElementRangeFrom[rangeIndex], timeClockElementRangeTo[rangeIndex], MINUTE);
    
    rangeIndex++;
    minuteDistance -= 10;
  }
}

void setup()
{
  Serial.begin(9600);

  rest.variable("type", &CLOCK_TYPE);
  rest.variable("room_name", &ROOM_NAME);
  
  // Function to be exposed
  rest.function("clockcolor", setPixelColor);
  rest.function("clocktime", getWifiTime);
  rest.function("clockwifi", beginWifiServer);
  rest.function("clockconfiguration", configureClock);
    
  rest.function("wordclockfreya", showFreya);

  //Opposite of beginAP is WiFi.begin
  status = WiFi.begin(ssid, pass);
  
  server.begin();
  udp.begin(localPort);
  // you're connected now, so print out the status:

  Serial.println(WiFi.localIP());
  // printWifiStatus();

  FastLED.addLeds<WS2812B, DATA_PIN>(leds, NUM_LEDS);
  createClockElements();
}

char color[3] = {255, 255, 255};
int currentHour = 0;
int currentMinute = 0;

bool showUhrWord = true;
void loop()
{  
  String clientRequest = "";
  client = server.available();   // listen for incoming clients
  handleClockFunctions();
    
  while (client.connected()) {
    rest.handle(client);
    handleClockFunctions();
  }
  client.stop();
}

int configureClock(String command){
  IPAddress address = WiFi.localIP();
  String ipAddress = String(address[0]) + "." + 
        String(address[1]) + "." + 
        String(address[2]) + "." + 
        String(address[3]);
  client.print("<html>");
  client.print("<head>");
  client.print("<title>Esp32</title>");
  client.print("<meta charset='UTF-8'>");
  client.print("</head>");
  client.print("<body>");
  client.print("<h1>Choose access point</h1>");
  client.print("<form method=\"GET\" action=/clockwifi>{{p}}");
  client.print("<br/><input type=\"text\" name=\"password\" placeholder=\"Wifi password\"/>");
  client.print("<br/><input type=\"submit\" value=\"Save\"/>");
  client.print("</form>");
  client.print("</body>");
  client.print("</html>");
  return 1;
}

void handleClockFunctions() {
  getTimeFromNTPServer();
  resetAllLEDs();
  showBasicClockElements();
  showMinuteLEDs(currentMinute, currentHour, showUhrWord);
  showHourLEDs(currentHour);
    
  if (showUhrWord)
  {
    //Light up the LEDs for the word "UHR"
    leds[8] = CRGB(color[1], color[0], color[2]);
    leds[9] = CRGB(color[1], color[0], color[2]);
    leds[10] = CRGB(color[1], color[0], color[2]);
  }

  FastLED.setBrightness(brightness);
  FastLED.show();
}

/* Don't hardwire the IP address or we won't get the benefits of the pool.
    Lookup the IP address for the host name instead */
//IPAddress timeServer(129, 6, 15, 28); // time.nist.gov NTP server
IPAddress timeServerIP; // time.nist.gov NTP server address
const char* ntpServerName = "1.de.pool.ntp.org";

void getTimeFromNTPServer(){
    //get a random server from the pool
  WiFi.hostByName(ntpServerName, timeServerIP);

  sendNTPpacket(timeServerIP); // send an NTP packet to a time server

  int cb = udp.parsePacket();
  if (!cb) {
    Serial.println("no packet yet");
  } else {
    udp.read(packetBuffer, NTP_PACKET_SIZE); // read the packet into the buffer


    unsigned long highWord = word(packetBuffer[40], packetBuffer[41]);
    unsigned long lowWord = word(packetBuffer[42], packetBuffer[43]);
    unsigned long secsSince1900 = highWord << 16 | lowWord;
    const unsigned long seventyYears = 2208988800UL;
    unsigned long epoch = secsSince1900 - seventyYears + 7200;

    currentHour  = (epoch  % 86400L) / 3600;
    // print the hour, minute and second:
    currentMinute = (epoch  % 3600) / 60;
    Serial.print(currentHour);
    Serial.print(":");
    Serial.print(currentMinute);
    Serial.println("");
  }
}

// send an NTP request to the time server at the given address
void sendNTPpacket(IPAddress& address) {
  Serial.println("sending NTP packet...");
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12]  = 49;
  packetBuffer[13]  = 0x4E;
  packetBuffer[14]  = 49;
  packetBuffer[15]  = 52;

  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:
  udp.beginPacket(address, 123); //NTP requests are to port 123
  udp.write(packetBuffer, NTP_PACKET_SIZE);
  udp.endPacket();
}

int beginWifiServer(String command) {
  Serial.println(command);
  WiFi.end();
  WiFi.begin("Honor 7X", "connect.me");
  server.begin();
  return 1;
}

int showFreya(String command) {
  showWordFreya();
}

int getWifiTime(String command) {
  return WiFi.getTime();
}

//http://192.168.4.1/rgb?param=1,2,3
int setPixelColor(String rgb) {
  int beginningIndex = 0;
  int colorIndex = 0;
  while(rgb.indexOf(",", beginningIndex) != -1){
    int index = rgb.indexOf(",", beginningIndex);
    Serial.println(rgb.substring(beginningIndex, index));
    color[colorIndex] = rgb.substring(beginningIndex, index).toInt();
    beginningIndex = index + 1;
    colorIndex++;
  }
  color[colorIndex] = rgb.substring(beginningIndex, rgb.length()).toInt();

  FastLED.show();
  // set single pixel color
  return 1;
}

void showHourLEDs(int &hours) {
  ClockElement clockElement = findClockElementByNumericValueAndType(hours, HOUR);
  setColorForClockElement(clockElement, color[1], color[0], color[2]);
}

void showMinuteLEDs(int minutes, int &hours, bool &showUhrWord) {
  ClockElement clockElement = findClockElementByNumericValueAndType(minutes, MINUTE);

  if (minutes >= 0 && minutes < 5) {
    showUhrWord = true;
  }
  else {
    showUhrWord = false;
  }
  
  if (minutes != 0) {
    if ((minutes >= 25 && minutes < 30) || (minutes >= 35 && minutes < 40))
    { 
      ClockElement element = findClockElementByNumericValueAndType(5, MINUTE);
      setColorForClockElement(element, color[0], color[1], color[2]);

      if (minutes >= 25 && minutes < 30)
      {
        showWordVor();
      }

      
      else if (minutes >= 35 && minutes < 40)
      {
        showWordNach();
      }
    }

    if (60 - minutes > 35 && !(minutes >= 0 && minutes < 5))
    {
      showWordNach();
    }
    else if (60 - minutes < 25 && !(minutes >= 0 && minutes < 5))
    {
      showWordVor();
    }

    if(60 - minutes < 25 || (minutes >= 25 && minutes < 30) || 
      (minutes >= 35 && minutes < 40) || (minutes >= 30 && minutes < 35)) {
      hours = hours + 1;
    }
    showLeftOverMinuteLEDs(minutes % 5);
  }

  setColorForClockElement(clockElement, color[1], color[0], color[2]);
}

void showLeftOverMinuteLEDs(int leftOverMinutes){
  for(int i = 124; i > 124 - leftOverMinutes; i--){
    leds[i] = CRGB(color[1], color[0], color[2]);
  }
}

void resetAllLEDs() {
  //Reset time words
  for(int i = 0; i < NUM_LEDS; i++){
    leds[i] = CRGB(0, 0, 0);
  }
}

void showBasicClockElements() {
  //Light up the LEDs for the word "ES"
  leds[110] = CRGB(color[1], color[0], color[2]);
  leds[111] = CRGB(color[1], color[0], color[2]);

  //Light up the LEDs for the word "IST"
  leds[113] = CRGB(color[1], color[0], color[2]);
  leds[114] = CRGB(color[1], color[0], color[2]);
  leds[115] = CRGB(color[1], color[0], color[2]);
}

void showWordVor() {
  //Light up the LEDs for the word "VOR"
  leds[85] = CRGB(color[1], color[0], color[2]);
  leds[86] = CRGB(color[1], color[0], color[2]);
  leds[87] = CRGB(color[1], color[0], color[2]);
}

void showWordNach() {
  //Light up the LEDs for the word "NACH"
  leds[66] = CRGB(color[1], color[0], color[2]);
  leds[67] = CRGB(color[1], color[0], color[2]);
  leds[68] = CRGB(color[1], color[0], color[2]);
  leds[69] = CRGB(color[1], color[0], color[2]);
}

void showWordFreya() {
  showUhrWord = false;
  //Light up the LEDs for the word "FREYA"
  leds[75] = CRGB(0,255,0);
  leds[76] = CRGB(0,255,0);
  leds[77] = CRGB(0,255,0);
  leds[78] = CRGB(0,255,0);
  leds[79] = CRGB(0,255,0);

  for(int i = 0; i < HEART_LEDS; i++){
    leds[heartLEDs[i]] = CRGB(0,255,0);
    FastLED.delay(150);
  }
  delay(150);
  
  for(int i = 0; i < HEART_LEDS; i++){
    leds[heartLEDs[i]] = CRGB(0,0,0);
    FastLED.delay(150);
  }
  showUhrWord = true;
}

void setColorForClockElement(ClockElement clockElement, int r, int g, int b) {
  for (int k = clockElement.GetRangeFrom(); k < clockElement.GetRangeTo(); k++)
  {
    leds[k] = CRGB(r, g, b);
  }
}

ClockElement findClockElementByNumericValueAndType(int numericValue, CLOCK_ELEMENT_TYPE elementType) {
  ClockElement *foundElement = NULL;

  for (int i = 0; i < NUM_CLOCK_ELEMENTS; i++)
  {
    ClockElement clockElement = timeClockElements[i];
    
    for (int j = 0; j < clockElement.GetNumericValuesArrayLength(); j++)
    {
      if(elementType == MINUTE && clockElement.GetClockElementType() == MINUTE){
        if (numericValue >= clockElement.GetNumericValueAtIndex(j) && numericValue < (clockElement.GetNumericValueAtIndex(j) + 5))
        {
          return timeClockElements[i];
        } 
      } else if(elementType == HOUR && clockElement.GetClockElementType() == HOUR) {
        if (numericValue == clockElement.GetNumericValueAtIndex(j) )
        {
          return timeClockElements[i];
        }  
      }
    }
  }

  return *foundElement;
}
