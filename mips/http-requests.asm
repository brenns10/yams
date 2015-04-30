###
# File: http-requests.asm
#
# Code that reads in an HTTP request and extracts relevant information.
###


.eqv	REQ_METHOD_BUFF_MAX		9
.eqv	REQ_URI_BUFF_MAX		513
.eqv	REQ_CONTENT_TYPE_BUFF_MAX	129
.eqv	REQ_BUFF_MAX			1048576	# This is the largest amount of data we can reasonably hold
.eqv	READ_SIZE			4096

.eqv	CHUNKED_TRANSFER_LEN	-2	# content_len is this if using chunked transfer

.eqv	req_method_len		$s7
.eqv	req_uri_len		$s6
.eqv	content_len		$s5
.eqv	header_ptr		$s4
.eqv	body_ptr		$s3
.eqv	temp_ptr		$s2
.eqv	sock_fd			$s1
.eqv	cur_req_buff_ptr	$s0

.data
# Print-out strings
_gr_msg_length:	.asciiz	"Bytes read: "
_gr_msg0: .asciiz	"Full Request:\n"
_gr_msg1: .asciiz	"$s7 = <len of method> = "
_gr_msg2: .asciiz	"$s6 = <len of URI> = "
_gr_msg3: .asciiz	"$s6 = <len of Content-Type> = "
_gr_respond_to_expect_unsupported:	.asciiz	"_respond_to_expect not yet supported\n"
_gr_read_to_length_unsupported:		.asciiz	"_read_to_length not yet supported\n"
_gr_read_all_chunks_unsupported:	.asciiz	"_read_all_chunks not yet supported\n"
_gr_unsupported_expect_header:		.asciiz	"unsupported Expect header: "
_gr_read_to_length_msg:			.asciiz	"in read_to_length: "
_gr_Expect_header_msg:			.asciiz	"Expect header: "

# Comparison strings
chr_space:	.asciiz	" "
chr_tab:	.asciiz "\t"
chr_CR:		.asciiz "\r"
chr_LF:		.asciiz "\n"
chr_0:		.asciiz "0"
chr_9:		.asciiz "9"

double_CRLF:	.ascii		"\r\n"
CRLF:		.asciiz	"\r\n"
str_empty:	.asciiz	""
str_GET:	.asciiz	"GET"
str_POST:	.asciiz	"POST"
str_header_Expect:		.asciiz	"Expect:"
str_header_ContentType:		.asciiz	"Content-Type:"
str_header_ContentLength:	.asciiz	"Content-Length:"
str_header_TransferEncoding:	.asciiz	"Transer-Encoding:"
str_100continue:		.asciiz	"100-continue"
str_100continue_response:	.asciiz	"HTTP/1.1 100 CONTINUE\r\n\r\n"

# Buffers for request information
req_method_buff:	.byte	0:REQ_METHOD_BUFF_MAX
req_uri_buff:		.byte	0:REQ_URI_BUFF_MAX
req_content_type_buff:	.byte	0:REQ_CONTENT_TYPE_BUFF_MAX
req_buff: 		.byte	0:REQ_BUFF_MAX


.text
	# get_request: gets the next HTTP request from the accepted socket.
	# Paramters:
	#   $a0: file descriptor for the client socket
	# Returns:
	#   $v0: request type, one of HTTP_GET (0), HTTP_POST (1), HTTP_OTHER (2), HTTP_ERROR (3)
	#	 - if $v0 == HTTP_ERROR, the following fields may not contain valid information
	#   $v1: address of null-terminated request URI
	#    -4($sp): address of the null-terminated request body
	#    -8($sp): length of the request body
	#   -12($sp): address of null-terminated Content-Type header value
get_request:
	push_all()
_gr_read:
	move sock_fd, $a0
	# read the request into the buffer
	la $a1, req_buff
	li $a2, READ_SIZE
	sock_read(sock_fd)
	la $t0, req_buff
	add cur_req_buff_ptr, $t0, $v1
	move $t1, $v1

	print(_gr_msg_length)
	print_int($t1)
	print(ln)

	# print whole request for debugging
	print(_gr_msg0)
	print(req_buff)
	print(ln)

	# confirm we got at least the header (i.e. check for doubleCRLF)
	la $a0, req_buff
	la $a1, double_CRLF
	jal substr_index_of
	bltz $v0, _get_request_error	# if not, drop this request on the floor

	# now we get pointers to the body...
	la $t0, req_buff
	add body_ptr, $t0, $v0	# up to doubleCRLF
	move temp_ptr, body_ptr
	la $a0, double_CRLF
	jal strlen
	add body_ptr, body_ptr, $v0	# add doubleCRLF

	# ...and to the headers
	la $a0, req_buff
	la $a1, CRLF
	jal substr_index_of
	# if we found a double CRLF, there must be at least one. Hence, no check.
	la $t0, req_buff
	add header_ptr, $t0, $v0
	la $a0, CRLF
	jal strlen
	add header_ptr, header_ptr, $v0

