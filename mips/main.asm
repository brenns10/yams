###
# File; main.asm
#

# The entry assembly file for YAMS.
###

# macro includes
.include "util-macros.asm"
.include "file-io-macros.asm"
.include "socket-macros.asm"

# module includes at bottom of file (otherwise entry point is messed up)

# Because MARS includes are hilarious
.eqv	HTTP_GET	0
.eqv	HTTP_POST	1
.eqv	HTTP_OTHER	2
.eqv	HTTP_ERROR	3
.eqv	NO_SPACE	4

.eqv	request_type	$s2
.eqv	CHUNK_SIZE	1024
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
rf_file:	.asciiz		"reading from file\n"
rf_file_done:	.asciiz		"done reading from file\n"
wt_sock:	.asciiz		"writing to socket\n"
wt_sock_done:	.asciiz		"done writing to socket\n"
cl_file:	.asciiz		"closing file\n"
bf_load_uri:    .asciiz         "/load"
bf_run_uri:     .asciiz         "/run"
bf_lc_success:  .asciiz         "Code loaded."
bf_lc_memory:   .asciiz         "Memory error."
bf_lc_balance:  .asciiz         "Unbalanced brackets."
filestream_buff:	.space	CHUNK_SIZE

.text
.globl	main
main:
	sock_close_all()	# close all open (server) sockets
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
	#print(msg3)
	#print_reg($s4)
	#print(ln)

	#j dispatch_default
	li $t0, HTTP_GET
	beq request_type, $t0, dispatch_get
	li $t0, HTTP_POST
	beq request_type, $t0, dispatch_post
	li $t0, HTTP_OTHER
	beq request_type, $t0, dispatch_other
	j dispatch_default  # for now, always dispatch to the default
	# errors will go here (e.g. insufficient space, malformed request)
	# default case will be 405 (bad request)

dispatch_get:
	# Convert URI -> filepath
	move $a0, $s3
	jal uri_file_handle_fetch
	# Open file@filepath
	# confirm file exists, if not 404
	move $s7, $v0  # save the file handle for later
	print_int($s7)
	move $v0, $s7
	bltz $v0, dispatch_404
	# if so, build a 200 w/ the data
	jal return_200
	move $s6, $v0
	move $a0, $v0
	jal strlen
	move $a1, $s6
	move $a2, $v0
	sock_write($s1)

stream_file:
	print(rf_file)
	li $t1, CHUNK_SIZE
	file_read($s7, filestream_buff, $t1, $s6)
	print_int($s6)
	print(ln)
	print(rf_file_done)
	print(filestream_buff)
	print(wt_sock)
	la $a1, filestream_buff
	move $a2, $s6
	sock_write($s1)
	print(wt_sock_done)
	bgtz $s6, stream_file

stream_file_cleanup:
	print(cl_file)
	file_close($s7)
	j close_client_socket

dispatch_404:
	jal return_404
	move $s6, $v0
	move $a0, $v0
	jal strlen # How long is the response?
	move $a1, $s6
	move $a2, $v0
	sock_write($s1)
	j close_client_socket
  

dispatch_post:
	# Simplifying Assumption -- use `curl` to trigger interpretation
	# If <some condition met>:
	# - decode POST request
	# - call into whitespace interpreter
	# else, 404/400 (bad request)
	la $a0, bf_load_uri
        move $a1, $s3
        jal strcmp
        beq $v0, $zero, _post_bf_load
        la $a0, bf_run_uri
        move $a1, $s3
        jal strcmp
        beq $v0, $zero, _post_bf_run
	j dispatch_404

_post_bf_load:
        move $a0, $s4
        jal bf_load_code
        push($v0)
        jal return_200
	move $s6, $v0
	move $a0, $v0
	jal strlen # How long is the response?
	move $a1, $s6
	move $a2, $v0
	sock_write($s1)
        pop($v0)
        beq $v0, $zero, _post_bf_load_success
        li $t0, 1
        beq $v0, $t0, _post_bf_load_mem
        li $t0, 2
        beq $v0, $t0, _post_bf_load_bal
_post_bf_load_success:
        la $a0, bf_lc_success
        la $a1, 12
        j _post_bf_load_continue
_post_bf_load_mem:
        la $a0, bf_lc_memory
        la $a1, 13
        j _post_bf_load_continue
_post_bf_load_bal:
        la $a0, bf_lc_balance
        la $a1, 20
_post_bf_load_continue:
        sock_write($s1)
        j close_client_socket

_post_bf_run:
        move $a0, $s4
        jal bf_intrp
        jal return_200
	move $s6, $v0
	move $a0, $v0
	jal strlen # How long is the response?
	move $a1, $s6
	move $a2, $v0
	sock_write($s1)
	la $a0, bf_out
        jal strlen
        la $a0, bf_out
        move $a1, $v0
        sock_write($s1)
        j close_client_socket


dispatch_other:
	# return 405 (method name not allowed)
	jal return_method_name_not_allowed
	move $a0, $v0
	jal strlen
	move $a2, $v0
	sock_write($s1)
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
	j req_loop		# handle the next HTTP request
	# end-of-program cleanup
	ssock_close($s0)
	exit(0)

# module includes
.include "file.asm"
.include "http-requests.asm"
.include "http-responses.asm"
.include "string.asm"
.include "brainfuck.asm"
