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

loop:           rcall tx_crlf
                ldi r16, '*'
                ldi r17, 32
                rcall tx_byte
                dec r17
                brne PC - 2
                rcall tx_crlf

                ldi ZL, low(MENU << 1)
                ldi ZH, high(MENU << 1)

                ldi r23, 'a'

menu_choice:    lpm r24, Z+
                lpm r25, Z+

                adiw r25:r24, 0
                breq wait_choice
                
                ldi r16, '['
                rcall tx_byte
                mov r16, r23
                rcall tx_byte
                ldi r16, ']'
                rcall tx_byte
                ldi r16, ' '
                rcall tx_byte
                rcall tx_string_crlf

                sbrc ZL, 0
                adiw Z, 1
                inc r23
                rjmp menu_choice

wait_choice:    rcall rx_byte
                cpi r16, 'a'
                brlo wait_choice
                cp r16, r23
                brsh wait_choice

                ldi ZL, low(MENU << 1)
                ldi ZH, high(MENU << 1)

find_choice:    cpi r16, 'a'
                breq found_choice

                adiw Z, 2
                lpm r17, Z+
                tst r17
                brne PC - 2
                sbrc ZL, 0
                adiw Z, 1

                dec r16
                rjmp find_choice 
 
found_choice:   lpm r2, Z+
                lpm r3, Z+
                movw r5:r4, Z
                
                rcall tx_crlf
                ldi ZL, low(START_STRING << 1)
                ldi ZH, high(START_STRING << 1)
                rcall tx_string
                movw Z, r5:r4
                rcall tx_string_crlf

                movw Z, r3:r2
                push r4
                push r5
                icall
                pop r5
                pop r4
                rcall spi_close

                rcall tx_crlf
                ldi ZL, low(END_STRING << 1)
                ldi ZH, high(END_STRING << 1)
                rcall tx_string
                movw Z, r5:r4
                rcall tx_string_crlf

                rcall rx_byte

                rjmp loop

MENU:
.dw MASTER_COMM \ .db "LC-8x8x8-RGB-00 (Master) / Interface", 0
.dw LC_COMM     \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Interface", 0
.dw LC_SR       \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Shift Registers", 0
.dw LC_OUTPUTS  \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, no LEDs installed", 0
.dw LC_SLICE0   \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 0 (back)", 0
.dw LC_SLICE1   \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 1", 0
.dw LC_SLICE2   \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 2", 0
.dw LC_SLICE3   \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 3", 0
.dw LC_SLICE4   \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 4", 0
.dw LC_SLICE5   \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 5", 0
.dw LC_SLICE6   \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 6", 0
.dw LC_SLICE7   \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 7 (front)", 0
.dw LC_FULL     \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, all LEDs installed", 0
.dw 0

START_STRING:       .db "*** Started:  ", 0
END_STRING:         .db "*** Finished: ", 0

////////////////////////////////////////////////// Comms

tx_string_crlf: rcall tx_string
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

tx_24_bit_int:  ldi r16, '0' - 1
                inc r16
                subi r17, low(10000000)
                sbci r18, byte2(10000000)
                sbci r19, byte3(10000000)
                brcc PC - 4
                subi r17, low(-10000000)
                sbci r18, byte2(-10000000)
                sbci r19, byte3(-10000000)
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(1000000)
                sbci r18, byte2(1000000)
                sbci r19, byte3(1000000)
                brcc PC - 4
                subi r17, low(-1000000)
                sbci r18, byte2(-1000000)
                sbci r19, byte3(-1000000)
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(100000)
                sbci r18, byte2(100000)
                sbci r19, byte3(100000)
                brcc PC - 4
                subi r17, low(-100000)
                sbci r18, byte2(-100000)
                sbci r19, byte3(-100000)
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(10000)
                sbci r18, byte2(10000)
                sbci r19, byte3(10000)
                brcc PC - 4
                subi r17, low(-10000)
                sbci r18, byte2(-10000)
                sbci r19, byte3(-10000)
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(1000)
                sbci r18, high(1000)
                brcc PC - 3
                subi r17, low(-1000)
                sbci r18, high(-1000)
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(100)
                sbci r18, high(100)
                brcc PC - 3
                subi r17, low(-100)
                sbci r18, high(-100)
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, 10
                brcc PC - 2
                subi r17, -10
                rcall tx_byte

                ldi r16, '0'
                add r16, r17
                rjmp tx_byte

