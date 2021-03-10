.nolist
.include "../Shared/m16def.inc"

.equ F_CPU = 8000000
.equ BAUD = 38400

.equ UCSRB_INIT = (1 << RXEN) | (1 << TXEN)
.equ UBRR_INIT = (F_CPU / (16 * BAUD)) - 1

.dseg
MENU_LINKS: .byte 120

.cseg
.list