_parse_status_line:
	# Get the request method
	la $a0, req_buff
	lbu $a1, chr_space
	jal str_index_of
	move req_method_len, $v0
	bltz req_method_len, _get_request_error		# -1 return --> character not found

	# get the request URI
	la $a0, req_buff
	addi $a0, $a0, 1
	add $a0, $a0, req_method_len
	lbu $a1, chr_space
	jal str_index_of
	move req_uri_len, $v0
	bltz req_uri_len, _get_request_error		# -1 return --> character not found

	# copy the request method
	la $a0, req_method_buff
	la $a1, req_buff
	addi $a2, req_method_len, 1	# add 1 to make space for null terminator
	li $t0, REQ_METHOD_BUFF_MAX	# Make sure we do not overrun req_method_buff
	sgt $t1, $a2, $t0
	movn $a2, $t0, $t1
	jal strncpy

	# copy the request uri
	la $a0, req_uri_buff
	la $t0, req_buff
	addi $t1, req_method_len, 1
	add $a1, $t0, $t1
	addi $a2, req_uri_len, 1	# add 1 to make space for null terminator
	li $t0, REQ_URI_BUFF_MAX	# make sure we do not overrun req_uri_buff
	sgt $t1, $a2, $t0
	movn $a2, $t0, $t1
	jal strncpy

	# print out length of request method, request uri for debugging
	#print(_gr_msg1)
	#print_int(req_method_len)
	#print(ln)
	#print(_gr_msg2)
	#print_int(req_uri_len)
	#print(ln)

	###
	# Header parsing begins here
	###

	# swap out doubleCRLF at end of header for null terminator
	la $a0, double_CRLF
	jal strlen
	sub $t0, body_ptr, $v0
	lbu $t1, ($t0)
	li $t2, 0
	sb $t2, ($t0)
	push($t0)
	push($t1)

	# get the content-type
	move $a0, header_ptr
	la $a1, str_header_ContentType
	jal substr_index_of
	bltz $v0, _parse_content_len_headers

	# temp_ptr -> end of :
	add temp_ptr, header_ptr, $v0
	la $a0, str_header_ContentType
	jal strlen
	add $a0, temp_ptr, $v0
	jal _read_to_end_of_linear_whitespace

	# find length of header value
	move temp_ptr, $v0
	move $a0, temp_ptr
	la $a1, CRLF
	jal substr_index_of

	# copy the request content type
	la $a0, req_content_type_buff
	move $a1, temp_ptr
	addi $a2, $v0, 1
	li $t0, REQ_CONTENT_TYPE_BUFF_MAX
	sgt $t1, $a2, $t0
	movn $a2, $t0, $t1
	jal strncpy

_parse_content_len_headers:
	li content_len, 0	# default value is no content

	# check for content-length
	move $a0, header_ptr
	la $a1, str_header_ContentLength
	jal substr_index_of
	bgezal $v0, _get_content_len
	j _check_expect

	# check for transfer-encoding
	la $a0, req_buff
	la $a1, str_header_TransferEncoding
	jal substr_index_of
	li $t0, CHUNKED_TRANSFER_LEN
	sge $t1, $v0, $zero
	movn content_len, $t0, $t1

_check_expect:
	# If there is a content header, respond to it
	move $a0, header_ptr
	la $a1, str_header_Expect
	jal substr_index_of
	bgezal $v0, _respond_to_expect	# ...respond if it exists, and handle its request

	# Remove the null-byte at end of headers
	pop($t1)
	pop($t0)
	sb $t1, ($t0)

	# Read to length if there is content
	bgtz content_len, _read_to_length
	beq content_len, CHUNKED_TRANSFER_LEN, _read_all_chunks
	# otherwise, assume there is no content

_match_request_type:
	# see if it is a GET request
	la $a0, req_method_buff
	la $a1, str_GET
	jal strcmp
	move $t0, $v0
	li $v0, HTTP_GET
	la $v1, req_uri_buff
	beqz  $t0, _get_request_return

	# see if it is a POST request
	la $a0, req_method_buff
	la $a1, str_POST
	jal strcmp
	move $t0, $v0
	li $v0, HTTP_POST
	la $v1, req_uri_buff
	beqz  $t0, _get_request_return

	# Otherwise, we throw an error
	j _get_request_error

_read_to_length:
_read_to_length_loop:
	sub $t0, cur_req_buff_ptr, body_ptr
	sub $t0, content_len, $t0
	move $a1, cur_req_buff_ptr
	move $a2, $t0
	blez $a2, _match_request_type
	sock_read(sock_fd)
	add cur_req_buff_ptr, cur_req_buff_ptr, $v1
	j _read_to_length_loop
_read_all_chunks:
	print(_gr_read_all_chunks_unsupported)
	j _get_request_error

_get_request_error:
	li $v0, HTTP_ERROR
	la $v1, str_empty
