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
                rcall spi_close

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
.dw LC_SR       \ .db "Shift Registers", 0
.dw LC_OUTPUTS  \ .db "Output, no LEDs installed", 0
.dw LC_SLICE    \ .db "Output, LED slice installed", 0
.dw LC_FULL     \ .db "Output, all LEDs installed", 0
.dw -1

START_STRING:       .db "*** Started:  ", 0
END_STRING:         .db "*** Finished: ", 0
SEPARATOR_STRING:   .db " / ", 0

////////////////////////////////////////////////// Shared
STEP_SEPARATOR: .db "... "
tx_step:        rcall tx_string
                ldi ZL, low(STEP_SEPARATOR << 1)
                ldi ZH, high(STEP_SEPARATOR << 1)
                rjmp tx_string

PASS_STRING: .db "PASS"
tx_pass:        ldi ZL, low(PASS_STRING << 1)
                ldi ZH, high(PASS_STRING << 1)
                rcall tx_string
                rjmp tx_crlf

FAIL_STRING: .db "FAIL"
tx_fail:        ldi ZL, low(FAIL_STRING << 1)
                ldi ZH, high(FAIL_STRING << 1)
                rcall tx_string
                rjmp tx_crlf

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

spi_master:     ldi r16, MASTER_SPCR_INIT
                out SPCR, r16
                ldi r16, MASTER_PORT_INIT
                out PORT, r16
                ldi r16, MASTER_DDR_INIT
                out DDR, r16
                ret

spi_slave:      ldi r16, SLAVE_SPCR_INIT
                out SPCR, r16
                ldi r16, SLAVE_PORT_INIT
                out PORT, r16
                ldi r16, SLAVE_DDR_INIT
                out DDR, r16
                ret

spi_close:      ldi r16, CLOSE_SPCR_INIT
                out SPCR, r16
                ldi r16, CLOSE_DDR_INIT
                out DDR, r16
                ldi r16, CLOSE_PORT_INIT
                out PORT, r16
                ret

tx_slave:       cbi PORT, SS_PIN
                rcall txrx_spi
                
                adiw Y, 0
                breq tx_slave1

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

                ld r16, X+
                rcall txrx_spi
                sbiw Y, 1
                brne PC - 3

tx_slave1:      adiw Z, 0
                brne tx_slave2

                rcall txrx_spi ; dummy for slave to have enough time to load response

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

                rcall txrx_spi
                st X+, r16
                sbiw Z, 1
                brne PC - 1

tx_slave2:      sbi PORT, SS_PIN
                ret

txrx_spi:       out SPDR, r16
                sbis SPSR, SPIF
                rjmp PC - 1
                in r16, SPDR
                ret

////////////////////////////////////////////////// LC-8x8x8-RGB-00 (Master)

MASTER_COMM:    ldi r16, 'A'
                rcall tx_byte
                ret

////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave)

LC_S0: .db "Sending and getting big packet"
LC_S1: .db "Checking INT pin"

LC_COMM:        rcall spi_master
                
                ldi ZL, low(LC_S0 << 1)
                ldi ZH, high(LC_S0 << 1)
                rcall tx_step

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)
                ldi r24, low(PACKET_BUFFER + PACKET_BUFFER_SIZE)
                ldi r25, high(PACKET_BUFFER + PACKET_BUFFER_SIZE)
                clr r16

                st X+, r16
                inc r16
                cp XL, r24
                cpc XH, r25
                brlo PC - 3

                ldi r16, D01_SET_TEST_DATA
                ldi YL, low(PACKET_BUFFER_SIZE)
                ldi YH, high(PACKET_BUFFER_SIZE)
                ldi ZL, 0
                ldi ZH, 0
                rcall tx_slave

                ldi r16, D01_GET_TEST_DATA
                ldi YL, 0
                ldi YH, 0
                ldi ZL, low(PACKET_BUFFER_SIZE)
                ldi ZH, high(PACKET_BUFFER_SIZE)
                rcall tx_slave

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)
                ldi r24, low(PACKET_BUFFER + PACKET_BUFFER_SIZE)
                ldi r25, high(PACKET_BUFFER + PACKET_BUFFER_SIZE)
                clr r16

lc_comm_loop1:  ld r17, X+
                cp r17, r16
                breq PC + 2
                rjmp tx_fail
                inc r16
                cp XL, r24
                cpc XH, r25
                brlo lc_comm_loop1

                rcall tx_pass

                ldi ZL, low(LC_S1 << 1)
                ldi ZH, high(LC_S1 << 1)
                rcall tx_step

                ldi r17, 8

lc_comm_loop2:  ldi r16, D01_SET_INT_HIGH
                ldi YL, 0
                ldi YH, 0
                ldi ZL, 0
                ldi ZH, 0
                rcall tx_slave

                sbis PINREG, INT_PIN
                rjmp tx_fail

                ldi r16, D01_SET_INT_LOW
                ldi YL, 0
                ldi YH, 0
                ldi ZL, 0
                ldi ZH, 0
                rcall tx_slave

                sbic PINREG, INT_PIN
                rjmp tx_fail

                dec r17
                brne lc_comm_loop2

                rjmp tx_pass

LC_SR:          ldi r16, 'X'
                rcall tx_byte
                ret

LC_OUTPUTS:     ldi r16, 'Y'
                rcall tx_byte
                ret

LC_SLICE:       ldi r16, 'Z'
                rcall tx_byte
                ret

LC_FULL:        ldi r16, 'W'
                rcall tx_byte
                ret
