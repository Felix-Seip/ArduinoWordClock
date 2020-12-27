from flask import Flask
from flask_script import Manager

from rpi_ws281x import *
import argparse

import CustomServer

LED_COUNT = 124
LED_PIN = 18
LED_FREQ_HZ = 800000
LED_DMA = 10
LED_BRIGHTNESS = 255
LED_INVERT = False
LED_CHANNEL = 0

strip = Adafruit_NeoPixel(
    LED_COUNT,
    LED_PIN,
    LED_FREQ_HZ,
    LED_DMA,
    LED_INVERT,
    LED_BRIGHTNESS,
    LED_CHANNEL)

strip.begin()

manager = Manager(Flask(__name__))
manager.add_command('runserver', CustomServer(strip))
manager.run()
