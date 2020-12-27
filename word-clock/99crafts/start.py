from flask import Flask
from flask_script import Manager

#from rpi_ws281x import *
import argparse

from CustomServer import CustomServer

LED_COUNT = 125
LED_PIN = 18
LED_FREQ_HZ = 800000
LED_DMA = 10
LED_BRIGHTNESS = 255
LED_INVERT = False
LED_CHANNEL = 0

strip = ""

# strip.begin()

app = Flask(__name__)
manager = Manager(app)
manager.add_command('runserver', CustomServer(strip, app))
manager.run()
