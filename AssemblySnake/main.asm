;David Benson
;Assembly Template

.386P
.model flat

extern   _ExitProcess@4: near

.data

.code
main PROC near
_main:

	push	0
	call	_ExitProcess@4

main ENDP
END