tx_byte:        sbis UCSRA, UDRE
                rjmp tx_byte
                out UDR, r16
                ret

rx_byte:        sbis UCSRA, RXC
                rjmp rx_byte
                in r16, UDR
                ret

spi_master:     ldi r16, MASTER_PORT_INIT
                out PORT, r16
                ldi r16, MASTER_DDR_INIT
                out DDR, r16
                ldi r16, MASTER_SPCR_INIT
                out SPCR, r16
                ret

spi_slave:      ldi r16, SLAVE_PORT_INIT
                out PORT, r16
                ldi r16, SLAVE_DDR_INIT
                out DDR, r16
                ldi r16, SLAVE_SPCR_INIT
                out SPCR, r16
                ret

spi_close:      ldi r16, CLOSE_SPCR_INIT
                out SPCR, r16
                ldi r16, CLOSE_DDR_INIT
                out DDR, r16
                ldi r16, CLOSE_PORT_INIT
                out PORT, r16
                ret

tx_slave_set:   cbi PORT, SS_PIN
                rcall txrx_spi

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

                ld r16, X+
                rcall txrx_spi
                sbiw r25:r24, 1
                brne PC - 3

                sbi PORT, SS_PIN
                ret

tx_slave_get:   cbi PORT, SS_PIN
                rcall txrx_spi

                rcall txrx_spi ; dummy for slave to have enough time to load response

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

                rcall txrx_spi
                st X+, r16
                sbiw r25:r24, 1
                brne PC - 3

                sbi PORT, SS_PIN
                ret

txrx_spi:       out SPDR, r16
                sbis SPSR, SPIF
                rjmp PC - 1
                in r16, SPDR
                ret

////////////////////////////////////////////////// Shared
STEP_SEPARATOR: .db "... ", 0
PASS_STRING: .db "PASS", 0
FAIL_STRING: .db "FAIL", 0

exec_steps:     set

exec_steps1:    lpm r24, Z+
                lpm r25, Z+
                adiw r25:r24, 0
                brne PC + 4
                rcall tx_crlf
                brts step_ret_pass
                rjmp step_ret_fail

                rcall tx_string
                sbrc ZL, 0
                adiw Z,1

                push ZL
                push ZH

                ldi ZL, low(STEP_SEPARATOR << 1)
                ldi ZH, high(STEP_SEPARATOR << 1)
                rcall tx_string

                movw Z, r25:r24
                icall ; these should return with step_ret_pass or step_ret_fail

                pop ZH
                pop ZL
                rjmp exec_steps1

step_ret_pass:  ldi ZL, low(PASS_STRING << 1)
                ldi ZH, high(PASS_STRING << 1)
                rjmp tx_string_crlf

step_ret_fail:  clt
                ldi ZL, low(FAIL_STRING << 1)
                ldi ZH, high(FAIL_STRING << 1)
                rjmp tx_string_crlf

////////////////////////////////////////////////// LC-8x8x8-RGB-00 (Master) / Interface

MASTER_COMM:    ldi r16, 'A'
                rcall tx_byte
                ret

////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Interface

LC_COMM_STEPS:
.dw LC_COMM_S1 \ .db "TX & RX big packet @ 250 kHz", 0
.dw LC_COMM_S2 \ .db "TX & RX big packet @ 500 kHz", 0
.dw LC_COMM_S3 \ .db "TX & RX big packet @ 1 MHz", 0
.dw LC_COMM_S4 \ .db "TX & RX big packet @ 2 MHz", 0
.dw LC_COMM_S5 \ .db "Check INT pin toggle, pass 1", 0
.dw LC_COMM_S5 \ .db "Check INT pin toggle, pass 2", 0
.dw 0

