import os, sys, json
from PySide2.QtGui import QIcon
from PySide2.QtWidgets import QApplication
from PySide2.QtQml import QQmlApplicationEngine, qmlRegisterType

from bubble import Client, Server
from bubble.user import User, Bubble
from bubble.binaries import Files

appname = "bubble"
org = "rubbiesoft"

# create temp folder
if not os.access("temp", os.F_OK): os.mkdir("temp")

# create data files
user_json = os.path.join("data", "user.json")
avatar_json = os.path.join("data", "avatars.json")
if not os.access(user_json, os.F_OK):
	data = {
		"user":{
			"name":	os.environ.get("USERNAME", "Unknown"),
			"mail": "no mail address",
			"phone": "no phone number",
			"avatar": "0"
		},
		"settimgs":{
			"sounds": True,
			"sys-tray": True
		}
	}
	with open(user_json, "w") as file:
		json.dump(data, file)

# plugins
server = Server()
client = Client()
user = User(user_json, avatar_json)
files = Files()
bubb = Bubble()

os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"

# create application objects
app = QApplication(sys.argv)
app.setWindowIcon(QIcon("data\\icon.png"))
app.setApplicationName(appname)
app.setOrganizationName(org)
app.setOrganizationDomain("org.%s.%s" %(org, appname.lower()))

# create qml app engine
engine = QQmlApplicationEngine()

# register plugins
engine.rootContext().setContextProperty("server", server)
engine.rootContext().setContextProperty("client", client)
engine.rootContext().setContextProperty("user", user)
engine.rootContext().setContextProperty("files", files)
engine.rootContext().setContextProperty("bubble", bubb)

# load qml file
engine.load("ui/app.qml")

engine.quit.connect(app.quit)
sys.exit(app.exec_())
