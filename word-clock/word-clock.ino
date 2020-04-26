#include <OneWire.h>
#include <Wire.h>
#include <FastLED.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <ESP8266WiFi.h>
#include <aREST.h>

#include "ClockElement.h"

//#define FASTLED_ESP8266_RAW_PIN_ORDER
#define NUM_LEDS 125
#define HEART_LEDS 10
#define NUM_CLOCK_ELEMENTS 19

#define DATA_PIN 5
#define pResistor A5
#define ONE_WIRE_BUS 7

aREST rest = aREST();
CRGB leds[NUM_LEDS];
String CLOCK_TYPE = "word-clock";
String ROOM_NAME = "Wohnzimmer"; //Needs to be configurable

char ssid[32] = "WordClock"; //Needs to be configurable
char pass[32] = "99crafts"; //Needs to be configurable
const long utcOffsetInSeconds = 7200;
boolean isConnectedToWifi = false;

WiFiUDP ntpUDP;
WiFiClient client;
WiFiServer server(80);
NTPClient timeClient(ntpUDP, "pool.ntp.org", utcOffsetInSeconds);

ClockElement timeClockElements[NUM_CLOCK_ELEMENTS];

//   Eins, Zwei, Drei, Vier, Fünf, Sechs, Sieben, Acht, Neun, Zehn, Elf, Zwölf, Null, Fünf, Zehn, Viertel, Zwanzig, Halb
int timeClockElementRangeFrom[NUM_CLOCK_ELEMENTS] = { 44,    51,   40,   33,   55,   22,    26,     18,   3,    0,    58,  13,  -1,   117,  106,  92,      99,      62  };
int timeClockElementRangeTo[NUM_CLOCK_ELEMENTS]   = { 48,    55,   44,   37,   59,   27,    32,     22,   7,    4,    61,  18,  -1,   121,  110,  99,      106,     66  };
int heartLEDs[HEART_LEDS] = {38, 48, 62, 69, 83, 71, 81, 73, 58, 50 };

struct CURRENT_TIME {
  int hours;
  int minutes;

  CURRENT_TIME(int h, int m) {
    hours = h;
    minutes = m;
  }
};


bool createdClockElements = false;
void createClockElements()
{
  createdClockElements = true;
  int clockElementIndex = 0;
  for (int i = 1; i <= 12; i++)
  {
    int numericValueAM = i;
    int numericValuePM = i + 12;

    if (i + 12 == 24)
    {
      numericValuePM = 0;
    }

    timeClockElements[clockElementIndex] = ClockElement(numericValueAM, numericValuePM, timeClockElementRangeFrom[i - 1], timeClockElementRangeTo[i - 1], HOUR);
    clockElementIndex++;
  }

  //Create the ClockElements for the minutes
  int minuteDistance = 60;
  int rangeIndex = 12;
  for (int i = 0; i <= 30; i += 5)
  {
    int numericValueAM = i;
    int numericValuePM = i + minuteDistance;

    if (i == 30) {
      rangeIndex--;
    }

    timeClockElements[clockElementIndex] = ClockElement(numericValueAM, numericValuePM, timeClockElementRangeFrom[rangeIndex], timeClockElementRangeTo[rangeIndex], MINUTE);

    rangeIndex++;
    minuteDistance -= 10;
    clockElementIndex++;
  }
}


void setup()
{
  Serial.begin(9600);

  rest.variable("type", &CLOCK_TYPE);
  rest.variable("room_name", &ROOM_NAME);

  // Function to be exposed
  rest.function("clockcolor", setPixelColor);
  rest.function("clockconfiguration", configureClock);
  rest.function("clockname", changeClockName);

  rest.function("wordclockfreya", showFreya);
  rest.function("setDST", setDST);

  //Opposite of beginAP is WiFi.begin
  WiFi.softAP(ssid, pass);
  Serial.println(WiFi.softAPIP());

  server.begin();
  // you're connected now, so print out the status:
  createClockElements();
  FastLED.addLeds<WS2812B, DATA_PIN>(leds, NUM_LEDS);

  timeClient.begin();
}

char color[3] = {255, 255, 255};

bool showUhrWord = true;
void loop()
{

  String clientRequest = "";

  client = server.available();   // listen for incoming clients

  while (client.connected()) {
    rest.handle(client);
    handleClockFunctions();
  }

  handleClockFunctions();
  delay(100);
}

int setDST() {
  return 1;
}

int configureClock(String configuration) {
  Serial.println("Configuring clock with following parameters:");
  String wifiSSID = "";
  String wifiPassword = "";
  String clockRoomName = "";

  int beginningIndex = 0;
  int configIndex = 0;
  String wifiConfiguration[3];
  while (configuration.indexOf(",", beginningIndex) != -1) {
    int index = configuration.indexOf(",", beginningIndex);
    wifiConfiguration[configIndex] = configuration.substring(beginningIndex, index);
    beginningIndex = index + 1;
    configIndex++;
  }

  wifiConfiguration[configIndex] = configuration.substring(beginningIndex, configuration.length());

  for (int i = 0; i < 3; i++) {
    String wifiConfig = wifiConfiguration[i];
    String configKeyValue[2];
    configKeyValue[0] = wifiConfig.substring(0, wifiConfig.indexOf("=", 0));
    configKeyValue[1] = wifiConfig.substring(configKeyValue[0].length() + 1, wifiConfig.length());

    Serial.print(configKeyValue[0] + ": ");
    Serial.println(configKeyValue[1]);

    if (i == 0) {
      Serial.println(configKeyValue[0]);
      configKeyValue[0].toCharArray(ssid, configKeyValue[0].length() + 1);
      Serial.println(ssid);
    } else if (configKeyValue[0].equals("password")) {
      configKeyValue[1].toCharArray(pass, configKeyValue[1].length() + 1);
    } else if (configKeyValue[0].equals("room-name")) {
      ROOM_NAME = configKeyValue[1];
    }
  }

  beginWifiServer();

  return 1;
}

