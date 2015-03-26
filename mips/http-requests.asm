###
# File: http-requests.asm
#
# Code that reads in an HTTP request and extracts relevant information
###

.eqv	HTTP_GET	0
.eqv	HTTP_POST	1
.eqv	HTTP_OTHER	2
.eqv	HTTP_ERROR	3

.eqv	REQ_METHOD_BUFF_MAX	8
.eqv	REQ_URI_BUFF_MAX	512
.eqv	REQ_BUFF_MAX		8192

.data
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

	# read the request into the buffer
	la $a1, req_buff
	li $a2, REQ_METHOD_BUFF_MAX
	sock_read($s1)
	
	# print buffer for debugging
	print(req_buff)
	print(ln)

	# parsing the status line
	# get index of the first space
	la $a0, req_buff
	lb $a1, chr_space
	jal str_index_of
	move $s7, $v0
	bltz $s7, req_error	# -1 return --> character not found
	
	# copy the request method
	la $a0, req_method_buff
	la $a1, req_buff
	addi $a2, $s7, -1
	li $t0, REQ_METHOD_BUFF_MAX
	bge $a2, $t0, _copy_req_method
	move $a2, $t0
_copy_req_method:
	push($ra)
	jal strncpy
	pop($ra)
	
	# get index of the second space: start search at first space + 1
	la $t0, 1(req_buff)
	add $a0, $t0, $s7
	lb $a1, chr_space
	jal str_index_of
	move $s6, $v0
	bltz $s6, req_error	# -1 return --> character not found
	
	# copy the request uri
	la $a0, req_uri_buff
	la $t0, 1(req_buff)
	add $a1, $t0, $s7
	sub $a2, $s6, $s7
	addi $a2, $a2, -1
	li $t0, REQ_METHOD_BUFF_MAX
	bge $a2, $t0, _copy_req_uri
	move $a2, $t0
_copy_req_uri:
	push($ra)
	jal strncpy
	pop($ra)

	# see if it's a GET request
	la $a0, req_method_buff
	la $a1, str_GET
	push($ra)
	jal strcmp
	pop($ra)
	move $s5, $v0

	li $v0, HTTP_GET
	la $v1, req_uri_buff
	# For now, if it's not a GET request, we throw an error
	beqz  $s5, _get_request_return
	j _get_request_error

_get_request_error:
	move $v0, HTTP_ERROR	
_get_request_return:
	pop($s7)
	pop($s6)
	pop($s5)
	pop($s1)
	jr $ra
	