.model small
.stack 100h

.data
    input db "input.txt", 0h
    output db "output.txt", 0h
    f_in dw 0000h
    f_out dw 0000h
    msg db "Koduoja teksta Base64 enkoderiu$"
    text db 256 dup(0)
    binary db 2048 dup(20h), 0h
    base64 db 256 dup(3dh)

    alphabet db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

.code 
start:

    mov dx, @data
    mov ds, dx

	mov bx, 81h

parameter:
    mov ax, es:[bx]
    inc bx

    cmp al, 20h
    je parameter

	cmp ax, "?/"
	jne read
    
help:

    mov ax, 0900h
    mov dx, offset msg
    int 21h
    jmp close

read:

    mov ax, 3d00h
    lea dx, input
    int 21h
    mov f_in, ax

    mov ax, 3c00h
    xor cx, cx
    lea dx, output
    int 21h
    mov f_out, ax

    mov ax, 3f00h
    mov bx, f_in
    lea dx, text
    mov cx, 100h
    int 21h

convert:

;ascii to binary
    lea di, text
    lea si, binary

bin:   
    xor dx, dx
    mov bx, 2
    mov cx, 8
    xor ax, ax
    mov ax, ds:[di]
    cmp ax, 0
    jz close
    

lbin:
    div bx
    push dx
    xor dx, dx
    loop lbin

    mov cx, 8

binpop:
    pop ds:[si]

    inc si
    loop binpop

    inc di
    xor ax, ax
    mov ax, ds:[di]
    cmp ax, 0
    jnz bin

;binary to base64
basestart:
    lea si, binary 
    lea di, base64

base:   
    mov cx, 6
    mov bx, 32

lbase:
    xor ax, ax
    mov al, ds:[si]

    cmp al, 20h
    je z113
z311:

    mul bx
    push ax

    shr bx, 1
    inc si
    loop lbase

    xor ax, ax
    mov cx, 6
basepop:
    pop dx
    add ax, dx

    loop basepop

    push di
    add ax, offset alphabet
    mov di, ax
    xor dx, dx
    mov dx, ds:[di]
    pop di

    mov ds:[di], dl

    inc di

    mov ax, ds:[si]
    cmp al, 20h
    jne base


    lea di, base64

print:

    mov ax, ds:[di]
    cmp al, 3dh
    je close

    mov dx, di
    mov ax, 4000h
    mov cx, 4
    mov bx, f_out
    int 21h

    add di, 4
    jmp print


close:

    mov ax, 4c00h
    int 21h

z113:
    mov al, 0
    jmp z311


end start