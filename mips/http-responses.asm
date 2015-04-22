###
# File: http-responses.asm
#
# Craft HTTP responses based on the request
###

# response codes we will most likely be using
.eqv HTTP_OK 200

.eqv HTTP_MOVED_PERMANENTLY 301
.eqv HTTP_FOUND 302
.eqv HTTP_NOT_MODIFIED 304

.eqv HTTP_BAD_REQUEST 400
.eqv HTTP_FORBIDDEN 403
.eqv HTTP_NOT_FOUND 404
.eqv HTTP_METHOD_NAME_NOT_ALLOWED 405

.eqv HTTP_INTERNAL_SERVER_ERROR 500
.eqv HTTP_INSUFFICIENT_STORAGE 507

.eqv RESP_BUFF_SIZE 2048

.data
http_protocol: .asciiz "HTTP/1.1 "

http_ok: .asciiz "200 OK\r\n"

http_moved_permanently: .asciiz "301 MOVED PERMANENTLY\r\n"
http_found: .asciiz "302 FOUND\r\n"
http_not_modified: .asciiz "304 NOT MODIFIED\r\n"

http_bad_request: .asciiz "400 BAD REQUEST\r\n"
http_forbidden: .asciiz "403 FORBIDDEN\r\n"
http_not_found: .asciiz "404 NOT FOUND\r\n"
http_method_name_not_allowed: .asciiz "405 METHOD NAME NOT ALLOWED\r\n"

http_internal_server_error: .asciiz "500 INTERNAL SERVER ERROR\r\n"
http_insufficient_storage: .asciiz "507 INSUFFICIENT STORAGE\r\n"

standard_headers: .asciiz "Connection: Close\r\nServer:yams\r\n"

resp_buff: .byte 0:RESP_BUFF_SIZE

.text
return_404:
  push($ra)

  la $a0, http_protocol
  la $a1, http_not_found
  la $a2, resp_buff
  jal strcat
  print(resp_buff)

  la $a0, resp_buff
  la $a1, standard_headers
  la $a2, resp_buff # redundant, but here for clarity
  jal strcat
  print(resp_buff)

  j _return_resp

return_200:
  push($ra)

  la $a0, http_protocol
  la $a1, http_ok
  la $a2, resp_buff
  jal strcat

  la $a0, resp_buff
  la $a1, standard_headers
  la $a2, resp_buff
  jal strcat

  j _return_resp

return_method_name_not_allowed:
  push($ra)

  la $a0, http_protocol
  la $a1, http_method_name_not_allowed
  la $a2, resp_buff
  jal strcat

  la $a0, resp_buff
  la $a1, standard_headers
  la $a2, resp_buff
  jal strcat

  j _return_resp

return_bad_request:
  push($ra)

  la $a0, http_protocol
  la $a1, http_bad_request
  la $a2, resp_buff
  jal strcat

  la $a0, resp_buff
  la $a1, standard_headers
  la $a2, resp_buff
  jal strcat

_return_resp:
  pop($ra)
  la $v0, resp_buff
  jr $ra
