%include "lib.asm"

EMPTY equ 0
OWNED_O equ 1
OWNED_X equ 2

section .data
	inputMsg db "> ", 0x0
	inputLen equ $ - inputMsg
	endlMsg db 0xA, 0x0
	endlLen equ $ - endlMsg
	spaceMsg db "E", 0x0
	spaceLen equ $ - spaceMsg
	oMsg db "O", 0x0
	oLen equ $ - oMsg
	xMsg db "X", 0x0
	xLen equ $ - xMsg
	barMsg db "|", 0x0
	barLen equ $ - barMsg
	field db EMPTY ; 0
	      db EMPTY ; 1
	      db EMPTY ; 2
	      db EMPTY ; 3
	      db EMPTY ; 4
	      db EMPTY ; 5
	      db EMPTY ; 6
          db EMPTY ; 7
          db EMPTY ; 8

section .bss
	input resb 32
	exitCode resb 1

section .text
	global _start

_start:
	mov r8, 0
	mov [exitCode], r8

	jmp display

    loop:
	mov rax, SYS_WRITE
	mov rbx, STDOUT
	mov rcx, inputMsg
	mov rdx, inputLen
	int 0x80

	mov rax, SYS_READ
	mov rbx, STDIN
	mov rcx, input
	mov rdx, 32
	int 0x80

	display:
	mov r8, 0

	displayLoop:
    mov rax, SYS_WRITE
    mov rbx, STDOUT

	cmp byte[field+r8], EMPTY
	je setEmpty
	cmp byte[field+r8], OWNED_O
	je setO
	cmp byte[field+r8], OWNED_X
	je setX

    setEmpty:
    mov rcx, spaceMsg
    jmp setEnd
    setO:
    mov rcx, oMsg
    jmp setEnd
    setX:
    mov rcx, xMsg
    jmp setEnd

    setEnd:
    mov rdx, 2
    int 0x80

    mov rdx, 0
    mov rax, r8
    mov rcx, 3
    idiv rcx

    cmp rdx, 0
    je displayBar
    cmp rdx, 1
    je displayBar
    cmp rdx, 2
    je displayNewLine

    displayBar:
    mov rax, SYS_WRITE
    mov rbx, STDOUT
    mov rcx, barMsg
    mov rdx, barLen
    int 0x80
    jmp displayEnd

    displayNewLine:
    mov rax, SYS_WRITE
    mov rbx, STDOUT
    mov rcx, endlMsg
    mov rdx, endlLen
    int 0x80
    jmp displayEnd

    displayEnd:
    inc r8
    mov rax, SYS_WRITE
    mov rbx, STDOUT
    mov rcx, r8
    add rcx, 0x30
    mov rdx, 1
    int 0x80
    cmp r8, 9
    jl displayLoop
    jmp loop

	exit:
	mov rax, SYS_EXIT
	mov rbx, [exitCode]
	int 0x80
