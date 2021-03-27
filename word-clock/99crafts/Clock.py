from ClockElement import *
import time
from time import ctime
from datetime import datetime
import ntplib
from rpi_ws281x import *
import math


class Clock:
    hours = 0
    minutes = 0

    timeClockElementRangeFrom = [44, 51, 40, 33, 55, 22, 26, 18, 3, 0, 58, 13, -1, 117, 106, 92, 99, 62]
    timeClockElementRangeTo = [48, 55, 44, 37, 59, 27, 32, 22, 7, 4, 61, 18, -1, 121, 110, 99, 106, 66]
    heartLEDs = [38, 48, 62, 69, 83, 71, 81, 73, 58, 50]

    hour_elements = {}
    minute_elements = {}

    NUM_LEDS = 125

    def __init__(self, strip):
        self.strip = strip
        self.create_clock_elements()

    def start(self):
        try:
            print("started clock...")
            ntp_client = ntplib.NTPClient()
            while True:
                print("getting current time from internet...")
                response = ntp_client.request('europe.pool.ntp.org', version=3)
                current_time = datetime.strptime(ctime(response.tx_time), "%a %b %d %H:%M:%S %Y")
                print("Current time is: " + current_time.strftime("%a %b %d %H:%M:%S %Y"))

                print("setting clock LEDs to the current time")
                self.reset_all_leds()
                self.show_base_elements()
                hour = self.show_minutes(current_time.minute, current_time.hour)
                self.show_hours(hour)
                print("Minuten: ", current_time.minute)
                print("Stunden: ", current_time.hour)
                if 0 <= current_time.minutte < 5:
                    for i in range(8, 11, 1):
                        #print("", i)
                        self.strip.setPixelColor(i, Color(255, 255, 255))

                self.strip.show()
                time.sleep(60)
        except KeyboardInterrupt:
            print("Keyboard Interupt")

    def freya(self):
        for i in range(75, 79, 1):
            self.strip.setPixelColor(i, Color(0, 255, 0))
            self.strip.show()
        for i in range(len(self.heartLEDs)):
            self.strip.setPixelColor(i, Color(0, 255, 0))
            time.sleep(0.5)
            self.strip.show()
        time.sleep(1)
        for i in range(len(self.heartLEDs)):
            self.strip.setPixelColor(i, Color(0, 0, 0))
            self.strip.show()

    def show_base_elements(self):
        for i in range(110, 112, 1):
            self.strip.setPixelColor(i, Color(255, 255, 255))
            self.strip.show()
        for i in range(113, 116, 1):
            self.strip.setPixelColor(i, Color(255, 255, 255))
            self.strip.show()

    def show_hours(self, hour):
        print(self.hour_elements.get(hour).led_from)
        self.show_clock_element(self.hour_elements.get(hour))

    def show_minutes(self, minute, hour):
        if minute != 0:
            if (25 <= minute < 30) or (35 <= minute < 40):
                minute_element = self.minute_elements.get(5)
                self.show_clock_element(minute_element)
                if 25 <= minute < 30:
                    self.show_vor_word()
                elif 35 <= minute < 40:
                    self.show_nach_word()
            if 60 - minute > 35 and not (0 <= minute < 5):
                self.show_nach_word()
            elif 60 - minute < 21 and not (0 <= minute < 5):
                self.show_vor_word()
            if 60 - minute < 25 or 25 <= minute < 30 or 35 <= minute < 40 or 30 <= minute < 35:
                hour += 1
            self.show_left_over_minute_leds(minute % 5)

        self.show_clock_element(self.minute_elements.get(5 * math.floor(minute / 5)))
        return hour

    def show_clock_element(self, element):
        for i in range(element.get_range_from(), element.get_range_to(), 1):
            #print("", i)
            self.strip.setPixelColor(i, Color(255, 255, 255))

    def show_vor_word(self):
        for i in range(85, 88, 1):
            #print("", i)
            self.strip.setPixelColor(i, Color(255, 255, 255))

    def show_left_over_minute_leds(self, left_over_minutes):
        for i in range(124, 124 - left_over_minutes, -1):
           # print("", i)
            self.strip.setPixelColor(i, Color(255, 255, 255))

    def show_nach_word(self):
        for i in range(66, 70, 1):
            #print("", i)
            self.strip.setPixelColor(i, Color(255, 255, 255))

    def reset_all_leds(self):
        # Reset time words
        for i in range(self.NUM_LEDS):
            #print("", i)
            self.strip.setPixelColor(i, Color(0, 0, 0))
        print("reset all leds to white")

    def create_clock_elements(self):
        clock_element_index = 0
        self.create_minute_elements(self.create_hour_elements(clock_element_index))

    def create_hour_elements(self, clock_element_index):
        for i in range(12):
            numeric_value_am = i
            numeric_value_pm = i + 12
            if i + 12 == 24:
                numeric_value_pm = 0
            if i == 0 or i == 12:
                print("Setting range for hour 12")
                self.hour_elements[numeric_value_am] = ClockElement(13,
                                                                18,
                                                                ClockElementType(1))
                self.hour_elements[numeric_value_pm] = ClockElement(13,
                                                                18,
                                                                ClockElementType(1))
            else:
                self.hour_elements[numeric_value_am] = ClockElement(self.timeClockElementRangeFrom[i - 1],
                                                                self.timeClockElementRangeTo[i - 1],
                                                                ClockElementType(1))
                self.hour_elements[numeric_value_pm] = ClockElement(self.timeClockElementRangeFrom[i - 1],
                                                                self.timeClockElementRangeTo[i - 1],
                                                                ClockElementType(1))

            clock_element_index += 1
        return clock_element_index

    def create_minute_elements(self, clock_element_index):
        minute_distance = 60
        range_index = 12

        for i in range(0, 35, 5):
            numeric_value_am = i
            numeric_value_pm = i + minute_distance

            if i == 30:
                range_index -= 1
            self.minute_elements[numeric_value_am] = ClockElement(self.timeClockElementRangeFrom[range_index],
                                                                  self.timeClockElementRangeTo[range_index],
                                                                  ClockElementType(2))
            self.minute_elements[numeric_value_pm] = ClockElement(self.timeClockElementRangeFrom[range_index],
                                                                  self.timeClockElementRangeTo[range_index],
                                                                  ClockElementType(2))
            range_index += 1
            minute_distance -= 10
            clock_element_index += 1
