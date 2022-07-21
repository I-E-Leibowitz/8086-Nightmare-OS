; Setup
org 0x7C00              ; Add 0x7C00 (MBR loading address) to label addresses.
bits 16

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

; Code
call clear_screen
mov si, hello_msg
call print_msg 
; Main loop
main:
    call get_str
    jmp main
; Data
hello_msg   db  "Welcome to NightmareOS!", 0xD, 0xA, 0
buffer times 0x14 0

; Functions
clear_screen:
    mov al, 0x03
    mov ah, 00
    int 0x10
    ret

print_msg:
    lodsb
    or al, al
    jz _done
    mov ah, 0x0E
    int 0x10
    jmp print_msg

_done:
    ret

get_str:
    ret
times 510-($-$$) db 0   ; Pads current section with zeros.
db 0x55, 0xaa