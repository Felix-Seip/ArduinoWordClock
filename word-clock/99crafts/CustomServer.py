from flask_script import Server
from threading import Thread

from rpi_ws281x import *

import Clock

class CustomServer(Server):
    app = ""

    def __call__(self, strip, app, *args, **kwargs):
        self.app = app
        self.strip = strip

        thread = Thread(target=self.threaded_function, args=(strip,))
        thread.start()
        return Server.__call__(self, app, *args, **kwargs)

    @app.route('/')
    def hello_world(self):
        self.strip.setPixelColor(0, Color(255, 0, 0))
        return 'Hello, World!'

    @app.route('/freya')
    def freya(self):
        return 'Freya'

    @staticmethod
    def threaded_function(strip):
        try:
            clock = Clock()
            clock.start()

        except KeyboardInterrupt:
            print("Keyboard Interupt")
