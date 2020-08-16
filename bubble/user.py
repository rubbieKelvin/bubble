import os
import json
from PySide2.QtCore import Property, Slot, Signal, QObject


class User(QObject):
	def __init__(self, filename, avatar_file):
		super(User, self).__init__()
		self.file = filename
		with open(self.file) as file: self.data = json.load(file)
		with open(avatar_file) as file: self.avatars = json.load(file)

	nameChanged = Signal(str)
	mailChanged = Signal(str)
	phoneChanged = Signal(str)
	avatarChanged = Signal(str)

	@Property(str, notify=nameChanged)
	def name(self):
		return self.data["user"]["name"]

	@Property(str, notify=phoneChanged)
	def phone(self):
		return self.data["user"]["phone"]

	@Property(str, notify=mailChanged)
	def mail(self):
		return self.data["user"]["mail"]

	@Property(str, notify=avatarChanged)
	def avatar(self):
		return self.data["user"]["avatar"]

	@Slot(str)
	def set_name(self, name):
		self.data["user"]["name"] = name
		self.nameChanged.emit(name)

	@Slot(str)
	def set_phone(self, phone):
		self.data["user"]["phone"] = phone
		self.phoneChanged.emit(phone)

	@Slot(str)
	def set_mail(self, mail):
		self.data["user"]["mail"] = mail
		self.mailChanged.emit(mail)

	@Slot(str)
	def set_avatar(self, avatar):
		self.data["user"]["avatar"] = avatar
		self.avatarChanged.emit(avatar)

	@Slot(str, result=str)
	def get_avatar_by_id(self, id):
		res = json.dumps(self.avatars[id])
		return res

	@Slot(result=str)
	def get_all_avatars(self):
		avatars = list(self.avatars.values())
		return json.dumps(avatars)

	@Slot()
	def save(self):
		with open(self.file, "w") as file:
			json.dump(self.data, file)

class Bubble(QObject):
	def __init__(self):
		super(Bubble, self).__init__()

	@Slot(result=str)
	def cwd(self):
		r = os.getcwd()
		r = r.split("\\")

		res = ""
		for i in r:
			res += (i+"/")

		return res

	@Slot(str, result=str)
	def split(self, path):
		return os.path.split(path)[-1]

	@Slot(str)
	def debug(self, value):
		print("\nBUBBLE DEBUGGING ####################")
		value = json.loads(value)
		print("type:", type(value))
		print("value:", value)
		print("################## DEBUG COMPLETE\n")
