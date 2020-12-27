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
                #self.reset_all_leds()
                self.show_hours(current_time.hour + 1)
                #self.show_base_elements()

                minute = 5 * math.floor(current_time.minute / 5)
                if minute == 0:
                    print("whole hour detected... not gonna show any vor / nach or minute leds")

                #self.show_minutes(minute)
                self.strip.show()
                time.sleep(10)
        except KeyboardInterrupt:
            print("Keyboard Interupt")

    def show_base_elements(self):
        for i in range(110, 112, 1):
            self.strip.setPixelColor(i, Color(255, 255, 255))
            self.strip.show()
        for i in range(113, 116, 1):
            self.strip.setPixelColor(i, Color(255, 255, 255))
            self.strip.show()

    def show_hours(self, hour):
        hour = self.hour_elements.get(hour)
        for i in range(hour.get_range_from(), hour.get_range_to(), 1):
            #print("setting led %d", i)
            self.strip.setPixelColor(i, Color(255, 255, 255))

    def show_minutes(self, rounded_minute):
        minute = self.minute_elements.get(rounded_minute)
        for i in range(minute.get_range_from(), minute.get_range_to(), 1):
            #print("setting led %d", i)
            self.strip.setPixelColor(i, Color(255, 255, 255))

    def reset_all_leds(self):
        # Reset time words
        for i in range(self.NUM_LEDS):
            # print("resetting %d", i)
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

        for i in range(0, 30, 5):
            print("Hello World")
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
