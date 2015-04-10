###
# File: http-responses.asm
#
# Craft HTTP responses based on the request
###

.include "http-requests.asm"

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

.data
# Not sure what I'll need in here yet

.text
# a0 has HTTP method code (defined in http-requests.asm)
# a1 has either the body (POST) or the URI (GET)
build_response:
  # TODO: push some temps
  beq $a0, HTTP_ERROR, _return_bad_request
  beq $a0, HTTP_OTHER, _return_method_name_not_allowed
  beq $a0, HTTP_POST, _handle_post

_handle_get:
_handle_post:
_return_method_name_not_allowed:
_return_bad_request:
