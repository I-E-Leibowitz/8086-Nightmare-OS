org 0x7C00  ; Add 0x7C00 (MBR loading address) to label addresses.
times 510-($-$$) db 0   ; Pads current section with zeros.
db 0x55, 0xaa