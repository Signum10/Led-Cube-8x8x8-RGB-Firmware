.include "definitions.inc"

start:          ldi r16, PORTB_INIT
                out PORTB, r16
                ldi r16, DDRB_INIT
                out DDRB, r16

                ldi r16, PORTC_INIT
                out PORTC, r16
                ldi r16, DDRC_INIT
                out DDRC, r16

                ldi r16, PORTD_INIT
                out PORTD, r16
                ldi r16, DDRD_INIT
                out DDRD, r16

                ldi r16, SPCR_INIT
                out SPCR, r16

                ldi r16, high(ICR1_INIT)
                sts ICR1H, r16
                ldi r16, low(ICR1_INIT)
                sts ICR1L, r16
                ldi r16, high(OCR1A_INIT)
                sts OCR1AH, r16
                ldi r16, low(OCR1A_INIT)
                sts OCR1AL, r16
                ldi r16, TCCR1A_INIT
                sts TCCR1A, r16
                ldi r16, TCCR1B_INIT
                sts TCCR1B, r16

                ldi YL, low(SLAVE_PROC)
                ldi YH, high(SLAVE_PROC)
                ldi r16, SLAVE_PROC_DATA_SIZE
                ldi r17, 0

                st Y+, r17
                dec r16
                brne PC - 2

loop_init:      ldi r16, ~(1 << INT_PIN_SLAVE0)
                mov CURRENT_SLAVE, r16
                
                ldi YL, low(SLAVE_PROC)
                ldi YH, high(SLAVE_PROC)

loop:           in r16, INT_PINREG
                and r16, CURRENT_SLAVE
                brne loop_cont

                ldi r16, DXX_CMD_GET_INT
                ldi r24, low(DXX_CMD_GET_INT_DATA_SIZE)
                ldi r25, high(DXX_CMD_GET_INT_DATA_SIZE)
                rcall tx_slave_get

                lds CURRENT_INT, PACKET_BUFFER

                sbrs CURRENT_INT, DXX_CMD_GET_INT_FLAG_RESET
                rjmp loop_call_proc

                ldi r16, DXX_CMD_GET_DEVID
                ldi r24, low(DXX_CMD_GET_DEVID_DATA_SIZE)
                ldi r25, high(DXX_CMD_GET_DEVID_DATA_SIZE)
                rcall tx_slave_get

                lds r17, PACKET_BUFFER

                ldi r16, 0
                std Y + 0, r16
                std Y + 1, r16

                ldi ZL, low(LUT_devids_proc << 1)
                ldi ZH, high(LUT_devids_proc << 1)

                lpm r16, Z
                tst r16
                breq loop_cont
                cp r16, r17
                breq PC + 3
                adiw Z, 4
                rjmp PC - 6

                adiw Z, 2
                lpm r16, Z+
                std Y + 0, r16
                lpm r16, Z+
                std Y + 1, r16

loop_call_proc: ldd ZL, Y + 0
                ldd ZH, Y + 1
                adiw Z, 0
                breq loop_cont

                push YL
                push YH
                icall
                pop YH
                pop YL

loop_cont:      adiw Y, SLAVE_PROC_ELEMENT_SIZE
                sec
                rol CURRENT_SLAVE
                ldi r16, ~(1 << (INT_PIN_SLAVE5 + 1))
                cp CURRENT_SLAVE, r16
                brne loop
                rjmp loop_init

LUT_devids_proc:
.db D01_CMD_GET_DEVID_VALUE, 0 \ .dw proc_LC
.db DTT_CMD_GET_DEVID_VALUE, 0 \ .dw proc_TT
.db 0

//////////////////////////////////////////////////

tx_slave_set:   in XL, SS_PORT
                and XL, CURRENT_SLAVE
                out SS_PORT, XL

                rcall txrx_spi

                sbiw r25:r24, 0
                breq PC + 7

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

                ld r16, X+
                rcall txrx_spi
                sbiw r25:r24, 1
                brne PC - 3

                ldi XL, SS_PORT_INIT
                out SS_PORT, XL
                ret

tx_slave_get:   in XL, SS_PORT
                and XL, CURRENT_SLAVE
                out SS_PORT, XL

                rcall txrx_spi

                rcall txrx_spi ; dummy for slave to have enough time to load response

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

                rcall txrx_spi
                st X+, r16
                sbiw r25:r24, 1
                brne PC - 3

                ldi XL, SS_PORT_INIT
                out SS_PORT, XL
                ret

txrx_spi:       out SPDR, r16
                in r0, SPSR
                sbrs r0, SPIF
                rjmp PC - 2
                in r16, SPDR
                ret

////////////////////////////////////////////////// Led Cube
proc_LC:        ret

////////////////////////////////////////////////// Test Slave
proc_TT:        sbrs CURRENT_INT, DTT_CMD_GET_INT_FLAG_SEND_PORT
                rjmp proc_TT_get

proc_TT_port:   ldi r16, ~(1 << INT_PIN_SLAVE0)
                ldi r17, 0

                cp r16, CURRENT_SLAVE
                breq PC + 5
                sec
                rol r16
                inc r17
                rjmp PC - 5

                sts PACKET_BUFFER, r17

                ldi r16, DTT_CMD_SEND_PORT
                ldi r24, low(DTT_CMD_SEND_PORT_DATA_SIZE)
                ldi r25, high(DTT_CMD_SEND_PORT_DATA_SIZE)
                rcall tx_slave_set

proc_TT_get:    sbrs CURRENT_INT, DTT_CMD_GET_INT_FLAG_GET_DATA
                rjmp proc_TT_set

                ldi r16, DTT_CMD_GET_DATA
                ldi r24, low(DTT_CMD_GET_DATA_SIZE)
                ldi r25, high(DTT_CMD_GET_DATA_SIZE)
                rcall tx_slave_get

proc_TT_set:    sbrs CURRENT_INT, DTT_CMD_GET_INT_FLAG_SET_DATA
                ret

                ldi r16, DTT_CMD_SET_DATA
                ldi r24, low(DTT_CMD_SET_DATA_SIZE)
                ldi r25, high(DTT_CMD_SET_DATA_SIZE)
                rjmp tx_slave_set
