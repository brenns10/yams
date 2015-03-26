###
# File: http-requests.asm
#
# Code that reads in an HTTP request and extracts relevant information
###

.eqv	HTTP_GET	0
.eqv	HTTP_POST	1
.eqv	HTTP_OTHER	2
.eqv	HTTP_ERROR	3

.eqv	REQ_METHOD_BUFF_MAX	9
.eqv	REQ_URI_BUFF_MAX	513
.eqv	REQ_BUFF_MAX		8192

.eqv	req_method_len		$s7
.eqv	req_uri_len		$s6

.data
_gr_msg1: .asciiz	"$s7 = <len of method> = "
_gr_msg2: .asciiz	"$s6 = <len of URI> = "
chr_space:
	.asciiz " "
double_CRLF:
	.ascii	"\r\n"
CRLF:
	.asciiz	"\r\n"
str_GET:
	.asciiz "GET"
str_POST:
	.asciiz "POST"

req_buff:
	.byte	0:REQ_BUFF_MAX
	.byte	0
req_method_buff:
	.byte	0:REQ_METHOD_BUFF_MAX
	.byte	0
req_uri_buff:
	.byte	0:REQ_URI_BUFF_MAX
	.byte	0

.text
get_request:
	push($s1)
	push($s5)
	push($s6)
	push($s7)
	push($ra)

	# read the request into the buffer
	la $a1, req_buff
	li $a2, REQ_BUFF_MAX
	sock_read($s1)
	
	# print whole request for debugging
	#print(req_buff)
	#print(ln)

	# parsing the status line
	# make $s7 = length of request method
	la $a0, req_buff
	lbu $a1, chr_space
	jal str_index_of
	move req_method_len, $v0
	bltz req_method_len, _get_request_error	# -1 return --> character not found
	
	# make $s6 = length of request uri
	la $a0, req_buff
	addi $a0, $a0, 1
	add $a0, $a0, $s7
	lbu $a1, chr_space
	jal str_index_of
	move req_uri_len, $v0
	bltz req_uri_len, _get_request_error	# -1 return --> character not found
	
	# print out length of request method, uri for debugging
	#print(_gr_msg1)
	#print_int(req_method_len)
	#print(ln)
	#print(_gr_msg2)
	#print_int(req_uri_len)
	#print(ln)
	
	# copy the request method
	la $a0, req_method_buff
	la $a1, req_buff
	addi $a2, req_method_len, 1  # add 1 to make space for null terminator
	li $t0, REQ_METHOD_BUFF_MAX
	bge $t0, $a2, _copy_req_method
	move $a2, $t0
_copy_req_method:
	jal strncpy
	
	# copy the request uri
	la $a0, req_uri_buff
	la $t0, req_buff
	addi $t1, req_method_len, 1
	add $a1, $t0, $t1
	addi $a2, req_uri_len, 1   # add 1 to make space for null terminator
	li $t0, REQ_URI_BUFF_MAX
	bge $t0, $a2, _copy_req_uri
	move $a2, $t0
_copy_req_uri:
	jal strncpy

	# see if it's a GET request
	la $a0, req_method_buff
	la $a1, str_GET
	jal strcmp
	move $s5, $v0

	li $v0, HTTP_GET
	la $v1, req_uri_buff
	# For now, if it's not a GET request, we throw an error
	beqz  $s5, _get_request_return
	j _get_request_error

_get_request_error:
	li $v0, HTTP_ERROR	
_get_request_return:
	pop($ra)
	pop($s7)
	pop($s6)
	pop($s5)
	pop($s1)
	jr $ra
	
