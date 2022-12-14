%include "lib.asm"

EMPTY equ 0
OWNED_O equ 1
OWNED_X equ 2
TURN_O equ 0
TURN_X equ 1

section .data
    inputStartMsg db "(", 0x0
    inputStartLen equ $ - inputStartMsg
	inputEndMsg db ") > ", 0x0
	inputEndLen equ $ - inputEndMsg
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
    turn db TURN_O

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
	mov rcx, inputStartMsg
	mov rdx, inputStartLen
	int 0x80

	cmp byte[turn], TURN_X
	je turnX

    mov rax, SYS_WRITE
    mov rbx, STDOUT
    mov rcx, oMsg
    mov rdx, oLen
    int 0x80
    jmp endInputPrint

    turnX:
    mov rax, SYS_WRITE
    mov rbx, STDOUT
    mov rcx, xMsg
    mov rdx, xLen
    int 0x80

    endInputPrint:
    mov rax, SYS_WRITE
    mov rbx, STDOUT
    mov rcx, inputEndMsg
    mov rdx, inputEndLen
    int 0x80

	mov rax, SYS_READ
	mov rbx, STDIN
	mov rcx, input
	mov rdx, 32
	int 0x80

	mov r9, input
	mov r10, 0

    cmp byte[r9], 0x30
    je set0
	cmp byte[r9], 0x31
	je set1
	cmp byte[r9], 0x32
	je set2
	cmp byte[r9], 0x33
	je set3
	cmp byte[r9], 0x34
	je set4
	cmp byte[r9], 0x35
	je set5
	cmp byte[r9], 0x36
	je set6
	cmp byte[r9], 0x37
	je set7
	cmp byte[r9], 0x38
	je set8

	jmp exit

	set0:
	mov r10, 0
	jmp endSet

	set1:
	mov r10, 1
	jmp endSet

	set2:
	mov r10, 2
	jmp endSet

	set3:
	mov r10, 3
	jmp endSet

	set4:
    mov r10, 4
    jmp endSet

    set5:
    mov r10, 5
    jmp endSet

    set6:
    mov r10, 6
    jmp endSet

    set7:
    mov r10, 7
    jmp endSet

    set8:
    mov r10, 8
    jmp endSet

    endSet:
	cmp byte[turn], TURN_X
	je updateFieldX

    mov byte[field+r10], OWNED_O
    jmp endUpdateField

    updateFieldX:
    mov byte[field+r10], OWNED_X

    endUpdateField:
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

    cmp byte[turn], TURN_X
    je setTurnO

    mov byte[turn], TURN_X
    jmp endSetTurn

    setTurnO:
    mov byte[turn], TURN_O

    endSetTurn:
    jmp loop

	exit:
	mov rax, SYS_EXIT
	mov rbx, [exitCode]
	int 0x80
