#!/usr/bin/python3.7

import sys
import socket
from datetime import datetime

# Define target

if len(sys.argv) == 2:
    target = socket.gethostbyname(sys.argv[1]) # Translate a hostname to IPv4
else:
    print('Invalid amount of arguments')
    print('Syntax:\n\t$ python3 scanner.py <ip>')
    sys.exit()

# Add a banner
print("-" * 50)
print("Scanning target %s" % target)
print("Time started: %s" % str(datetime.now()))
print("-" * 50)

try:
    for port in range(50,85):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        socket.setdefaulttimeout(1)
        result = s.connect_ex((target,port)) # returns error indicator
        print("Checking port {}...".format(port))
        if result == 0:
            print("Port {} is open".format(port))
        s.close()
except KeyboardInterrupt:
    print("\nExiting program.")
    sys.exit()
except socket.gaierror:
    print("Hostname could not be resolved.")
    sys.exit()
except socket.error:
    print("Couldn't connect to server.")
    sys.exit()
