BUFSIZE = 4096
# BUFSIZE = 2048

from .client import Client
from .server import Server
import socket

def host():
	host_name = socket.gethostname()
	return [host_name, socket.gethostbyname(host_name)]
