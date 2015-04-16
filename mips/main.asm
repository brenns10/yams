###
# File; main.asm
#
# The entry assembly file for YAMS.
###

# macro includes
.include "util-macros.asm"
.include "socket-macros.asm"

# module includes at bottom of file (otherwise entry point is messed up)

.eqv	MAX_REQUESTS	5
.eqv	num_requests	$s7
.eqv	request_type	$s2
.data
msg0:	.asciiz		"Request Method Type: "
msg1:	.asciiz		"Request Method (string): "
msg2:	.asciiz		"Request URI: "
msg3:	.asciiz		"Request Body: "
msg4:	.asciiz		"Request Body Length = "
msg5:	.asciiz		"Request Content-Type: "
hwhtml:	.ascii		"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\nContent-Length: 72\r\nConnection: close\r\n\r\n<html><h1>Hello, world!</h1><br/><h4>Served by MIPS and MARS.</h4></html>"
hwhtml_end:
formhtml:.ascii	"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\nContent-Length: 301\r\nConnection: close\r\n\r\n<html><h1>Hi</h1><form method='POST' action='/form.bfk' enctype='multipart/form-data'><label for='name'>Your name:</label><input name='name' type='text' id='name' /><br><input type='file' name='fle' id='input'><br><button type='submit'>Click Meh</button></form><h4>Served by MIPS and MARS.</h4></html>"
formhtml_end:
okay:	.ascii	"HTTP/1.1 200 OK\r\n\r\n"
okay_end:
ln:	.asciiz		"\n"

.text
.globl	main
main:
	li $s7, MAX_REQUESTS
	li $a0, 19001		# Port = 19001
	ssock_open($s0)		# open server_socket on 19001 and store FD in $s0
req_loop:
	ssock_accept($s0, $s1)	# accept connection from server_socket in $s0, store client FD in $s1

	# read & parse a single request
	move $a0, $s1	# requires the server socket FD in $a0
	jal get_request

	move $s2, $v0	# request type, one of HTTP_GET (0), HTTP_POST (1), HTTP_OTHER (2), HTTP_ERROR (3)
	move $s3, $v1	# Holds buffer with request URI (null-terminated)
	pop($s4)	# Holds buffer with request body (null-terminated)
	pop($t7)	# Get the length of the body (may not be
	pop($s5)	# Holds buffer with Content-Type header value

	# Debug Prints
	# Request Type
	print(msg0)
	print_int($s2)
	print(ln)

	# Request URI
	print(msg2)
	print_reg($s3)
	print(ln)

	# Content-Type header value
	print(msg5)
	print_reg($s5)
	print(ln)

	# Request Body Length
	print(msg4)
	print_int($t7)
	print(ln)

	# Request Body
	print(msg3)
	print_reg($s4)
	print(ln)

	j dispatch_default  # for now, always dispatch to the default
	#li $t0, HTTP_GET
	#beq request_type, $t0, dispatch_get
	#li $t0, HTTP_POST
	#beq request_type, $t0, dispatch_post
	#li $t0, HTTP_OTHER
	#beq request_type, $t0, dispatch_other
	# errors will go here (e.g. insufficient space, malformed request)
	# default case will be 405 (bad request)

dispatch_get:
	# Convert URI -> filepath
	# Open file@filepath
	# confirm file exists
	# if so, build a 200 w/ the data
	# else, 404
	j close_client_socket

dispatch_post:
	# If <some condition met>:
	# - decode POST request
	# - call into whitespace interpreter
	# else, 404/400 (bad request)
	j close_client_socket

dispatch_other:
	# return 405 (method name not allowed)
	j close_client_socket

dispatch_default:
	# default handler
	la $a1, formhtml
	# compute length of formhtml
	la $a2, formhtml_end
	sub $a2, $a2, $a1
	sock_write($s1)
	j close_client_socket

close_client_socket:
	# we don't bother re-using connections, so we can close.
	sock_close($s1)
	addi num_requests, num_requests, -1
	bgtz num_requests, req_loop		# handle the next HTTP request
	# end-of-program cleanup
	ssock_close($s0)
	exit(0)

# module includes
.include "http-requests.asm"
.include "string.asm"

