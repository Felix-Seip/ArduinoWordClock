from ClockElement import *


class Clock:
    hours = 0
    minutes = 0

    # Eins, Zwei, Drei, Vier, Fünf, Sechs, Sieben, Acht, Neun, Zehn, Elf, Zwölf, Null, Fünf, Zehn, Viertel, Zwanzig, Halb
    timeClockElementRangeFrom = {44, 51, 40, 33, 55, 22, 26, 18, 3, 0, 58, 13, -1, 117, 106, 92, 99, 62}
    timeClockElementRangeTo = {48, 55, 44, 37, 59, 27, 32, 22, 7, 4, 61, 18, -1, 121, 110, 99, 106, 66}
    heartLEDs = {38, 48, 62, 69, 83, 71, 81, 73, 58, 50}

    def __init__(self, strip):
        self.strip = strip
        self.create_clock_elements()

    def start(self):
        print("started clock")
        while True:
            # do clock stuff
            self.strip.setPixelColor(120, 255)
            self.strip.show()

    def create_clock_elements(self):
        elements = []
        clock_element_index = 0

        for i in range(12):
            numeric_value_am = i
            numeric_value_pm = i + 12
            if i + 12 == 24:
                numeric_value_pm = 0
            elements.insert(ClockElement(numeric_value_am, numeric_value_pm, self.timeClockElementRangeFrom[i - 1],
                                         self.timeClockElementRangeTo[i - 1], ClockElementType(1)))
            clock_element_index += 1

        minuteDistance = 60
        rangeIndex = 12

        for i in range(0, 30, 5):
            print("Hello World")
            numeric_value_am = i
            numeric_value_pm = i + minuteDistance

            if i == 30:
                rangeIndex -= 1
            elements.insert(ClockElement(numeric_value_am, numeric_value_pm, self.timeClockElementRangeFrom[rangeIndex],
                                         self.timeClockElementRangeTo[rangeIndex], ClockElementType(2)))
            rangeIndex += 1
            minuteDistance -= 10
            clock_element_index += 1
