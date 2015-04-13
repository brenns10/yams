###
# File: http-requests.asm
#
# Code that reads in an HTTP request and extracts relevant information
###

.eqv	HTTP_GET	0
.eqv	HTTP_POST	1
.eqv	HTTP_OTHER	2
.eqv	HTTP_ERROR	3
.eqv	NO_SPACE	4

.eqv	REQ_METHOD_BUFF_MAX	9
.eqv	REQ_URI_BUFF_MAX	513
.eqv	REQ_BUFF_MAX		1048576	# This is the largest amount of data we can reasonably hold
.eqv	READ_SIZE		4096

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
str_header_ContentLength:	.asciiz	"Content-Length:"
str_header_TransferEncoding:	.asciiz	"Transer-Encoding:"
str_100continue:		.asciiz	"100-continue"
str_100continue_response:	.asciiz	"HTTP/1.1 100 CONTINUE\r\n\r\n"

# Buffers for request information
req_buff: 		.byte	0:REQ_BUFF_MAX
req_method_buff:	.byte	0:REQ_METHOD_BUFF_MAX
req_uri_buff:		.byte	0:REQ_URI_BUFF_MAX

.text
get_request:
	push_all()
_gr_read:
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
	add body_ptr, $v0, $t0	# up to doubleCRLF
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
	li $t0, REQ_METHOD_BUFF_MAX	# Make sure we don't overrun req_method_buff
	sgt $t1, $a2, $t0
	movn $a2, $t0, $t1
	jal strncpy

	# copy the request uri
	la $a0, req_uri_buff
	la $t0, req_buff
	addi $t1, req_method_len, 1
	add $a1, $t0, $t1
	addi $a2, req_uri_len, 1	# add 1 to make space for null terminator
	li $t0, REQ_URI_BUFF_MAX	# make sure we don't overrun req_uri_buff
	sgt $t1, $a2, $t0
	movn $a2, $t0, $t1
	jal strncpy

	# print out length of request method, request uri for debugging
	print(_gr_msg1)
	print_int(req_method_len)
	print(ln)
	print(_gr_msg2)
	print_int(req_uri_len)
	print(ln)

_find_content_len:
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
	# If there's a content header, respond to it
	move $a0, header_ptr
	la $a1, str_header_Expect
	jal substr_index_of
	bgezal $v0, _respond_to_expect	# ...respond if it exists, and handle its request

	# Read to length if there's content
	bgtz content_len, _read_to_length
	beq content_len, CHUNKED_TRANSFER_LEN, _read_all_chunks
	# otherwise, assume there's no content

_match_request_type:
	# see if it's a GET request
	la $a0, req_method_buff
	la $a1, str_GET
	jal strcmp
	move $t0, $v0
	li $v0, HTTP_GET
	la $v1, req_uri_buff
	beqz  $t0, _get_request_return

	# see if it's a POST request
	la $a0, req_method_buff
	la $a1, str_POST
	jal strcmp
	move $t0, $v0
	li $v0, HTTP_POST
	la $v1, req_uri_buff
	beqz  $t0, _get_request_return

	# Otherwise, we throw an error
	j _get_request_error

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
	print_int(content_len)
	print(ln)

	# swap back null byte
	pop($t0)
	pop($t1)
	sb $t1, ($t0)
	pop($ra)
	jr $ra

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

	# debug prints
	print(_gr_Expect_header_msg)
	print_reg(temp_ptr)
	print(ln)

	move $a0, temp_ptr
	la $a1, str_100continue
	jal strcmp
	beqz $v0, _write_100continue

	# TODO: check the spec and see what to do in the no-match case
	# for now, we'll print, but return
	print(_gr_unsupported_expect_header)
	print_reg(temp_ptr)

_respond_to_expect_return:
	# swap back null byte, then return
	pop($t0)
	pop($t2)
	sb $t2, ($t0)
	pop($ra)
	jr $ra

_write_100continue:
	# if so, write out the response
	la $a0, str_100continue_response
	jal strlen
	move $a2, $v0
	la $a1, str_100continue_response
	sock_write(sock_fd)
	j _respond_to_expect_return
	
_read_to_length:
	print(_gr_read_to_length_msg)
	print_int(content_len)
	print(ln)
	move $a1, cur_req_buff_ptr
	move $a2, content_len
	sock_read(sock_fd)
	add cur_req_buff_ptr, cur_req_buff_ptr, $v1
	move $t1, $v1
	print_int($t1)
	print(ln)
	print(ln)
	j _match_request_type

_read_all_chunks:
	print(_gr_read_all_chunks_unsupported)
	j _get_request_error
_get_request_error:
	li $v0, HTTP_ERROR
	la $v1, str_empty
_get_request_return:
	pop_all()
	jr $ra


# parsing methods
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
	 
