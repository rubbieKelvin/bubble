# this binary class, tursn bynary to string in case of sender
# and in cass of recv, it turns it into filr, returning path name
import os
import json
import base64
from PySide2.QtCore import Property, Slot, Signal, QObject

IMAGE_EXTENSIONS = ["png", "svg", "jpg", "jpeg", "gif"]
AUDIO_EXTENSIONS = ["mp3", "wav", "ogg", "m4a"]

class Binary(object):
	def __init__(self, filename=None):
		super(Binary, self).__init__()
		if filename is None:
			self.path = None
			self.filename = None
			self.fileext = None
			self.dec = None
			self.byte = None
		else:
			self.path, self.filename = os.path.split(filename)
			self.fileext = os.path.splitext(self.filename)[-1]
			self.dec = base64.b16encode(bytes(self.filename, "utf8")).decode("utf8")+base64.b16encode(os.urandom(4)).decode("utf8")
			try:
				with open(f"{self.path}\\{self.filename}", "rb") as file:
					self.byte = file.read()
				self.save()
			except Exception as e:
				raise e

	def save(self):
		with open(os.path.join("temp", f"{self.dec}{self.fileext}"), "wb") as file:
			file.write(self.byte)

	def __str__(self):
		data = dict(
			name = self.dec,
			ext  = self.fileext,
			data = self.to_str(self.byte)
		)
		return json.dumps(data)

	def to_str(self, byte):
		# byte is non ascii or maybe not
		res = base64.b85encode(byte)
		return res.decode("utf8")

	def parse(string):
		data = json.loads(string);

		res = Binary()
		res.path = "temp"
		res.filename = data["name"]
		res.fileext = data["ext"]
		res.dec = res.filename
		res.byte = res.from_str(data["data"])
		return res

	def from_str(self, string):
		res = bytes(string, "utf8")
		return base64.b85decode(res)

# file:///D:/rubbiesoft/Portfolio/InDevelopment/Bubble/bubble_client.ipynb

class Files(QObject):
	def __init__(self):
		super(Files, self).__init__()
		self.files = {}

	@Slot(int, str)
	def add(self, id, file):
		file = file[8:]
		self.files[id] = file

	@Slot(int)
	def remove(self, id):
		if self.files.get(id) is not None:
			del self.files[id]

	@Slot(result=str)
	def get(self):
		res = list(self.files.values())
		return json.dumps(res)

	@Slot()
	def clear(self):
		self.files = {}

	@Slot(str, result=bool)
	def is_image(self, filename):
		filename = filename.lower()
		return filename.split(".")[-1] in IMAGE_EXTENSIONS
