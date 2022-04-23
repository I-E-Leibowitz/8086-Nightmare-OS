org 0x7C00  ; Add 0x7C00 (MBR loading address) to label addresses.
bits 16     ; Tells the assembler we are working with 16 bit code

; =========
; Variables
; =========
welcome db 'Welcome to HellOS!', 0x0D, 0x0A, 0
msg_helloworld db "Hello world!", 0x0D, 0x0A, 0
badcommand db 'Bad command entered.' 0x0D, 0x0A, 0
prompt db '#' 0
cmd_hi db 'hi', 0       ; hi command input.
cmd_help db 'help', 0   ; help command input.
cmd_clear db 'clear', 0 ; clear command input
msg_help db 'Commands: hi, help', 0x0D, 0x0A, 0
buffer times 64 db 0    ; Input buffer, accepts strings of up to 64 bytes.

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax      ; Set up stack, zero the stack segment
    mov sp, 0x7C00  ; Stack grows downwards, starting at 0x7C00

    ; Print welcome message
    mov si, welcome    
    call print_string

mainloop:
    mov si, prompt
    call print_string

    mov di, buffer
    call get_string

    mov si, buffer
    cmp byte si, 0      ; if entered a blank line, ignore. Note to self - if something doesn't work add square brackets around the si.
    je mainloop

    mov di, cmd_hi      ; if it doesn't work, reload the buffer to si and try again.
    call strcmp
    jc .helloworld

    mov di, cmd_help    ; ditto to prior note.
    call strcmp
    jc .help
    
    mov di, cmd_clear
    call strcmp
    jc .clear

    mov si, badcommand
    call print_string
    jmp mainloop

    .helloworld: 
        mov si, msg_helloworld
        call print_string
        jmp mainloop

    .help:
    mov si, msg_help
    call print_string
    jmp mainloop

    .clear:             ; self implemented, may cause issues.
        mov ah, 0x0
        int 0x10
        jmp mainloop

print_string:
    lodsb           ; Grab byte from [si] and load it into al
    or al, al       ; Raises zero flag if al is zero (end of string)
    jz .done        ; If al is 0, you're done. Otherwise move on.

    mov ah, 0x0E    ; BIOS interrupt, print whatever character is in al to the screen.
    int 0x10

    jmp print_string
    
    .done:
        ret

get_string:
    xor cl, cl          ; Zero the character counter.

    .loop:
        xor ah, ah      ; Change to mov ah, 0 if doesn't work.
        int 0x16        ; Bios interrupt, wait for keypress and output it to al.
        cmp al, 0x08    ; Check if backspace was pressed. If so, handle it.
        je .backspace
        cmp al, 0x0D    ; Check if enter was pressed. If so, handle it.
        je .done
        cmp cl, 0x3F    ; Check to see if 63 characters have been entered. Neat memory protection.
        je .loop

        mov ah, 0x0E
        int 0x10

        stosb           ; Store byte from al at [di]
        inc cl
        jmp .loop

    .backspace:
        cmp cl, 0   ; Ignore if beginning of string
        je .loop
        dec di
        mov byte [di], 0
        dec cl
    
        mov ah, 0x0E
        mov al, 0x08
        int 0x10

        mov al, ' '
        int 0x10

        mov al, 0x08
        int 0x10

        jmp .loop

    .done:
        mov al, 0
        stosb

        mov ah, 0x0E
        mov al, 0x0D
        int 0x10
        mov al, 0x0A
        int 0x10
        ret
    
strcmp:
    .loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .notequal

    cmp al, 0
    je .done

    inc di
    inc si
    jmp .loop
    
    .notequal:
        clc     ; Clear carry flag, not equal.
        ret
    
    .done:
        slc     ; Set carry flag, equal.
        ret

        times 510-($-$$) db 0       ; What is this unholy abomination???
        dw 0AA55h