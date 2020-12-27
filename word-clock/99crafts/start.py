from flask import Flask
from flask_script import Manager

from CustomServer import CustomServer

app = Flask(__name__)

manager = Manager(app)
server = CustomServer()
manager.add_command('runserver', server)


@app.route('/freya')
def freya():
    return server.freya()


manager.run()

if __name__ == "__main__":
    manager.run()
