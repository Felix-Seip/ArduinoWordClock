from flask import Flask
from flask_script import Manager, Server

from threading import Thread
from time import sleep

import time
from rpi_ws281x import *
import argparse

# LED strip configuration:
LED_COUNT = 124  # Number of LED pixels.
LED_PIN = 18  # GPIO pin connected to the pixels (18 uses PWM!).
# LED_PIN        = 10      # GPIO pin connected to the pixels (10 uses SPI
# /dev/spidev0.0).
LED_FREQ_HZ = 800000  # LED signal frequency in hertz (usually 800khz)
LED_DMA = 10  # DMA channel to use for generating signal (try 10)
LED_BRIGHTNESS = 255  # Set to 0 for darkest and 255 for brightest
# True to invert the signal (when using NPN transistor level shift)
LED_INVERT = False
LED_CHANNEL = 0  # set to '1' for GPIOs 13, 19, 41, 45 or 53

strip = Adafruit_NeoPixel(
    LED_COUNT,
    LED_PIN,
    LED_FREQ_HZ,
    LED_DMA,
    LED_INVERT,
    LED_BRIGHTNESS,
    LED_CHANNEL)

strip.begin()

app = Flask(__name__)
manager = Manager(app)


@app.route('/')
def hello_world():
    strip.setPixelColor(0, Color(255, 0, 0))
    return 'Hello, World!'


@app.route('/freya')
def freya():
    return 'Freya'


# Remeber to add the command to your Manager instance
manager.add_command('runserver', CustomServer())

# if __name__ == "__main__":
manager.run()