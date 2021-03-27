from flask import Flask
from flask_script import Manager
from urllib.request import urlopen
from urllib.error import URLError
from CustomServer import CustomServer

app = Flask(__name__)

manager = Manager(app)
server = CustomServer()
manager.add_command('runserver', server)


@app.route('/freya')
def freya():
    return server.freya()

while True:
    try:
        response = urlopen("https://google.com")
        break
    except URLError:
        pass

manager.run()

if __name__ == "__main__":
    manager.run()
