# __init__
import os
import time
import json
import base64
import logging
import pprint
import sockdot
from threading import Thread
from .messaging import Message
from .binaries import Binary
from PySide2.QtCore import Property, Slot, Signal, QObject


PRINTER = pprint.PrettyPrinter()
PORT = 59187
PING_INTERVAL	 = 10
AUTH = dict(SECURITY_KEY = base64.b16encode(os.urandom(5)).decode("utf8"), WHITELIST = [], BLACKLIST = [], USE_WHITELIST = False)
CLIENT_ID = base64.b16encode(bytes(sockdot.host()[0], "utf8")).decode("utf8")+base64.b16encode(os.urandom(5)).decode("utf8")

# print("server-key:", AUTH["SECURITY_KEY"], "\nclient-id:", CLIENT_ID)
logging.basicConfig(format='%(levelname)s: %(asctime)s\t%(message)s', level=logging.INFO)

# headers
PROFILE_UPDATE 	= "PROFILE_UPDATE"	# used when client sends updated profile to server
CONTACT_UPDATE	= "CONTACT_UPDATE"	# used to give clients list of connected people
PING 			= "PING!PONG"		# used to check if client is still connected to server


# def print(*args, **kwargs):
# 	res = ""
# 	for arg in args:
# 		res += str(arg)
# 	PRINTER.pprint(res)


class Server(QObject):
	PERSON = 0
	GROUP = 1
	def __init__(self):
		super(Server, self).__init__()
		self.events = dict(
			on_running_changed = self.on_running_changed,
			on_data_recieved = self.on_data_recieved,
			on_error = self.on_error,
			on_connection_close = self.on_connection_close
		)
		self.server = sockdot.Server(port=PORT, event=self.events, auth=AUTH)
		# PERSON TYPE
		# id:str = {
		# name:str,
		# id:str
		# avatar:str,
		# phone:str,
		# mail:str,
		# ip:str,
		# type:int <PERSON>
		# }
		# GROUP TYPE
		# id:str{
		# name:str,
		# id:str
		# avatar:str,
		# type: int <GROUP>,
		# members:list <List of member's ids>
		# }
		self.people = dict()
		# {id:str=client:clientobject}
		self.clients = dict()

	runningChanged = Signal(bool)

	def on_connection_close(self, client):
		for c in self.clients:
			if self.clients[c] == client:
				break
		try:
			del self.clients[c]
			del self.people[c]

			# send every one updated contacts
			contacts = []
			for entity in self.people.values():
				if entity["type"] == Server.PERSON:
					contacts.append(entity)

			# tell everyone who's around
			reply = Message(body=json.dumps(contacts), type=Message.REQUEST, header=CONTACT_UPDATE)
			self.broadcast(str(reply), [self.clients[client] for client in self.clients])
		except KeyError as e:
			pass


	def on_error(self, exception, message):
		print(exception, message)

	def on_running_changed(self, running):
		self.runningChanged.emit(running)

	def on_data_recieved(self, client, data):
		# make data a message
		# first check if its a request or message
		# if its requests you're probably looking for headers
		# else broadcast to whom it may concern
		# msg is a Message type
		msg = Message.parse(data)
		if msg.type == Message.MESSAGE:
			# just figure out who to send it to
			if msg.to == "*":
				# send to everybody
				self.broadcast(data, [self.clients[client] for client in self.clients])
			else:
				# find recipient
				try:
					to = self.clients[msg.to]
					self.broadcast(data, [to,])
				except Exception as e:
					pass

		elif msg.type == Message.REQUEST:
			if msg.header == PROFILE_UPDATE:
				# parse message and update the shit
				data = json.loads(msg.body)
				id = data["id"]
				self.people[id] = dict(
					name = data.get("name"),
					avatar = data.get("avatar", ""),
					phone = data.get("phone"),
					mail = data.get("mail"),
					type = Server.PERSON,
					id = id
				)
				self.clients[id] = client

				# send every one updated contacts
				contacts = []
				for entity in self.people.values():
					if entity["type"] == Server.PERSON:
						contacts.append(entity)

				# tell everyone who's around
				reply = Message(body=json.dumps(contacts), type=Message.REQUEST, header=CONTACT_UPDATE)
				self.broadcast(str(reply), [self.clients[client] for client in self.clients])
			elif msg.header == PING:
				try:
					self.server.send(client, str(msg))
				except ConnectionResetError as e:
					try:
						del self.clients[msg.sender]
						del self.people[msg.sender]

						# send every one updated contacts
						contacts = []
						for entity in self.people.values():
							if entity["type"] == Server.PERSON:
								contacts.append(entity)

						# tell everyone who's around
						reply = Message(body=json.dumps(contacts), type=Message.REQUEST, header=CONTACT_UPDATE)
						self.broadcast(str(reply), [self.clients[client] for client in self.clients])
					except KeyError as e:
						pass
			else:
				pass

	def broadcast(self, data, clients):
		for client in clients:
			try:
				self.server.send(client, data)
			except ConnectionResetError as e:
				for c in self.clients:
					if self.clients[c] == client:
						break
				try:
					del self.clients[c]
					del self.people[c]

					# send every one updated contacts
					contacts = []
					for entity in self.people.values():
						if entity["type"] == Server.PERSON:
							contacts.append(entity)

					# tell everyone who's around
					reply = Message(body=json.dumps(contacts), type=Message.REQUEST, header=CONTACT_UPDATE)
					self.broadcast(str(reply), [self.clients[client] for client in self.clients])
				except KeyError as e:
					pass

	@Slot(result=str)
	def create(self):
		res = dict(error=None, key=None, domain=None)
		if sockdot.host()[1] == "127.0.0.1":
			res['error'] = "not connected to LAN"
		else:
			try:
				self.server.run()
				res["key"] = AUTH["SECURITY_KEY"]
				res["domain"] = sockdot.host()[0]
			except Exception as e:
				res["error"] = str(e)
		return json.dumps(res)

	@Slot()
	def close(self):
		self.server.kill()




