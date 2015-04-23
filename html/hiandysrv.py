#!/usr/bin/python2
import socket
import time

def write_html(andyshere):
	f = open('andy.html', 'w')
	f.write("<!DOCTYPE html><html><head><title>Andy Probe</title><body><font size=\"7\">")
	f.write("Andy is in Glennan!" if andyshere else  "Andy is not in Glennan (or avoiding my detection)")
	f.write("</font></body></html>")
	f.close()

while True:
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

	sock.settimeout(1.0)

	print "Probing Andy..."
	write_html(sock.connect_ex(("129.22.158.148", 80)) == 0)

	sock.close()

	time.sleep(30)
