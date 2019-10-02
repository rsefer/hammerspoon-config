#!/usr/bin/env python3
import sys
import telnetlib

telnet = telnetlib.Telnet(sys.argv[1], sys.argv[2])
full_command = sys.argv[3] + " " + sys.argv[4]
telnet.write(full_command.encode("ASCII") + b"\r")
response = telnet.read_until(b"\r", timeout=0.5)