int changeClockName(String clockName) {
  ROOM_NAME = clockName;
}

void handleClockFunctions() {
  if (isConnectedToWifi) {
    CURRENT_TIME currentTime = getTimeFromNTPServer();

    resetAllLEDs();
    showBasicClockElements();
    showMinuteLEDs(currentTime.minutes, currentTime.hours, showUhrWord);
    showHourLEDs(currentTime.hours);

    if (showUhrWord)
    {
      //Light up the LEDs for the word "UHR"
      leds[8] = CRGB(color[1], color[0], color[2]);
      leds[9] = CRGB(color[1], color[0], color[2]);
      leds[10] = CRGB(color[1], color[0], color[2]);
    }
  } else {
    leds[83] = CRGB(color[1], color[0], color[2]);
    leds[70] = CRGB(color[1], color[0], color[2]);
    leds[61] = CRGB(color[1], color[0], color[2]);
    leds[48] = CRGB(color[1], color[0], color[2]);
    leds[39] = CRGB(color[1], color[0], color[2]);

    leds[72] = CRGB(color[1], color[0], color[2]);
    leds[73] = CRGB(color[1], color[0], color[2]);
    leds[74] = CRGB(color[1], color[0], color[2]);
  }

  FastLED.show();
}

CURRENT_TIME getTimeFromNTPServer() {
  timeClient.update();
  delay(1000);
  return CURRENT_TIME(timeClient.getHours(), timeClient.getMinutes());
}

void beginWifiServer() {
  WiFi.disconnect();

  while ( WiFi.status() == WL_CONNECTED ) {
    delay ( 500 );
    Serial.print ( "." );
  }
  
  WiFi.begin(ssid, pass);

  while ( WiFi.status() != WL_CONNECTED ) {
    delay ( 500 );
    Serial.print ( "." );
  }

  isConnectedToWifi = true;
  server.begin();
  Serial.println(WiFi.localIP());
}

int showFreya(String command) {
  showWordFreya();
}

//http://192.168.4.1/rgb?param=1,2,3
int setPixelColor(String rgb) {
  int beginningIndex = 0;
  int colorIndex = 0;
  while (rgb.indexOf(",", beginningIndex) != -1) {
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
  Serial.print("Hour to show: ");
  Serial.println(hours);

  ClockElement clockElement = findClockElementByNumericValueAndType(hours, HOUR);

  Serial.print("Hour that will be shown: ");
  Serial.println(clockElement.GetNumericValuePM());
  Serial.println("");

  setColorForClockElement(clockElement, color[1], color[0], color[2]);
}

void showMinuteLEDs(int minutes, int &hours, bool &showUhrWord) {
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

    if (60 - minutes < 25 || (minutes >= 25 && minutes < 30) ||
        (minutes >= 35 && minutes < 40) || (minutes >= 30 && minutes < 35)) {
      hours = hours + 1;
    }
    showLeftOverMinuteLEDs(minutes % 5);
  }

  ClockElement clockElement = findClockElementByNumericValueAndType(minutes - (minutes % 5), MINUTE);
  setColorForClockElement(clockElement, color[1], color[0], color[2]);
}

void showLeftOverMinuteLEDs(int leftOverMinutes) {
  for (int i = 124; i > 124 - leftOverMinutes; i--) {
    leds[i] = CRGB(color[1], color[0], color[2]);
  }
}

void resetAllLEDs() {
  //Reset time words
  for (int i = 0; i < NUM_LEDS; i++) {
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
  leds[75] = CRGB(0, 255, 0);
  leds[76] = CRGB(0, 255, 0);
  leds[77] = CRGB(0, 255, 0);
  leds[78] = CRGB(0, 255, 0);
  leds[79] = CRGB(0, 255, 0);

  for (int i = 0; i < HEART_LEDS; i++) {
    leds[heartLEDs[i]] = CRGB(0, 255, 0);
    FastLED.delay(150);
  }
  delay(150);

  for (int i = 0; i < HEART_LEDS; i++) {
    leds[heartLEDs[i]] = CRGB(0, 0, 0);
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

    if (elementType == MINUTE && clockElement.GetClockElementType() == MINUTE) {
      if ((numericValue == clockElement.GetNumericValueAM() || numericValue == clockElement.GetNumericValuePM())) {
        return timeClockElements[i];
      }
    } else if (elementType == HOUR && clockElement.GetClockElementType() == HOUR) {
      if (numericValue == clockElement.GetNumericValueAM() || numericValue == clockElement.GetNumericValuePM()) {
        return timeClockElements[i];
      }

    }
  }

  if (foundElement == NULL) {
    Serial.print("foundElement of type ");
    if (elementType == HOUR) {
      Serial.println("hour is NULL");
    } else if (elementType == MINUTE) {
      Serial.println("minute is NULL");
    }
  }

  return *foundElement;
}