LC_COMM:        rcall spi_master

                ldi ZL, low(LC_COMM_STEPS << 1)
                ldi ZH, high(LC_COMM_STEPS << 1)
                rjmp exec_steps

LC_COMM_S1:     sbi SPSR, SPI2X
                ldi r16, MASTER_SPCR_INIT | (1 << SPR1)
                out SPCR, r16
                rjmp LC_COMM_S1_4

LC_COMM_S2:     cbi SPSR, SPI2X
                ldi r16, MASTER_SPCR_INIT | (1 << SPR0)
                out SPCR, r16
                rjmp LC_COMM_S1_4

LC_COMM_S3:     sbi SPSR, SPI2X
                ldi r16, MASTER_SPCR_INIT | (1 << SPR0)
                out SPCR, r16
                rjmp LC_COMM_S1_4

LC_COMM_S4:     cbi SPSR, SPI2X
                ldi r16, MASTER_SPCR_INIT
                out SPCR, r16
                rjmp LC_COMM_S1_4

LC_COMM_S1_4:   ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)
                ldi r24, low(PACKET_BUFFER + D01_TEST_SET_DATA_SIZE)
                ldi r25, high(PACKET_BUFFER + D01_TEST_SET_DATA_SIZE)
                clr r16

                st X+, r16
                inc r16
                cp XL, r24
                cpc XH, r25
                brlo PC - 4

                ldi r16, D01_TEST_SET
                ldi r24, low(D01_TEST_SET_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_DATA_SIZE)
                rcall tx_slave_set

                ldi r16, D01_TEST_GET
                ldi r24, low(D01_TEST_GET_DATA_SIZE)
                ldi r25, high(D01_TEST_GET_DATA_SIZE)
                rcall tx_slave_get

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)
                ldi r24, low(PACKET_BUFFER + D01_TEST_GET_DATA_SIZE)
                ldi r25, high(PACKET_BUFFER + D01_TEST_GET_DATA_SIZE)
                clr r16

                ld r17, X+
                cp r17, r16
                breq PC + 2
                rjmp step_ret_fail
                inc r16
                cp XL, r24
                cpc XH, r25
                brlo PC - 7

                rjmp step_ret_pass

LC_COMM_S5:     ldi r16, 1
                sts PACKET_BUFFER + D01_TEST_SET_INT_STATE_OFFSET, r16
                ldi r16, D01_TEST_SET_INT
                ldi r24, low(D01_TEST_SET_INT_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_INT_DATA_SIZE)
                rcall tx_slave_set

                ldi r16, 0
                dec r16
                brne PC - 1

                sbis PINREG, INT_PIN
                rjmp step_ret_fail

                ldi r16, 0
                sts PACKET_BUFFER + D01_TEST_SET_INT_STATE_OFFSET, r16
                ldi r16, D01_TEST_SET_INT
                ldi r24, low(D01_TEST_SET_INT_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_INT_DATA_SIZE)
                rcall tx_slave_set

                ldi r16, 0
                dec r16
                brne PC - 1

                sbic PINREG, INT_PIN
                rjmp step_ret_fail

                rjmp step_ret_pass

////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Shift Registers

LC_SR_STEPS:
.dw LC_SR_S1 \ .db "Load and read shift registers @ 250 kHz for 1 minute", 0
.dw LC_SR_S2 \ .db "Load and read shift registers @ 500 kHz for 1 minute", 0
.dw LC_SR_S3 \ .db "Load and read shift registers @ 1 MHz for 1 minute", 0
.dw LC_SR_S4 \ .db "Load and read shift registers @ 2 MHz for 1 minute", 0
.dw LC_SR_S5 \ .db "Load and read shift registers @ 4 MHz for 30 seconds", 0
.dw 0

LC_SR_COUNT_S: .db " errors ", 0

LC_SR:          rcall spi_master

                ldi ZL, low(LC_SR_STEPS << 1)
                ldi ZH, high(LC_SR_STEPS << 1)
                rjmp exec_steps

LC_SR_S1:       D01_TEST_SET_SR_FREQUENCY_AND_SECONDS_TO_PRESCALAR_AND_COUNT 250000, 60, r16, r17, r18, r19, r20
                rjmp LC_SR_S1_5

