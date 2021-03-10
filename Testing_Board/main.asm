.include "definitions.inc"

start:          ldi r16, low(RAMEND)
                out SPL, r16
                ldi r16, high(RAMEND)
                out SPH, r16

                ldi r16, high(UBRR_INIT)
                out UBRRH, r16
                ldi r16, low(UBRR_INIT)
                out UBRRL, r16
                ldi r16, UCSRB_INIT
                out UCSRB, r16

loop:           ldi ZL, low(MENU << 1)
                ldi ZH, high(MENU << 1)

                ldi r23, 'a'
                ldi XL, low(MENU_LINKS)
                ldi XH, high(MENU_LINKS)

menu_entry:     lpm r24, Z+
                lpm r25, Z+

                adiw r25:r24, 0
                breq print_title
                adiw r25:r24, 1
                breq wait_input
                sbiw r25:r24, 1
                rjmp print_choice

print_title:    rcall tx_crlf
                ldi r16, ' '
                rcall tx_byte
                ldi r16, ' '
                rcall tx_byte
                ldi r16, ' '
                rcall tx_byte
                ldi r16, ' '
                rcall tx_byte
                movw r3:r2, Z
                rjmp print_string

print_choice:   ldi r16, '['
                rcall tx_byte
                mov r16, r23
                rcall tx_byte
                ldi r16, ']'
                rcall tx_byte
                ldi r16, ' '
                rcall tx_byte

                st X+, r2
                st X+, r3
                st X+, ZL
                st X+, ZH
                st X+, r24
                st X+, r25
                inc r23
                rjmp print_string

print_string:   rcall tx_string
                rcall tx_crlf
                sbrc ZL, 0
                adiw Z, 1
                rjmp menu_entry

wait_input:     rcall rx_byte
                cpi r16, 'a'
                brlo wait_input
                cp r16, r23
                brsh wait_input

                ldi XL, low(MENU_LINKS)
                ldi XH, high(MENU_LINKS)
                subi r16, 'a'
                ldi r17, 6
                mul r16, r17
                add XL, r0
                adc XH, r1

                ldi YL, low(MENU_LINKS)
                ldi YH, high(MENU_LINKS)

                ldi ZL, low(START_STRING << 1)
                ldi ZH, high(START_STRING << 1)
                rcall tx_crlf
                rcall tx_string

                ld ZL, X+
                ld ZH, X+
                st Y+, ZL
                st Y+, ZH
                rcall tx_string

                ldi ZL, low(SEPARATOR_STRING << 1)
                ldi ZH, high(SEPARATOR_STRING << 1)
                rcall tx_string

                ld ZL, X+
                ld ZH, X+
                st Y+, ZL
                st Y+, ZH
                rcall tx_string
                rcall tx_crlf
                
                ld ZL, X+
                ld ZH, X+
                icall

                ldi XL, low(MENU_LINKS)
                ldi XH, high(MENU_LINKS)

                ldi ZL, low(END_STRING << 1)
                ldi ZH, high(END_STRING << 1)
                rcall tx_crlf
                rcall tx_string

                ld ZL, X+
                ld ZH, X+
                rcall tx_string

                ldi ZL, low(SEPARATOR_STRING << 1)
                ldi ZH, high(SEPARATOR_STRING << 1)
                rcall tx_string

                ld ZL, X+
                ld ZH, X+
                rcall tx_string
                rcall tx_crlf
                rjmp loop

MENU:
.dw 0           \ .db "Choose test to run", 0

.dw 0           \ .db "LC-8x8x8-RGB-00 (Master)", 0
.dw MASTER_COMM \ .db "Interface", 0

.dw 0           \ .db "LC-8x8x8-RGB-01 (Led Cube Slave)", 0
.dw LC_COMM     \ .db "Interface", 0
.dw LC_INT      \ .db "INT Pin", 0
.dw LC_SR       \ .db "Shift Registers", 0
.dw LC_OUTPUTS  \ .db "Output, no LEDs installed", 0
.dw LC_SLICE    \ .db "Output, LED slice installed", 0
.dw LC_FULL     \ .db "Output, all LEDs installed", 0
.dw -1

START_STRING:       .db "*** Started:  ", 0
END_STRING:         .db "*** Finished: ", 0
SEPARATOR_STRING:   .db " / ", 0

//////////////////////////////////////////////////

tx_string:      lpm r16, Z+
                tst r16
                brne PC + 2
                ret
                rcall tx_byte
                rjmp tx_string

tx_crlf:        ldi r16, 0x0D
                rcall tx_byte
                ldi r16, 0x0A
                rjmp tx_byte

tx_byte:        sbis UCSRA, UDRE
                rjmp tx_byte
                out UDR, r16
                ret

rx_byte:        sbis UCSRA, RXC
                rjmp rx_byte
                in r16, UDR
                ret

//////////////////////////////////////////////////

MASTER_COMM:    ldi r16, 'A'
                rcall tx_byte
                ret

//////////////////////////////////////////////////

LC_COMM:        ldi r16, 'B'
                rcall tx_byte
                ret

LC_INT:         ldi r16, 'C'
                rcall tx_byte
                ret

LC_SR:          ldi r16, 'D'
                rcall tx_byte
                ret

LC_OUTPUTS:     ldi r16, 'E'
                rcall tx_byte
                ret

LC_SLICE:       ldi r16, 'F'
                rcall tx_byte
                ret

LC_FULL:        ldi r16, 'G'
                rcall tx_byte
                ret
