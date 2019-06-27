#include <OneWire.h>
#include <Vector.h>
#include <Wire.h>
#include <TimeLib.h>
#include <FastLED.h>
#include <SPI.h>
#include <WiFiNINA.h>
#include <FastLED.h>
#include <aREST.h>

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

WiFiServer server(80);
WiFiClient client;

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
    
  rest.function("wordclockfreya", showFreya);

  //Opposite of beginAP is WiFi.begin
  status = WiFi.beginAP(ssid, pass);
  
  server.begin();
  // you're connected now, so print out the status:
  // printWifiStatus();

  FastLED.addLeds<WS2812B, DATA_PIN>(leds, NUM_LEDS);
  createClockElements();
}

char color[3] = {255, 255, 255};
int currentHour = 10;
int currentMinute = 45;

bool showUhrWord = true;
void loop()
{  
  String clientRequest = "";
  client = server.available();   // listen for incoming clients
  getIPTime();
  handleClockFunctions();
    
  while (client.connected()) {
    rest.handle(client);
    handleClockFunctions();
  }
  client.stop();
}

void handleClockFunctions() {
  int minutes = 45;
  int hours = 10;
  resetAllLEDs();
  showBasicClockElements();
  showMinuteLEDs(minutes, hours, showUhrWord);
  showHourLEDs(hours);
    
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

void getIPTime() {
    unsigned long epoch = 1561488487 + 7200;
    currentHour = ((epoch  % 86400L) / 3600);
    currentMinute = (epoch  % 3600) / 60;  
}

int beginWifiServer(String command) {
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
  int colors[3] = {255, 255, 0};

  int beginningIndex = 0;
  int colorIndex = 0;
  while(rgb.indexOf(",", beginningIndex) != -1){
    int index = rgb.indexOf(",", beginningIndex);
    colors[colorIndex] = rgb.substring(beginningIndex, index).toInt();
    beginningIndex = index + 1;
    colorIndex++;
  }
  colors[colorIndex] = rgb.substring(beginningIndex, rgb.length()).toInt();

  for(int i = 0; i < NUM_LEDS; i++){
    leds[i] = CRGB(colors[1], colors[0], colors[2]);
  }
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