class Client(QObject):
	def __init__(self):
		super(Client, self).__init__()
		self.events = dict(
			on_error				=	self.on_error,
			on_connected_changed 	=	self.on_connected_changed,
			on_handshake_ended		=	self.on_handshake_ended,
			on_data_recieved		=	self.on_data_recieved,
		)
		self.client = sockdot.Client(port=PORT, event=self.events)
		self.profile = dict(
			id 		=	CLIENT_ID,
			name 	= 	"Unknown",
			avatar	=	"",
			mail 	= 	"",
			phone 	= 	""
		)
		self.contacts = {}
		self.pinging = False
		self.messages = {}

	error = Signal(str)
	connectedChanged 	= Signal(bool)
	handshakeEnded 		= Signal(bool)
	contactsUpdated 	= Signal(str)
	messageRecieved 	= Signal(str)
	threadedProcessStarted = Signal(str) 	# ==> title:str
	threadedProcessEnded = Signal(bool)		# ==> successful:bool

	def on_data_recieved(self, data):
		# make data a message
		# first check if its a request or message
		# if its requests you're probably looking for headers
		# else read your message
		# msg is a Message type
		msg = Message.parse(data)
		if msg.type == Message.MESSAGE:
			# find who sent it and store
			# if it was sent to "*" store in "*" else strore in sender

			# print("\n\nDEBUG (recv)=====>")
			# print(msg)
			# print(self.messages)
			# print("<====== X\n\n")

			if msg.sender != self.profile["id"]:

				# save binaries, if there are any
				# clear binaries when saving is done,
				# to increase perfomance.
				# large data transferred betwen Cython and Js causes perfomance lag
				for file_ in msg.binaries:
					new_bin = Binary.parse(json.dumps(file_))
					new_bin.save()
					file_["data"] = "data has been cleared (recv)"


				if msg.to == "*":
					if self.messages.get("*") is None:
						self.messages["*"] = []
					self.messages["*"].append(msg)
				else:
					if self.messages.get(msg.sender) is None:
						self.messages[msg.sender] = []
					self.messages[msg.sender].append(msg)

				self.messageRecieved.emit(str(msg))

		elif msg.type == Message.REQUEST:
			if msg.header == CONTACT_UPDATE:

				# print("\n here's body========>", msg.body, type(msg.body), "\n")
				contacts = json.loads(msg.body)

				for contact in contacts:
					self.contacts[contact["id"]] = contact

				self.contactsUpdated.emit(msg.body)

			else:
				pass

	def on_handshake_ended(self, result):
		self.handshakeEnded.emit(result)

	def on_connected_changed(self, connected):
		self.connectedChanged.emit(connected)
		if connected:
			# start pinging
			# send server your profile
			# not expecting anything in return
			# just for recognition
			self.pinging = True
			self.serve_updated_profile()
			self.start_pinging()
			pass
		else:
			self.pinging = False

	@Slot()
	def serve_updated_profile(self):
		profile = json.dumps(self.profile)
		msg = Message(
			sender=self.profile.get("id", ""),
			body=profile,
			type=Message.REQUEST,
			header=PROFILE_UPDATE
		)
		self.client.send(str(msg))


	def on_error(self, exception, message):
		self.error.emit(message)
		print(exception, message)

	@Slot(result=bool)
	def connected(self):
		return self.client.connected

	@Slot(str, str)
	def set_profile(self, key, value):
		if key != "id":
			self.profile[key] = value

	@Slot(str, result=str)
	def get_profile(self, key):
		return self.profile.get(key, "")

	@Slot(result=str)
	def my_id(self):
		return self.profile["id"]

	@Slot(str, str)
	def send(self, to, message):
		msg = Message(
			body=message,
			sender=self.profile["id"],
			to=to
		)
		# print("\n\nDEBUG (send)=====>")
		# print(msg)
		# print(self.messages)
		# print("<====== X\n\n")

		self.messageRecieved.emit(str(msg))
		# send
		self.client.send(str(msg))

		# find who youre sending to and store
		if self.messages.get(msg.to) is None:
			self.messages[msg.to] = []
		self.messages[msg.to].append(msg)

	@Slot(str, str, str)
	def send_binary(self, to, message, file):
		# threaded process
		self.threadedProcessStarted.emit("sending atachments...")
		Thread(target=self.threaded_send_binary, args=(to, message, file)).start()

	def threaded_send_binary(self, to, message, file):
		file = json.loads(file)
		files = [json.loads(str(Binary(x))) for x in file]

		print("\nHERE ======>", to, message, file, "\n")

		msg = Message(
			body=message,
			sender=self.profile["id"],
			to=to,
			binaries = files
		)

		# print("\n\nDEBUG (send - with files)=====>")
		# print(msg)
		# print(self.messages)
		# print("<====== X\n\n")

		# send
		self.client.send(str(msg))

		# no need to save binaries here
		# clear binaries,
		# to increase perfomance.
		# large data transferred betwen Cython and Js causes perfomance lag
		for file_ in msg.binaries:
			file_["data"] = "data has been cleared (send)"

		self.messageRecieved.emit(str(msg))
		# find who youre sending to and store
		if self.messages.get(msg.to) is None:
			self.messages[msg.to] = []
		self.messages[msg.to].append(msg)


		# finish
		self.threadedProcessEnded.emit(True)

	@Slot(str, str, result=str)
	def connect(self, domain, key):
		# connect to a domain
		# first check if the user is already connected to somthing
		# set the host and auth key to get started
		res = dict(error=None, message="")
		if self.client.connected:
			res["message"] = "you are already connected to a server"
		else:
			try:
				self.client.sethost(domain)
				self.client.connect(key)
				res["message"] = f"connecting to {domain}..."
			except socket.gaierror:
				res["error"] = f"domain doesnt exist"
		return json.dumps(res)

	@Slot()
	def close(self):
		self.pinging = False
		self.client.close()

	@Slot(str, result=str)
	def get_messages(self, chatid):
		msg = self.messages.get(chatid, [])
		msg = [vars(x) for x in msg]
		return json.dumps((msg))


	def start_pinging(self):
		Thread(target=self._start_pinging).start()

	def _start_pinging(self):
		while self.pinging:
			time.sleep(PING_INTERVAL)
			msg = Message(header=PING, type=Message.REQUEST, sender=self.profile.get("id"))
			try:
				if self.client.is_busy:
					pass
				else:
					self.client.send(str(msg))
					logging.info("ping successful...")
			except Exception as e:
				self.client.close()

	@Slot(str, result=str)
	def get_contact_by_id(self, id):
		if id == "*":
			res = dict(
				id 		=	"*",
				name 	= 	str(self.client.host),
				avatar	=	"70",
				mail 	= 	"This Contact doesnt have an email",
				phone 	= 	"This Contact doesnt have a phone"
			)
		elif self.contacts.get(id) is not None:
			res = self.contacts[id]
		else:
			res = dict(
				id 		=	id,
				name 	= 	"Unknown",
				avatar	=	"",
				mail 	= 	"unavailable",
				phone 	= 	"unavailable"
			)

		# print("\nDEBUGGING ===>")
		# print("id", id)
		# print("contact", self.contacts.get(id))
		# print("<======x\n")

		return json.dumps(res)