LC_SR_S2:       D01_TEST_SET_SR_FREQUENCY_AND_SECONDS_TO_PRESCALAR_AND_COUNT 500000, 60, r16, r17, r18, r19, r20
                rjmp LC_SR_S1_5

LC_SR_S3:       D01_TEST_SET_SR_FREQUENCY_AND_SECONDS_TO_PRESCALAR_AND_COUNT 1000000, 60, r16, r17, r18, r19, r20
                rjmp LC_SR_S1_5

LC_SR_S4:       D01_TEST_SET_SR_FREQUENCY_AND_SECONDS_TO_PRESCALAR_AND_COUNT 2000000, 60, r16, r17, r18, r19, r20
                rjmp LC_SR_S1_5

LC_SR_S5:       D01_TEST_SET_SR_FREQUENCY_AND_SECONDS_TO_PRESCALAR_AND_COUNT 4000000, 30, r16, r17, r18, r19, r20
                rjmp LC_SR_S1_5

LC_SR_S1_5:     sts PACKET_BUFFER + D01_TEST_SET_SR_PRESCALAR_OFFSET + 0, r16
                sts PACKET_BUFFER + D01_TEST_SET_SR_PRESCALAR_OFFSET + 1, r17
                sts PACKET_BUFFER + D01_TEST_SET_SR_COUNT_OFFSET + 0, r18
                sts PACKET_BUFFER + D01_TEST_SET_SR_COUNT_OFFSET + 1, r19
                sts PACKET_BUFFER + D01_TEST_SET_SR_COUNT_OFFSET + 2, r20

                ldi r16, D01_TEST_SET_SR
                ldi r24, low(D01_TEST_SET_SR_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_SR_DATA_SIZE)
                rcall tx_slave_set

                ldi r16, 0
                dec r16
                brne PC - 1

                sbis PINREG, INT_PIN
                rjmp step_ret_fail 

                sbic PINREG, INT_PIN
                rjmp PC - 1

                ldi r16, D01_TEST_GET_SR
                ldi r24, low(D01_TEST_GET_SR_DATA_SIZE)
                ldi r25, high(D01_TEST_GET_SR_DATA_SIZE)
                rcall tx_slave_get

                lds r17, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 0
                lds r18, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 1
                lds r19, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 2
                
                rcall tx_24_bit_int
                ldi ZL, low(LC_SR_COUNT_S << 1)
                ldi ZH, high(LC_SR_COUNT_S << 1)
                rcall tx_string

                lds r17, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 0
                lds r18, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 1
                lds r19, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 2

                clr r16
                cp r17, r16
                cpc r18, r16
                cpc r19, r16
                breq PC + 2
                rjmp step_ret_fail
                rjmp step_ret_pass

////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, no LEDs installed
////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 0 (back)
////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 1
////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 2
////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 3
////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 4
////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 5
////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 6
////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice 7 (front)
////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave) / Output, all LEDs installed

LC_OUTPUTS:     ldi r16, low(lc_outputs_lim)
                ldi r17, high(lc_outputs_lim)
                ldi r18, low(lc_outputs_tr)
                ldi r19, high(lc_outputs_tr)
                rjmp lc_out

LC_SLICE0:      ldi r16, 0 * D01_CUBE_EDGE_SIZE
                rjmp LC_SLICE

LC_SLICE1:      ldi r16, 1 * D01_CUBE_EDGE_SIZE
                rjmp LC_SLICE

LC_SLICE2:      ldi r16, 2 * D01_CUBE_EDGE_SIZE
                rjmp LC_SLICE

LC_SLICE3:      ldi r16, 3 * D01_CUBE_EDGE_SIZE
                rjmp LC_SLICE

LC_SLICE4:      ldi r16, 4 * D01_CUBE_EDGE_SIZE
                rjmp LC_SLICE

LC_SLICE5:      ldi r16, 5 * D01_CUBE_EDGE_SIZE
                rjmp LC_SLICE

LC_SLICE6:      ldi r16, 6 * D01_CUBE_EDGE_SIZE
                rjmp LC_SLICE