_get_request_return:
	move $t0, body_ptr
	move $t1, content_len
	la $t2, req_content_type_buff
	pop_all()
	push($t2)
	push($t1)
	push($t0)
	jr $ra


	# _get_content_len: converts value of Content-Length field to number
	# Arguments:
	#  $v0: address of start of Content-Length header
	# Returns:
	#  $v0: value of the Content-Length header
_get_content_len:
	push($ra)
	# here, $v0 = start of "Content-Length:" header
	# get to end of header
	add temp_ptr, header_ptr, $v0
	la $a0, str_header_ContentLength
	jal strlen
	add $a0, temp_ptr, $v0
	jal _read_to_end_of_linear_whitespace
	move temp_ptr, $v0

	# read to end of digit string
	move $a0, temp_ptr
	jal _read_to_non_digit

	# swap w/ null byte
	lbu $t1, ($v0)
	li $t0, 0
	sb $t0, ($v0)
	push($t1)
	push($v0)

	# convert content length to decimal
	move $a0, temp_ptr
	jal atoi
	move content_len, $v0

	# swap back null byte
	pop($t0)
	pop($t1)
	sb $t1, ($t0)
	pop($ra)
	jr $ra


	# _respond_to_expect: Writes out a response expected by the client.
	#   Sometimes used in POST request for large files.
	# Arguments:
	#  $v0: address of start of Expect header
	# Returns:
	#  $v0: value of the Content-Length header
_respond_to_expect:
	push($ra)
	# here, $v0 = start of "Expect:" header
	# read to the start of its values
	add temp_ptr, header_ptr, $v0
	la $a0, str_header_Expect
	jal strlen
	add $a0, temp_ptr, $v0
	jal _read_to_end_of_linear_whitespace
	move temp_ptr, $v0

	# and to its end...
	move $a0, temp_ptr
	la $a1, CRLF
	jal substr_index_of

	add $t1, temp_ptr, $v0
	# swap w/ null byte
	lbu $t2, ($t1)
	li $t0, 0
	sb $t0, ($t1)
	push($t2)
	push($t1)

	move $a0, temp_ptr
	la $a1, str_100continue
	jal strcmp
	bnez $v0, _respond_to_expect_error
_write_100continue:
	la $a0, str_100continue_response
	jal strlen
	move $a2, $v0
	la $a1, str_100continue_response
	sock_write(sock_fd)
	j _respond_to_expect_return
_respond_to_expect_error:
	# TODO: check the spec and see what to do in the no-match case
	# for now, we print, but return
	print(_gr_unsupported_expect_header)
	print_reg(temp_ptr)
_respond_to_expect_return:
	# swap back null byte, then return
	pop($t0)
	pop($t2)
	sb $t2, ($t0)
	pop($ra)
	jr $ra
<<<<<<< Updated upstream

_read_to_length:
_read_to_length_loop:
	sub $t0, cur_req_buff_ptr, body_ptr
	sub $t0, content_len, $t0
	move $a1, cur_req_buff_ptr
	move $a2, $t0
	blez $a2, _match_request_type
	sock_read(sock_fd)
	add cur_req_buff_ptr, cur_req_buff_ptr, $v1
	j _read_to_length_loop

_read_all_chunks:
	print(_gr_read_all_chunks_unsupported)
	j _get_request_error
_get_request_error:
	li $v0, HTTP_ERROR
	la $v1, str_empty
_get_request_return:
	move $t0, body_ptr
	move $t1, content_len
	la $t2, req_content_type_buff
	pop_all()
	push($t2)
	push($t1)
	push($t0)
	jr $ra
=======
>>>>>>> Stashed changes


	# Parsing Methods
	# _read_to_end_of_linear_whitespace: moves addr in $a0 to first non-LWS character
	# Paramters:
	#   $a0: address in a buffer
	# Returns:
	#   $v0: address of first non-LWS character
_read_to_end_of_linear_whitespace:
	lbu $t1, chr_space
	lbu $t2, chr_tab
	lbu $t3, chr_CR
	lbu $t4, chr_LF
_rlws_loop:
	addi $a0, $a0, 1
	lbu $t0, ($a0)
	beq $t0, $t1, _rlws_loop
	beq $t0, $t2, _rlws_loop
	beq $t0, $t3, _rlws_loop
	beq $t0, $t4, _rlws_loop
	move $v0, $a0
	jr $ra


	# _read_to_to_non_digit: moves addr in $a0 to first non-digit character
	# Paramters:
	#   $a0: address in a buffer
	# Returns:
	#   $v0: address of first non-digit character
_read_to_non_digit:
_rnd_loop:
	addi $a0, $a0, 1
	lbu $t0, ($a0)
	lbu $t1, chr_0
	lbu $t2, chr_9
	blt $t0, $t1, _rnd_exit
	bgt $t0, $t2, _rnd_exit
	j _rnd_loop
_rnd_exit:
	move $v0, $a0
	jr $ra
