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
                mov r17, CURRENT_SLAVE
                com r17
                and r16, r17
                brne loop_cont

                ldi r16, DXX_CMD_GET_INT
                ldi r24, low(DXX_CMD_GET_INT_DATA_SIZE)
                ldi r25, high(DXX_CMD_GET_INT_DATA_SIZE)
                ldi XL, low(0)
                ldi XH, high(0)
                rcall tx_slave_get_x

                mov CURRENT_INT, r0

                sbrs CURRENT_INT, DXX_CMD_GET_INT_FLAG_RESET
                rjmp loop_call_proc

                ldi r16, DXX_CMD_GET_DEVID
                ldi r24, low(DXX_CMD_GET_DEVID_DATA_SIZE)
                ldi r25, high(DXX_CMD_GET_DEVID_DATA_SIZE)
                ldi XL, low(0)
                ldi XH, high(0)
                rcall tx_slave_get_x

                mov r17, r0

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
                sbrc CURRENT_SLAVE, INT_PIN_SLAVE5 + 1
                rjmp loop
                rjmp loop_init

LUT_devids_proc:
.db D01_CMD_GET_DEVID_VALUE, 0 \ .dw proc_LC
.db DTT_CMD_GET_DEVID_VALUE, 0 \ .dw proc_TT
.db 0

//////////////////////////////////////////////////

tx_slave_set:   ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

tx_slave_set_x: in r1, SS_PORT
                and r1, CURRENT_SLAVE
                out SS_PORT, r1

                rcall txrx_spi

                sbiw r25:r24, 0
                breq PC + 5

                ld r16, X+
                rcall txrx_spi
                sbiw r25:r24, 1
                brne PC - 3

                ldi XL, SS_PORT_INIT
                out SS_PORT, XL
                ret

tx_slave_get:   ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

tx_slave_get_x: in r1, SS_PORT
                and r1, CURRENT_SLAVE
                out SS_PORT, r1

                rcall txrx_spi

                rcall txrx_spi ; dummy for slave to have enough time to load response

                rcall txrx_spi
                st X+, r16
                sbiw r25:r24, 1
                brne PC - 3

                ldi XL, SS_PORT_INIT
                out SS_PORT, XL
                ret

txrx_spi:       out SPDR, r16
                in r16, SPSR
                sbrs r16, SPIF
                rjmp PC - 2
                in r16, SPDR
                ret

////////////////////////////////////////////////// Led Cube
proc_LC:        sbrs CURRENT_INT, D01_CMD_GET_INT_FLAG_RESET
                rjmp proc_LC_frame

                ldi r16, 0
                sts ANIMATION_COUNTER + 0, r16
                sts ANIMATION_COUNTER + 1, r16

                ldi r16, 0
                ldi r17, 0
                ldi r18, 0
                rcall LC_fill
                rcall LC_update_frame

proc_LC_frame:  sbrs CURRENT_INT, D01_CMD_GET_INT_FLAG_NEW_FRAME_RDY
                ret

                ldi r16, D01_CMD_SET_FRAME
                ldi r24, low(D01_FRAME_SIZE)
                ldi r25, high(D01_FRAME_SIZE)
                ldi XL, low(FRAME_BUFFER)
                ldi XH, high(FRAME_BUFFER)
                rcall tx_slave_set_x

                rjmp LC_update_frame

LC_update_frame:lds r24, ANIMATION_COUNTER + 0
                lds r25, ANIMATION_COUNTER + 1
                adiw r25:r24, 1
                sts ANIMATION_COUNTER + 0, r24
                sts ANIMATION_COUNTER + 1, r25
                sbiw r25:r24, 1

                mov r16, r25
                lsr r16
                andi r16, 0b111

                cpi r16, 0
                brne PC + 4
                ldi r19, 15
                ldi r20, 0
                ldi r21, 0

                cpi r16, 2
                brne PC + 4
                ldi r19, 0
                ldi r20, 15
                ldi r21, 0

                cpi r16, 4
                brne PC + 4
                ldi r19, 0
                ldi r20, 0
                ldi r21, 15

                cpi r16, 6
                brne PC + 4
                ldi r19, 15
                ldi r20, 15
                ldi r21, 15

                sbrs r16, 0
                rjmp PC + 4
                ldi r19, 0
                ldi r20, 0
                ldi r21, 0

                mov r16, r24

                mov r17, r24
                lsl r17
                swap r17

                lsl r24
                rol r25
                lsl r24
                rol r25

                mov r18, r25

                rjmp LC_dot

; r16 = R
; r17 = G
; r18 = B
LC_fill:        andi r16, (1 << D01_LED_COLOR_BITS) - 1
                andi r17, (1 << D01_LED_COLOR_BITS) - 1
                andi r18, (1 << D01_LED_COLOR_BITS) - 1

                mov r13, r18
                swap r13
                or r13, r17

                mov r14, r16
                swap r14
                or r14, r18

                mov r15, r17
                swap r15
                or r15, r16

                ldi XL, low(FRAME_BUFFER)
                ldi XH, high(FRAME_BUFFER)
                ldi r24, low(D01_FRAME_SIZE)
                ldi r25, high(D01_FRAME_SIZE)
                
                st X+, r13
                st X+, r14
                st X+, r15
                sbiw r25:r24, 3
                brne PC - 4

                ret

; r16 = X (left -> right)
; r17 = Y (back -> front)
; r18 = Z (buttom -> top)
; r19 = R
; r20 = G
; r21 = B
LC_dot:         andi r16, D01_CUBE_EDGE_SIZE - 1
                andi r17, D01_CUBE_EDGE_SIZE - 1
                andi r18, D01_CUBE_EDGE_SIZE - 1
                andi r19, (1 << D01_LED_COLOR_BITS) - 1
                andi r20, (1 << D01_LED_COLOR_BITS) - 1
                andi r21, (1 << D01_LED_COLOR_BITS) - 1

                lsl r16
                lsl r16

                swap r17
                lsl r17
                or r17, r16
                
                lsr r18
                ror r17
                
                mov r14, r17
                mov r15, r18
                
                lsr r18
                ror r17

                add r17, r14
                adc r18, r15

                lsr r18
                ror r17
                
                ldi XL, low(FRAME_BUFFER)
                ldi XH, high(FRAME_BUFFER)
                add XL, r17
                adc XH, r18

                sbrc r16, 2
                rjmp LC_dot_odd_add

LC_dot_even_add:swap r21
                or r21, r20
                st X+, r21

                ld r16, X
                andi r16, 0x0F
                swap r19
                or r16, r19
                st X, r16
                ret

LC_dot_odd_add: ld r16, X
                andi r16, 0xF0
                or r16, r21
                st X+, r16

                swap r20
                or r20, r19
                st X, r20
                ret

////////////////////////////////////////////////// Test Slave
proc_TT:        sbrs CURRENT_INT, DTT_CMD_GET_INT_FLAG_SEND_PORT
                rjmp proc_TT_get

proc_TT_port:   mov r16, CURRENT_SLAVE
                ldi r17, -1

                inc r17
                lsr r16
                brcs PC - 2

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