LC_SLICE7:      ldi r16, 7 * D01_CUBE_EDGE_SIZE
                rjmp LC_SLICE

LC_SLICE:       mov r2, r16
                ldi r16, low(lc_slice_lim)
                ldi r17, high(lc_slice_lim)
                ldi r18, low(lc_slice_tr)
                ldi r19, high(lc_slice_tr)
                rjmp lc_out

LC_FULL:        ldi r16, low(lc_full_lim)
                ldi r17, high(lc_full_lim)
                ldi r18, low(lc_full_tr)
                ldi r19, high(lc_full_tr)
                rjmp lc_out

LC_OUTPUTS_MENU:
.dw lc_out_prev \ .db 'p', "previous step", 0
.dw lc_out_next \ .db 'n', "next step", 0
.dw lc_out_quit \ .db 'q', "quit", 0
.dw 0

lc_out:         movw r5:r4, r17:r16
                movw r7:r6, r19:r18

                rcall spi_master

                ldi ZL, low(LC_OUTPUTS_MENU << 1)
                ldi ZH, high(LC_OUTPUTS_MENU << 1)
                
lc_out_menu:    lpm r24, Z+
                lpm r25, Z+
                adiw r25:r24, 0
                breq lc_out_cont

                lpm r17, Z+

                ldi r16, '['
                rcall tx_byte
                mov r16, r17
                rcall tx_byte
                ldi r16, ']'
                rcall tx_byte
                ldi r16, ' '
                rcall tx_byte
                rcall tx_string_crlf

                sbrc ZL, 0
                adiw Z,1
                rjmp lc_out_menu

lc_out_cont:    clr r8
                clr r9
                rcall lc_out_change

lc_out_rx:      rcall rx_byte

                ldi ZL, low(LC_OUTPUTS_MENU << 1)
                ldi ZH, high(LC_OUTPUTS_MENU << 1)

lc_out_check:   lpm r24, Z+
                lpm r25, Z+
                adiw r25:r24, 0
                breq lc_out_rx

                lpm r17, Z+
                cp r17, r16
                breq lc_out_exec

                lpm r17, Z+
                tst r17
                brne PC - 2

                sbrc ZL, 0
                adiw Z,1
                rjmp lc_out_check

lc_out_exec:    movw Z, r25:r24
                icall
                rjmp lc_out_rx

lc_out_prev:    movw r25:r24, r9:r8
                sbiw r25:r24, 1
                brcc PC + 2
                ret

                movw r9:r8, r25:r24
                rjmp lc_out_change

lc_out_next:    movw Z, r5:r4
                icall

                movw r25:r24, r9:r8
                adiw r25:r24, 1
                cp r24, r16
                cpc r25, r17
                brlo PC + 2
                ret

                movw r9:r8, r25:r24
                rjmp lc_out_change

lc_out_quit:    pop r16
                pop r16
                ret

LC_OUT_COLOR_SHORTHAND:
.db "-RGYBMCW"

lc_out_change:  movw Z, r7:r6
                movw r25:r24, r9:r8
                icall

                sts PACKET_BUFFER + D01_TEST_SET_LEDS_START_LED_OFFSET, r16
                sts PACKET_BUFFER + D01_TEST_SET_LEDS_END_LED_OFFSET, r17
                sts PACKET_BUFFER + D01_TEST_SET_LEDS_COLOR_OFFSET, r18
                sts PACKET_BUFFER + D01_TEST_SET_LEDS_LEVEL_OFFSET, r19

                ldi r16, D01_TEST_SET_LEDS
                ldi r24, low(D01_TEST_SET_LEDS_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_LEDS_DATA_SIZE)
                rcall tx_slave_set

                rcall tx_crlf

                ldi r17, 0
                ldi r18, D01_CUBE_EDGE_SIZE - 1

                lds r19, PACKET_BUFFER + D01_TEST_SET_LEDS_START_LED_OFFSET
                lds r20, PACKET_BUFFER + D01_TEST_SET_LEDS_END_LED_OFFSET
                lds r21, PACKET_BUFFER + D01_TEST_SET_LEDS_COLOR_OFFSET
                lds r22, PACKET_BUFFER + D01_TEST_SET_LEDS_LEVEL_OFFSET

