from flask_script import Server
from threading import Thread

from rpi_ws281x import *

from Clock import *

from flask import Flask


class CustomServer(Server):
    LED_COUNT = 125
    LED_PIN = 18
    LED_FREQ_HZ = 800000
    LED_DMA = 10
    LED_BRIGHTNESS = 255
    LED_INVERT = False
    LED_CHANNEL = 0

    def __call__(self, app, *args, **kwargs):
        self.app = app
        self.strip = self.setup_strip()
        self.clock = Clock(self.strip)

        thread = Thread(target=self.threaded_function, args=(self.clock,))
        thread.start()
        return Server.__call__(self, app, *args, **kwargs)

    def setup_strip(self):
        print("Setup strip")
        strip = Adafruit_NeoPixel(
            self.LED_COUNT,
            self.LED_PIN,
            self.LED_FREQ_HZ,
            self.LED_DMA,
            self.LED_INVERT,
            self.LED_BRIGHTNESS,
            self.LED_CHANNEL)

        strip.begin()
        return strip

    def freya(self):
        self.clock.freya()
        return "Freya"

    def threaded_function(self, clock):
        try:
            clock.start()
            print("")

        except KeyboardInterrupt:
            print("Keyboard Interupt")
