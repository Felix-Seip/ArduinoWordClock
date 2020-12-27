from enum import Enum


class ClockElementType(Enum):
    HOUR = 1
    MINUTE = 2
    WORD = 3


class ClockElement:
    def __init__(self, numeric_value_am, numeric_value_pm, led_from, led_to, element_type):
        self.numeric_value_am = numeric_value_am
        self.numeric_value_pm = numeric_value_pm
        self.led_from = led_from
        self.led_to = led_to
        self.element_type = element_type

    def get_range_from(self):
        return self.led_from

    def get_range_to(self):
        return self.led_to

    def get_numeric_value_am(self):
        return self.numeric_value_am

    def get_numeric_value_pm(self):
        return self.numeric_value_pm