lc_out_print:   ldi r16, '-'
                cp r18, r22
                brne PC + 3
                mov r16, r18
                subi r16, -'0'

                rcall tx_byte
                
                ldi r16, '|'
                rcall tx_byte

lc_out_print1:  ldi r16, D01_TEST_SET_LEDS_COLOR_NONE
                cp r17, r19
                brlo PC + 4
                cp r20, r17
                brlo PC + 2
                mov r16, r21

                ldi ZL, low(LC_OUT_COLOR_SHORTHAND << 1)
                ldi ZH, high(LC_OUT_COLOR_SHORTHAND << 1)
                add ZL, r16
                ldi r16, 0
                adc ZH, r16
                lpm r16, Z

                rcall tx_byte

                inc r17
                mov r16, r17
                andi r16, D01_CUBE_EDGE_SIZE - 1
                brne lc_out_print1

                rcall tx_crlf
                dec r18

                cpi r17, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                brlo lc_out_print
                ret

lc_outputs_lim: ldi r16, low(D01_CUBE_EDGE_SIZE + (D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE) * 4)
                ldi r17, high(D01_CUBE_EDGE_SIZE + (D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE) * 4)
                ret

lc_outputs_tr:  ldi r16, low(D01_CUBE_EDGE_SIZE)
                ldi r17, high(D01_CUBE_EDGE_SIZE)
                cp r24, r16
                cpc r25, r17
                brsh PC + 6

                mov r19, r24
                clr r16
                clr r17
                ldi r18, D01_TEST_SET_LEDS_COLOR_WHITE
                ret

                sbiw r25:r24, D01_CUBE_EDGE_SIZE

                rcall lc_out_color

                mov r16, r24
                mov r17, r24
                ldi r19, D01_CUBE_EDGE_SIZE - 1
                ret

lc_slice_lim:   ldi r16, low((D01_CUBE_EDGE_SIZE + 1) * D01_CUBE_EDGE_SIZE * 4)
                ldi r17, high((D01_CUBE_EDGE_SIZE + 1) * D01_CUBE_EDGE_SIZE * 4)
                ret

lc_slice_tr:    rcall lc_out_color

                ldi r19, -1

                inc r19
                subi r24, D01_CUBE_EDGE_SIZE + 1
                brcc PC - 2
                
                subi r24, -(D01_CUBE_EDGE_SIZE + 1)
                
                cpi r24, D01_CUBE_EDGE_SIZE
                breq PC + 4
                mov r16, r24
                mov r17, r24
                rjmp PC + 3
                ldi r16, 0
                ldi r17, D01_CUBE_EDGE_SIZE - 1

                add r16, r2
                add r17, r2
                ret

lc_full_lim:    ldi r16, low((D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1) * D01_CUBE_EDGE_SIZE * 4)
                ldi r17, high((D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1) * D01_CUBE_EDGE_SIZE * 4)
                ret

lc_full_tr:     rcall lc_out_color

                ldi r19, -1

                inc r19
                subi r24, low(D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1)
                sbci r25, high(D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1)
                brcc PC - 3
                
                subi r24, low(-(D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1))
                sbci r25, high(-(D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1))
                
                cpi r24, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                breq PC + 4
                mov r16, r24
                mov r17, r24
                rjmp PC + 3
                ldi r16, 0
                ldi r17, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE - 1
                ret

lc_out_color:   mov r18, r24
                andi r18, 0x03

                lsr r25
                ror r24
                lsr r25
                ror r24

                cpi r18, 0
                brne PC + 3
                ldi r18, D01_TEST_SET_LEDS_COLOR_RED
                ret

                cpi r18, 1
                brne PC + 3
                ldi r18, D01_TEST_SET_LEDS_COLOR_GREEN
                ret

                cpi r18, 2
                brne PC + 3
                ldi r18, D01_TEST_SET_LEDS_COLOR_BLUE
                ret

                ldi r18, D01_TEST_SET_LEDS_COLOR_WHITE
                ret
