#include <Vector.h>

#include <Wire.h>
#include <TimeLib.h>
#include <DS1307RTC.h>

#include <FastLED.h>

#include "ClockElement.h"

#define NUM_LEDS 121
#define NUM_CLOCK_ELEMENTS 19

#define DATA_PIN 5

// Define the array of leds
CRGB leds[NUM_LEDS];

Vector<ClockElement> timeClockElements;

//   Eins, Zwei, Drei, Vier, Fünf, Sechs, Sieben, Acht, Neun, Zehn, Elf, Zwölf, Null, Fünf, Zehn, Viertel, Zwanzig, Halb
int timeClockElementRangeFrom[NUM_CLOCK_ELEMENTS] = { 44,    51,   40,   33,   55,   22,    26,     18,   3,    0,    58,  13,  -1,   117,  106,  92,      99,      62  };
int timeClockElementRangeTo[NUM_CLOCK_ELEMENTS]   = { 48,    55,   44,   37,   59,   27,    32,     22,   7,    4,    61,  18,  -1,   121,  110,  99,      106,     66  };

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
  Wire.begin();
  FastLED.addLeds<WS2812B, DATA_PIN>(leds, NUM_LEDS);
  createClockElements();
}

void loop()
{
  tmElements_t tm;
  RTC.read(tm);

  int minutes = tm.Minute;
  int hours = tm.Hour;

  bool showUhrWord = true;

  showBasicClockElements();
  resetAllLEDs();
  showMinuteLEDs(minutes, hours, showUhrWord);
  showHourLEDs(hours);

  if (showUhrWord)
  {
    //Light up the LEDs for the word "UHR"
    leds[8] = CRGB(255, 255, 255);
    leds[9] = CRGB(255, 255, 255);
    leds[10] = CRGB(255, 255, 255);
  }

  FastLED.show();
}

void showHourLEDs(int &hours) {
  ClockElement clockElement = findClockElementByNumericValueAndType(hours, HOUR);
  setColorForClockElement(clockElement, 255, 255, 255);
}

void showMinuteLEDs(int minutes, int &hours, bool &showUhrWord) {
  if ((minutes % 5) != 0) {
    return;
  }
  
  ClockElement clockElement = findClockElementByNumericValueAndType(minutes, MINUTE);

  if (minutes == 0) {
    showUhrWord = true;
  }
  else {
    showUhrWord = false;
  }

  if (minutes != 0) {
    if (minutes == 25 || minutes == 35)
    {
      ClockElement element = findClockElementByNumericValueAndType(5, MINUTE);
      setColorForClockElement(element, 255, 255, 255);

      if (minutes == 25)
      {
        showWordVor();
      }
      else if (minutes == 35)
      {
        showWordNach();
      }
    }

    if (60 - minutes > 35)
    {
      showWordNach();
    }
    else if (60 - minutes < 25)
    {
      showWordVor();
    }

    if(60 - minutes < 25 || minutes == 25 || minutes == 35 || minutes == 30) {
      hours = hours + 1;
    }
  }

  setColorForClockElement(clockElement, 255, 255, 255);
}

void resetAllLEDs() {
  //Reset time words
  leds[8] = CRGB(0, 0, 0);
  leds[9] = CRGB(0, 0, 0);
  leds[10] = CRGB(0, 0, 0);

  leds[66] = CRGB(0, 0, 0);
  leds[67] = CRGB(0, 0, 0);
  leds[68] = CRGB(0, 0, 0);
  leds[69] = CRGB(0, 0, 0);

  leds[85] = CRGB(0, 0, 0);
  leds[86] = CRGB(0, 0, 0);
  leds[87] = CRGB(0, 0, 0);

  for (int i = 0; i < timeClockElements.size(); i++)
  {
    ClockElement clockElement = timeClockElements[i];
    for (int k = clockElement.GetRangeFrom(); k < clockElement.GetRangeTo(); k++)
    {
      leds[k] = CRGB(0, 0, 0);
    }
  }
}

void showBasicClockElements() {
  //Light up the LEDs for the word "ES"
  leds[110] = CRGB(255, 255, 255);
  leds[111] = CRGB(255, 255, 255);

  //Light up the LEDs for the word "IST"
  leds[113] = CRGB(255, 255, 255);
  leds[114] = CRGB(255, 255, 255);
  leds[115] = CRGB(255, 255, 255);
}

void showWordVor() {
  //Light up the LEDs for the word "VOR"
  leds[85] = CRGB(255, 255, 255);
  leds[86] = CRGB(255, 255, 255);
  leds[87] = CRGB(255, 255, 255);
}

void showWordNach() {
  //Light up the LEDs for the word "NACH"
  leds[66] = CRGB(255, 255, 255);
  leds[67] = CRGB(255, 255, 255);
  leds[68] = CRGB(255, 255, 255);
  leds[69] = CRGB(255, 255, 255);
}

void setColorForClockElement(ClockElement clockElement, int r, int g, int b) {
  for (int k = clockElement.GetRangeFrom(); k < clockElement.GetRangeTo(); k++)
  {
    leds[k] = CRGB(255, 255, 255);
  }
}

ClockElement findClockElementByNumericValueAndType(int numericValue, CLOCK_ELEMENT_TYPE elementType) {
  ClockElement foundElement;

  for (int i = 0; i < timeClockElements.size(); i++)
  {
    ClockElement clockElement = timeClockElements[i];
    for (int j = 0; j <= clockElement.GetNumericValuesArrayLength(); j++)
    {
      if (numericValue == clockElement.GetNumericValueAtIndex(j) && clockElement.GetClockElementType() == elementType)
      {
        return timeClockElements[i];
      }
    }
  }

  return foundElement;
}
