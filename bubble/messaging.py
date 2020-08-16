import json
import time

# every message has the following structure
# {
# 	"id"		: 	<message id>,
# 	"time"		: 	<time sent>
# 	"to"		: 	<reciever's id>,
# 	"body"		: 	<message body>,
# 	"type"		:	<message or request>,
# 	"sender"	: 	<sender's id>,
# 	"header"	: 	<message title>
# 	"binaries"	:	[
# 		{
# 			"name":	<binary name>,
# 			"data": <byte>,
# 			"type": <file type>
# 		}
# 	],
# 	'reply_to'	:	<reply message id>
# }

class Message(object):
	MESSAGE = 0
	REQUEST = 1
	GROUP	= 2
	def __init__(self, body="", sender="", to="*", type=MESSAGE, reply_to="", binaries=[], header="", **kwargs):
		super(Message, self).__init__()
		# auto
		self.id 		= str(self.__hash__())	# TODO: work on making this id unique
		self.time 		= time.strftime("%I:%M:%S %p")

		# req
		self.to 		= to
		self.body 		= body
		self.type 		= type
		self.sender 	= sender
		self.header		= header
		self.binaries 	= binaries
		self.reply_to 	= reply_to

	def __str__(self):
		return json.dumps(vars(self))

	def parse(message):
		return Message(**json.loads(message))
