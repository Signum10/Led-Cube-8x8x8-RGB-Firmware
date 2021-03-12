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
.dw LC_SLICE    \ .db "LC-8x8x8-RGB-01 (Led Cube Slave) / Output, installed LED slice", 0
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
                breq tx_slave2

                rcall txrx_spi ; dummy for slave to have enough time to load response

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

                rcall txrx_spi
                st X+, r16
                sbiw Z, 1
                brne PC - 3

tx_slave2:      sbi PORT, SS_PIN
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

////////////////////////////////////////////////// LC-8x8x8-RGB-00 (Master)

MASTER_COMM:    ldi r16, 'A'
                rcall tx_byte
                ret

////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave)

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
                ldi r24, low(PACKET_BUFFER + PACKET_BUFFER_SIZE)
                ldi r25, high(PACKET_BUFFER + PACKET_BUFFER_SIZE)
                clr r16

                st X+, r16
                inc r16
                cp XL, r24
                cpc XH, r25
                brlo PC - 4

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

                ld r17, X+
                cp r17, r16
                breq PC + 2
                rjmp step_ret_fail
                inc r16
                cp XL, r24
                cpc XH, r25
                brlo PC - 7

                rjmp step_ret_pass

LC_COMM_S5:     ldi r16, D01_SET_INT_HIGH
                ldi YL, 0
                ldi YH, 0
                ldi ZL, 0
                ldi ZH, 0
                rcall tx_slave

                sbis PINREG, INT_PIN
                rjmp step_ret_fail

                ldi r16, D01_SET_INT_LOW
                ldi YL, 0
                ldi YH, 0
                ldi ZL, 0
                ldi ZH, 0
                rcall tx_slave

                sbic PINREG, INT_PIN
                rjmp step_ret_fail

                rjmp step_ret_pass

LC_SR_STEPS:
.dw LC_SR_S1 \ .db "Load and read shift registers @ 250 kHz for 1 minute", 0
.dw LC_SR_S2 \ .db "Load and read shift registers @ 500 kHz for 1 minute", 0
.dw LC_SR_S3 \ .db "Load and read shift registers @ 1 MHz for 1 minute", 0
.dw LC_SR_S4 \ .db "Load and read shift registers @ 2 MHz for 1 minute", 0
.dw LC_SR_S5 \ .db "Load and read shift registers @ 4 MHz for 1 minute", 0
.dw 0

LC_SR_COUNT_S: .db " errors ", 0

LC_SR:          rcall spi_master

                ldi ZL, low(LC_SR_STEPS << 1)
                ldi ZH, high(LC_SR_STEPS << 1)
                rjmp exec_steps

LC_SR_S1:       ldi r16, low((D01_F_CPU / (2 * 250000)) - 1)
                ldi r17, high((D01_F_CPU / (2 * 250000)) - 1)
                ldi r18, low(60 * (250000 / 8))
                ldi r19, byte2(60 * (250000 / 8))
                ldi r20, byte3(60 * (250000 / 8))
                rjmp LC_SR_S1_5

LC_SR_S2:       ldi r16, low((D01_F_CPU / (2 * 500000)) - 1)
                ldi r17, high((D01_F_CPU / (2 * 500000)) - 1)
                ldi r18, low(60 * (500000 / 8))
                ldi r19, byte2(60 * (500000 / 8))
                ldi r20, byte3(60 * (500000 / 8))
                rjmp LC_SR_S1_5

LC_SR_S3:       ldi r16, low((D01_F_CPU / (2 * 1000000)) - 1)
                ldi r17, high((D01_F_CPU / (2 * 1000000)) - 1)
                ldi r18, low(60 * (1000000 / 8))
                ldi r19, byte2(60 * (1000000 / 8))
                ldi r20, byte3(60 * (1000000 / 8))
                rjmp LC_SR_S1_5

LC_SR_S4:       ldi r16, low((D01_F_CPU / (2 * 2000000)) - 1)
                ldi r17, high((D01_F_CPU / (2 * 2000000)) - 1)
                ldi r18, low(60 * (2000000 / 8))
                ldi r19, byte2(60 * (2000000 / 8))
                ldi r20, byte3(60 * (2000000 / 8))
                rjmp LC_SR_S1_5

LC_SR_S5:       ldi r16, low((D01_F_CPU / (2 * 4000000)) - 1)
                ldi r17, high((D01_F_CPU / (2 * 4000000)) - 1)
                ldi r18, low(60 * (4000000 / 8))
                ldi r19, byte2(60 * (4000000 / 8))
                ldi r20, byte3(60 * (4000000 / 8))
                rjmp LC_SR_S1_5

LC_SR_S1_5:     ldi YL, low(PACKET_BUFFER)
                ldi YH, high(PACKET_BUFFER)
                std Y + D01_SR_TEST_PRESCALAR_OFFSET + 0, r16
                std Y + D01_SR_TEST_PRESCALAR_OFFSET + 1, r17
                std Y + D01_SR_TEST_COUNT_OFFSET + 0, r18
                std Y + D01_SR_TEST_COUNT_OFFSET + 1, r19
                std Y + D01_SR_TEST_COUNT_OFFSET + 2, r20

                ldi r16, D01_SET_TEST_DATA
                ldi YL, low(D01_SR_TEST_DATA_SIZE)
                ldi YH, high(D01_SR_TEST_DATA_SIZE)
                ldi ZL, 0
                ldi ZH, 0
                rcall tx_slave

                ldi r16, D01_START_SR_TEST
                ldi YL, 0
                ldi YH, 0
                ldi ZL, 0
                ldi ZH, 0
                rcall tx_slave

                ldi r16, 0
                dec r16
                brne PC - 1

                sbis PINREG, INT_PIN
                rjmp step_ret_fail 

                sbic PINREG, INT_PIN
                rjmp PC - 1

                ldi r16, D01_GET_TEST_DATA
                ldi YL, 0
                ldi YH, 0
                ldi ZL, low(D01_SR_TEST_DATA_SIZE)
                ldi ZH, high(D01_SR_TEST_DATA_SIZE)
                rcall tx_slave
                
                ldi YL, low(PACKET_BUFFER)
                ldi YH, high(PACKET_BUFFER)
                ldd r17, Y + D01_SR_TEST_ERROR_COUNT_OFFSET + 0
                ldd r18, Y + D01_SR_TEST_ERROR_COUNT_OFFSET + 1
                ldd r19, Y + D01_SR_TEST_ERROR_COUNT_OFFSET + 2
                
                rcall tx_24_bit_int
                ldi ZL, low(LC_SR_COUNT_S << 1)
                ldi ZH, high(LC_SR_COUNT_S << 1)
                rcall tx_string

                ldd r17, Y + D01_SR_TEST_ERROR_COUNT_OFFSET + 0
                ldd r18, Y + D01_SR_TEST_ERROR_COUNT_OFFSET + 1
                ldd r19, Y + D01_SR_TEST_ERROR_COUNT_OFFSET + 2

                clr r16
                cp r17, r16
                cpc r18, r16
                cpc r19, r16
                breq PC + 2
                rjmp step_ret_fail
                rjmp step_ret_pass

LC_OUTPUTS:     ldi r16, 'Y'
                rcall tx_byte
                ret

LC_SLICE:       ldi r16, 'Z'
                rcall tx_byte
                ret

LC_FULL:        ldi r16, 'W'
                rcall tx_byte
                ret
