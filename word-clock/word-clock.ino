#include <OneWire.h>
#include <DallasTemperature.h>
#include <Vector.h>

#include <Wire.h>
#include <TimeLib.h>
#include <DS1307RTC.h>

#include <FastLED.h>

#include "ClockElement.h"

#define NUM_LEDS 125
#define HEART_LEDS 10
#define NUM_CLOCK_ELEMENTS 19

#define DATA_PIN 5
#define pResistor A5
#define ONE_WIRE_BUS 7


int brightness = 255;
// Define the array of leds
CRGB leds[NUM_LEDS];

Vector<ClockElement> timeClockElements;

                                                //   Eins, Zwei, Drei, Vier, Fünf, Sechs, Sieben, Acht, Neun, Zehn, Elf, Zwölf, Null, Fünf, Zehn, Viertel, Zwanzig, Halb
int timeClockElementRangeFrom[NUM_CLOCK_ELEMENTS] = { 44,    51,   40,   33,   55,   22,    26,     18,   3,    0,    58,  13,  -1,   117,  106,  92,      99,      62  };
int timeClockElementRangeTo[NUM_CLOCK_ELEMENTS]   = { 48,    55,   44,   37,   59,   27,    32,     22,   7,    4,    61,  18,  -1,   121,  110,  99,      106,     66  };
int heartLEDs[HEART_LEDS] = {38, 48, 62, 69, 83, 71, 81, 73, 58, 50 };

void createClockElements()
{
  //Create the ClockElements for the hours
  ClockElement storage_array1[NUM_CLOCK_ELEMENTS];
  timeClockElements.setStorage(storage_array1);

  for (int i = 1; i <= 12; i++)
  {
    int *numericValues = new int[2];
    numericValues[0] = i;

    if (i + 12 == 24)
    {
      numericValues[1] = 0;
    }
    else
    {
      numericValues[1] = i + 12;
    }

    timeClockElements.push_back(ClockElement(numericValues, timeClockElementRangeFrom[i - 1], timeClockElementRangeTo[i - 1], HOUR));
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

    timeClockElements.push_back(ClockElement(numericValues, timeClockElementRangeFrom[rangeIndex], timeClockElementRangeTo[rangeIndex], MINUTE));

    rangeIndex++;
    minuteDistance -= 10;
  }
}

void setup()
{
  Serial.begin(9600);
  FastLED.addLeds<WS2812B, DATA_PIN>(leds, NUM_LEDS);
  createClockElements();
}

char color[3] = {255, 255, 255};
int hours = -1;
int minutes = -1;

String inString = "";

bool showUhrWord = true;
void loop()
{
  int colorIndex = 0;
  String command = "";
  String fullCommand = "";
  bool readCommand = true;
  bool isHour = true;
  if(Serial.available() > 0) {
    while(Serial.available() > 0){
      char nextChar = Serial.read();
      fullCommand += nextChar;
      if(readCommand){
        if(!isDigit(nextChar)){
          command += nextChar;
        } else {
          readCommand = false;
        }
      } 

      if(command == "setColor(" && !readCommand) 
      {
        //Set the color
        if(isDigit(nextChar))
        {
          inString += nextChar;
        }
        else if (nextChar == ',' || nextChar == ')')
        {
          color[colorIndex] = inString.toInt();
          colorIndex++;
          inString = "";
        }
      } 
      else if(command == "showFreya(" && !readCommand) 
      {
        if (nextChar == ',' || nextChar == ')')
        {
          showWordFreya();
          inString = "";
        }
      } 
      else if(command == "setTime(")
      {
        //Set the time
        if(isDigit(nextChar))
        {
          inString += nextChar;
        }
        else if (nextChar == ',' || nextChar == ')')
        {
          if(isHour)
          {
            hours = inString.toInt();
            isHour = false;
          } 
          else 
          {
            minutes = inString.toInt();
          }
          inString = "";
        }

        if(!isHour){
          tmElements_t tim_e;
          tim_e.Hour = hours;
          tim_e.Minute = minutes;
          RTC.write(tim_e);
        }
      }
    }
    Serial.println(fullCommand);
  } 
  tmElements_t tm;
  RTC.read(tm);

  int minutes = tm.Minute;
  int hours = tm.Hour;

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

  for (int i = 0; i < timeClockElements.size(); i++)
  {
    ClockElement clockElement = timeClockElements[i];
    for (int j = 0; j <= clockElement.GetNumericValuesArrayLength(); j++)
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
