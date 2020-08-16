import os
import json
import base64
import socket
import logging
import threading

from . import BUFSIZE
from . import response
from . import events

class Server:
	_LOGS_FILE = "server.log"
	_EVENTS = {
		"on_data_recieved": events.void,	# param: client, data
		"on_connection_open": events.void,	# param: client
		"on_connection_close": events.void,	# param: client
		"on_server_destruct": events.void,	# no param
		"on_error": events.void,			# param: exception, message
		"on_port_changed": events.void,		# param: port
		"on_running_changed": events.void	# param: running
	}
	def __init__(self, port=80, debug=False, auth=None, event={}):
		super(Server, self).__init__()
		self.sock = None
		self.port = port
		self.clients = set()
		self.debug = debug

		# extract auth file
		self.auth = {
			"SECURITY_KEY": "",
			"WHITELIST": [],
			"BLACKLIST": [],
			"USE_WHITELIST": False
		}
		if auth is None:
			self.auth = auth
		elif type(auth) is dict:
			self.auth.update(auth)
		else:
			with open(auth) as file:
				try:
					self.auth.update(json.load(file))
				except json.JSONDecodeError as e:
					logging.error("error reading auth file")


		# Initialize log file format.
		# logging.basicConfig(
		# 	filename=Server._LOGS_FILE,
		# 	filemode='w',
		# 	format='%(levelname)s: %(asctime)s\t%(message)s',
		# 	level=logging.DEBUG if self.debug else logging.INFO
		# )

		# get events
		self.events = Server._EVENTS.copy()
		self.events.update(event.get() if type(event)==events.Event else event.copy())

	def updateevent(self, event):
		self.events.update(event.get() if type(event)==events.Event else event.copy())

	def updateauth(self, auth, filename=None):
		self.auth.update(auth)
		if filename is not None:
			with open(filename) as file:
				json.dumps(self.auth, file)

	@property
	def host(self):
		return socket.gethostname()

	@property
	def alive(self):
		return self.sock is not None

	def setport(self, port):
		self.port = port
		self.events["on_port_changed"](port)

	def run(self):
		self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.sock.bind((self.host, self.port))
		self.sock.listen(5)
		self.events["on_running_changed"](self.alive)
		threading.Thread(target=self.run_).start()

	def run_(self):
		logging.info("server started!")
		while self.alive:
			try:
				logging.info("waiting for connection")
				client, addr = self.sock.accept()
				logging.info(f"client {addr} joined")
				self.events["on_connection_open"](client)
				threading.Thread(target=self.handshake, args=(client, addr)).start()
			except OSError as e:
				err_msg = "error occured during server shutdown"
				self.events["on_error"](e, err_msg)
				self.events["on_server_destruct"]()
				logging.error(err_msg)
				break

	def handshake(self, client, addr):
		auth = self.recv(client)
		rep = self.authenticate(auth, addr)
		logging.info(f"handshake response from client {addr[0]}: {rep}")
		if rep:
			# handle client
			logging.info(f"handshake with client {addr} successfull")
			self.clients.add(client)
			self.send(client, response.HANDSHAKE_SUCCESSFUL)
			threading.Thread(target=self.manageclient, args=(client,)).start()
		else:
			# dump client
			logging.error(f"handshake with client {addr} unsuccessfull")
			self.send(client, response.HANDSHAKE_UNSUCCESSFUL)
			client.close()

	def authenticate(self, data, addr):
		res = False
		if self.auth is not None:
			# check security key
			if self.auth["SECURITY_KEY"]:
				if data == self.auth["SECURITY_KEY"]:
					res = True
				else:
					return False
			# check in whitelist
			if not self.auth["USE_WHITELIST"]:
				res = True
			else:
				if addr[0] in self.auth["WHITELIST"]:
					res = True
				else:
					return False
			# check in blacklist
			if addr in self.auth["BLACKLIST"]:
				return False
			else:
				res = True
		else:
			return True
		return res

	def send(self, client, data):
		if data:
			br = base64.b85encode(os.urandom(4)).decode("utf8")
			data = f"{br}::{data}::</{br}>"
			data = bytes(data, "utf8")
			res = client.send(data)
			return res
		return 0

	def recv(self, client):
		res = client.recv(BUFSIZE).decode("utf8")

		br = res.split("::")[0]
		while not res.endswith(f"</{br}>"):
			res = res+client.recv(BUFSIZE).decode("utf8")

		return res[len(br)+2:][:-len(br)-5]

	def broadcast(self, data):
		for client in self.clients:
			self.send(client, data)

	def manageclient(self, client):
		while self.alive:
			try:
				data = self.recv(client)
				self.events["on_data_recieved"](client, data)
			except ConnectionResetError:
				# client closed connection
				self.events["on_connection_close"](client)
				logging.info("client {client} left")
				self.clients.remove(client)
				break

	def kill(self):
		logging.info("server shutdown")
		if self.alive: self.sock.close()
		self.sock = None
		self.events["on_running_changed"](self.alive)
		self.client = set()
