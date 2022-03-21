.include "definitions.inc"

.org 0x0000     rjmp start
.org INT0addr   ldi SPI_STATE_REGISTER, SPI_STATE_START
                reti
.org INT1addr   reti
.org PCI0addr   reti
.org PCI1addr   reti
.org PCI2addr   reti
.org WDTaddr    reti
.org OC2Aaddr   reti
.org OC2Baddr   rjmp INT_LATCH
.org OVF2addr   reti
.org ICP1addr   reti
.org OC1Aaddr   reti
.org OC1Baddr   reti
.org OVF1addr   reti
.org OC0Aaddr   reti
.org OC0Baddr   reti
.org OVF0addr   reti
.org SPIaddr    rjmp INT_SPI
.org URXCaddr   reti
.org UDREaddr   reti
.org UTXCaddr   reti
.org ADCCaddr   reti
.org ERDYaddr   reti
.org ACIaddr    reti
.org TWIaddr    reti
.org SPMRaddr   reti
.org INT_VECTORS_SIZE

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
                sbi MISO_DDR, MISO_PIN

                ldi r16, EICRA_INIT
                sts EICRA, r16
                ldi r16, EIMSK_INIT
                out EIMSK, r16

                ldi r16, UCSR0C_INIT
                sts UCSR0C, r16
                ldi r16, UCSR0B_INIT
                sts UCSR0B, r16
                ldi r16, high(UBRR0_INIT)
                sts UBRR0H, r16
                ldi r16, low(UBRR0_INIT)
                sts UBRR0L, r16

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

                ldi r16, OCR2B_INIT
                sts OCR2B, r16
                ldi r16, TIMSK2_INIT
                sts TIMSK2, r16

                ldi SPI_STATE_REGISTER, SPI_STATE_END

                ldi r16, low(CMD_SET_FRAME_DATA)
                ldi r17, high(CMD_SET_FRAME_DATA)
                movw CURRENT_FRAME_H:CURRENT_FRAME_L, r17:r16

                ldi r16, low(CMD_SET_FRAME_DATA + D01_FRAME_SIZE)
                ldi r17, high(CMD_SET_FRAME_DATA + D01_FRAME_SIZE)
                movw NEXT_FRAME_H:NEXT_FRAME_L, r17:r16

                ldi r16, D01_CMD_GET_DEVID_VALUE
                sts CMD_GET_DEVID_DATA, r16

                rcall NORMAL_MODE

                ldi r16, 1 << D01_CMD_GET_INT_FLAG_RESET
                sts CMD_GET_INT_DATA, r16
                sbi INT_PORT, INT_PIN
                sei

loop:           sbis FLAGS, FLAG_MODE_CHANGED
                rjmp loop_cont
                cli
                cbi FLAGS, FLAG_MODE_CHANGED

                sbis FLAGS, FLAG_TEST_STATE
                rjmp PC + 4
                rcall NORMAL_MODE
                sei
                rjmp loop

                rcall TEST_MODE
                sei

loop_cont:      sbis FLAGS, FLAG_TEST_COMMAND
                rjmp loop
                cbi FLAGS, FLAG_TEST_COMMAND

                cpi SPI_OPCODE_REGISTER, D01_TEST_SET_SR
                brne PC + 3
                rcall TEST_SET_SR
                rjmp loop

                cpi SPI_OPCODE_REGISTER, D01_TEST_SET_LEDS
                brne loop
                rcall TEST_SET_LEDS
                rjmp loop

//////////////////////////////////////////////////

NORMAL_MODE:    movw Y, CURRENT_FRAME_H:CURRENT_FRAME_L
                ldi ZL, low(D01_FRAME_SIZE)
                ldi ZH, high(D01_FRAME_SIZE)
                ldi r16, 0

                st Y+, r16
                sbiw Z, 1
                brne PC - 2

                ldi r16, D01_CMD_SET_BRIGHT_MAX
                mov CURRENT_BRIGHT, r16
                ldi CURRENT_STAGE, STAGE_MAX - 1
                ldi CURRENT_LEVEL, LEVEL_MAX - 1

                ldi r16, 1 << TXC0
                sts UCSR0A, r16

                .if COMMON_K == 1
                ldi r16, 0xFF
                .else
                ldi r16, 0x00
                .endif

                ldi r17, (D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE * D01_LED_COLORS) / 8

                lds r15, UCSR0A
                sbrs r15, UDRE0
                rjmp PC - 3
                sts UDR0, r16

                dec r17
                brne PC - 7

                com r16
                ldi r17, D01_CUBE_EDGE_SIZE / 8

                lds r15, UCSR0A
                sbrs r15, UDRE0
                rjmp PC - 3
                sts UDR0, r16

                dec r17
                brne PC - 7

                lds r15, UCSR0A
                sbrs r15, TXC0
                rjmp PC - 3

                sbi LATCH_PORT, LATCH_PIN
                ldi r16, 0
                dec r16
                brne PC - 1
                cbi LATCH_PORT, LATCH_PIN

                cbi ENABLE_PORT, ENABLE_PIN

                cbi FLAGS, FLAG_TEST_STATE
                cbi FLAGS, FLAG_TEST_COMMAND
                
                ldi r16, TCCR2A_INIT
                sts TCCR2A, r16
                ldi r16, TCCR2B_INIT
                sts TCCR2B, r16
                ret

//////////////////////////////////////////////////

TEST_MODE:      sbi ENABLE_PORT, ENABLE_PIN

                ldi r16, 0
                sts TCCR2A, r16
                sts TCCR2B, r16
                sts TCNT2, r16
                ldi r16, TIFR2_CLR
                sts TIFR2, r16

                cbi LATCH_PORT, LATCH_PIN

                sbi FLAGS, FLAG_TEST_STATE
                cbi FLAGS, FLAG_FRAME_CHANGED
                cbi FLAGS, FLAG_BRIGHT_CHANGED
                ret

//////////////////////////////////////////////////

INT_SPI:        ld SPI_DATA_REGISTER, X
                out SPDR, SPI_DATA_REGISTER
                in SPI_DATA_REGISTER, SPDR

                in SPI_SREG_SAVE, SREG

STATE_WRITE:    cpi SPI_STATE_REGISTER, SPI_STATE_WRITE
                brne STATE_READ

                st X+, SPI_DATA_REGISTER
                
                cp XL, SPI_POINTER_END_L
                cpc XH, SPI_POINTER_END_H
                brsh PC + 3
                out SREG, SPI_SREG_SAVE
                reti

                cpi SPI_OPCODE_REGISTER, D01_CMD_SET_FRAME
                brne PC + 7
                sbic FLAGS, FLAG_TEST_STATE
                sbi FLAGS, FLAG_MODE_CHANGED
                sbi FLAGS, FLAG_FRAME_CHANGED
                ldi SPI_STATE_REGISTER, SPI_STATE_END
                out SREG, SPI_SREG_SAVE
                reti

                cpi SPI_OPCODE_REGISTER, D01_CMD_SET_BRIGHT
                brne PC + 7
                sbic FLAGS, FLAG_TEST_STATE
                sbi FLAGS, FLAG_MODE_CHANGED
                sbi FLAGS, FLAG_BRIGHT_CHANGED
                ldi SPI_STATE_REGISTER, SPI_STATE_END
                out SREG, SPI_SREG_SAVE
                reti

                cpi SPI_OPCODE_REGISTER, D01_TEST_SET_SR
                breq PC + 3
                cpi SPI_OPCODE_REGISTER, D01_TEST_SET_LEDS
                brne PC + 4
                sbis FLAGS, FLAG_TEST_STATE
                sbi FLAGS, FLAG_MODE_CHANGED
                sbi FLAGS, FLAG_TEST_COMMAND

                ldi SPI_STATE_REGISTER, SPI_STATE_END
                out SREG, SPI_SREG_SAVE
                reti

STATE_READ:     cpi SPI_STATE_REGISTER, SPI_STATE_READ
                brne STATE_START

                adiw X, 1

                cp XL, SPI_POINTER_END_L
                cpc XH, SPI_POINTER_END_H
                brsh PC + 3
                out SREG, SPI_SREG_SAVE
                reti

                cpi SPI_OPCODE_REGISTER, D01_CMD_GET_INT
                brne PC + 5
                ldi XL, 0
                sts CMD_GET_INT_DATA, XL
                cbi INT_PORT, INT_PIN

                ldi SPI_STATE_REGISTER, SPI_STATE_END
STATE_END:      out SREG, SPI_SREG_SAVE
                reti

STATE_START:    cpi SPI_STATE_REGISTER, SPI_STATE_START
                brne STATE_END

                mov SPI_OPCODE_REGISTER, SPI_DATA_REGISTER

CMD_SET_FRAME_O:cpi SPI_OPCODE_REGISTER, D01_CMD_SET_FRAME
                brne CMD_GET_INT_OP

                movw SPI_POINTER_END_H:SPI_POINTER_END_L, NEXT_FRAME_H:NEXT_FRAME_L
                ldi XL, low(D01_CMD_SET_FRAME_DATA_SIZE)
                ldi XH, high(D01_CMD_SET_FRAME_DATA_SIZE)
                add SPI_POINTER_END_L, XL
                adc SPI_POINTER_END_H, XH

                movw X, NEXT_FRAME_H:NEXT_FRAME_L
                
                cbi FLAGS, FLAG_FRAME_CHANGED
                ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
                out SREG, SPI_SREG_SAVE
                reti

CMD_GET_INT_OP: cpi SPI_OPCODE_REGISTER, D01_CMD_GET_INT
                brne CMD_SET_BRGHT_O

                ldi XL, low(CMD_GET_INT_DATA + D01_CMD_GET_INT_DATA_SIZE)
                ldi XH, high(CMD_GET_INT_DATA + D01_CMD_GET_INT_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(CMD_GET_INT_DATA)
                ldi XH, high(CMD_GET_INT_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_READ
                out SREG, SPI_SREG_SAVE
                reti

CMD_SET_BRGHT_O:cpi SPI_OPCODE_REGISTER, D01_CMD_SET_BRIGHT
                brne CMD_GET_DEVID_O

                ldi XL, low(CMD_SET_BRIGHT_DATA + D01_CMD_SET_BRIGHT_DATA_SIZE)
                ldi XH, high(CMD_SET_BRIGHT_DATA + D01_CMD_SET_BRIGHT_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(CMD_SET_BRIGHT_DATA)
                ldi XH, high(CMD_SET_BRIGHT_DATA)
                
                cbi FLAGS, FLAG_BRIGHT_CHANGED
                ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
                out SREG, SPI_SREG_SAVE
                reti

CMD_GET_DEVID_O:cpi SPI_OPCODE_REGISTER, D01_CMD_GET_DEVID
                brne TEST_SET_OP

                ldi XL, low(CMD_GET_DEVID_DATA + D01_CMD_GET_DEVID_DATA_SIZE)
                ldi XH, high(CMD_GET_DEVID_DATA + D01_CMD_GET_DEVID_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(CMD_GET_DEVID_DATA)
                ldi XH, high(CMD_GET_DEVID_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_READ
                out SREG, SPI_SREG_SAVE
                reti

TEST_SET_OP:    cpi SPI_OPCODE_REGISTER, D01_TEST_SET
                brne TEST_GET_OP

                movw SPI_POINTER_END_H:SPI_POINTER_END_L, NEXT_FRAME_H:NEXT_FRAME_L
                ldi XL, low(D01_CMD_SET_FRAME_DATA_SIZE)
                ldi XH, high(D01_CMD_SET_FRAME_DATA_SIZE)
                add SPI_POINTER_END_L, XL
                adc SPI_POINTER_END_H, XH

                movw X, NEXT_FRAME_H:NEXT_FRAME_L
                
                ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
                out SREG, SPI_SREG_SAVE
                reti

TEST_GET_OP:    cpi SPI_OPCODE_REGISTER, D01_TEST_GET
                brne TEST_SET_INT_OP

                movw SPI_POINTER_END_H:SPI_POINTER_END_L, NEXT_FRAME_H:NEXT_FRAME_L
                ldi XL, low(D01_CMD_SET_FRAME_DATA_SIZE)
                ldi XH, high(D01_CMD_SET_FRAME_DATA_SIZE)
                add SPI_POINTER_END_L, XL
                adc SPI_POINTER_END_H, XH

                movw X, NEXT_FRAME_H:NEXT_FRAME_L
                
                ldi SPI_STATE_REGISTER, SPI_STATE_READ
                out SREG, SPI_SREG_SAVE
                reti

TEST_SET_INT_OP:cpi SPI_OPCODE_REGISTER, D01_TEST_SET_INT
                brne TEST_SET_SR_OP

                lds XL, CMD_GET_INT_DATA
                ori XL, 1 << D01_CMD_GET_INT_FLAG_TEST_RDY
                sts CMD_GET_INT_DATA, XL
                sbi INT_PORT, INT_PIN
                
                ldi SPI_STATE_REGISTER, SPI_STATE_END
                out SREG, SPI_SREG_SAVE
                reti

TEST_SET_SR_OP: cpi SPI_OPCODE_REGISTER, D01_TEST_SET_SR
                brne TEST_GET_SR_OP

                ldi XL, low(TEST_SET_SR_DATA + D01_TEST_SET_SR_DATA_SIZE)
                ldi XH, high(TEST_SET_SR_DATA + D01_TEST_SET_SR_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(TEST_SET_SR_DATA)
                ldi XH, high(TEST_SET_SR_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
                out SREG, SPI_SREG_SAVE
                reti

TEST_GET_SR_OP: cpi SPI_OPCODE_REGISTER, D01_TEST_GET_SR
                brne TEST_SET_LEDS_O

                ldi XL, low(TEST_GET_SR_DATA + D01_TEST_GET_SR_DATA_SIZE)
                ldi XH, high(TEST_GET_SR_DATA + D01_TEST_GET_SR_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(TEST_GET_SR_DATA)
                ldi XH, high(TEST_GET_SR_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_READ
                out SREG, SPI_SREG_SAVE
                reti

TEST_SET_LEDS_O:cpi SPI_OPCODE_REGISTER, D01_TEST_SET_LEDS
                brne INVALID_OPCODE

                ldi XL, low(TEST_SET_LEDS_DATA + D01_TEST_SET_LEDS_DATA_SIZE)
                ldi XH, high(TEST_SET_LEDS_DATA + D01_TEST_SET_LEDS_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(TEST_SET_LEDS_DATA)
                ldi XH, high(TEST_SET_LEDS_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
                out SREG, SPI_SREG_SAVE
                reti

INVALID_OPCODE: ldi SPI_STATE_REGISTER, SPI_STATE_END
                out SREG, SPI_SREG_SAVE
                reti

//////////////////////////////////////////////////

INT_LATCH:      inc CURRENT_STAGE
                cpi CURRENT_STAGE, STAGE_MAX
                brlo INT_LATCH_CONT
                clr CURRENT_STAGE

                inc CURRENT_LEVEL
                cpi CURRENT_LEVEL, LEVEL_MAX
                brlo INT_LATCH_CONT
                clr CURRENT_LEVEL

                lds r16, CMD_GET_INT_DATA
                ori r16, 1 << D01_CMD_GET_INT_FLAG_NEW_FRAME_RDY
                sts CMD_GET_INT_DATA, r16
                sbi INT_PORT, INT_PIN

                sbis FLAGS, FLAG_FRAME_CHANGED
                rjmp PC + 5
                cbi FLAGS, FLAG_FRAME_CHANGED
                movw r17:r16, CURRENT_FRAME_H:CURRENT_FRAME_L
                movw CURRENT_FRAME_H:CURRENT_FRAME_L, NEXT_FRAME_H:NEXT_FRAME_L
                movw NEXT_FRAME_H:NEXT_FRAME_L, r17:r16
                
                sbis FLAGS, FLAG_BRIGHT_CHANGED
                rjmp PC + 6
                cbi FLAGS, FLAG_BRIGHT_CHANGED
                lds r16, CMD_SET_BRIGHT_DATA
                andi r16, (1 << D01_LED_COLOR_BITS) - 1
                movw CURRENT_BRIGHT, r16
                
INT_LATCH_CONT: sei ; allows INT_SPI

                mov r16, CURRENT_BRIGHT

                mov r17, CURRENT_STAGE
                swap r17

                ldi r18, D01_FRAME_SIZE / D01_CUBE_EDGE_SIZE
                mul r18, CURRENT_LEVEL
                movw Y, CURRENT_FRAME_H:CURRENT_FRAME_L
                add YL, r0
                adc YH, r1

                .macro MAC_PROCESS_NIBBLE
                andi r18, 0x0F
                mul r18, r16
                cp r17, r0
                rol r19
                .endmacro

                .macro MAC_PROCESS_BYTE
                ld r18, Y
                swap r18
                MAC_PROCESS_NIBBLE

                ld r18, Y+
                MAC_PROCESS_NIBBLE
                .endmacro

                .macro MAC_TX_AFTER_4BYTES
                MAC_PROCESS_BYTE
                MAC_PROCESS_BYTE
                MAC_PROCESS_BYTE
                MAC_PROCESS_BYTE

                .if COMMON_K == 1
                com r19
                .else
                nop
                .endif
                nop
                nop
                sts UDR0, r19
                .endmacro

                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES
                MAC_TX_AFTER_4BYTES

                ldi r19, 1 << (D01_CUBE_EDGE_SIZE - 1)
                mov r16, CURRENT_LEVEL

                tst r16
                breq PC + 4

                lsr r19
                dec r16
                brne PC - 2

                .if COMMON_K == 0
                com r19
                .endif

                lds r16, UCSR0A
                sbrs r16, UDRE0
                rjmp PC - 3

                sts UDR0, r19
                reti

//////////////////////////////////////////////////

TEST_SET_SR:    ldi YL, low(TEST_SET_SR_DATA)
                ldi YH, high(TEST_SET_SR_DATA)

                ldd r16, Y + D01_TEST_SET_SR_PRESCALAR_OFFSET + 0
                ldd r17, Y + D01_TEST_SET_SR_PRESCALAR_OFFSET + 1

                sts UBRR0H, r17
                sts UBRR0L, r16

                ldd r7, Y + D01_TEST_SET_SR_COUNT_OFFSET + 0
                ldd r8, Y + D01_TEST_SET_SR_COUNT_OFFSET + 1
                ldd r9, Y + D01_TEST_SET_SR_COUNT_OFFSET + 2
                
                ldd r19, Y + D01_TEST_SET_SR_BYTE_OFFSET

                ldd r16, Y + D01_TEST_SET_SR_MODE_OFFSET
                cpi r16, D01_TEST_SET_SR_MODE_MANUAL
                brne PC + 3
                rcall TEST_SET_SR_MAN
                rjmp PC + 2
                rcall TEST_SET_SR_AUT

                ldi r16, low(UBRR0_INIT)
                ldi r17, high(UBRR0_INIT)

                sts UBRR0H, r17
                sts UBRR0L, r16

                cli
                lds r16, CMD_GET_INT_DATA
                ori r16, 1 << D01_CMD_GET_INT_FLAG_TEST_RDY
                sts CMD_GET_INT_DATA, r16
                sbi INT_PORT, INT_PIN
                sei
                ret

TEST_SET_SR_MAN:ldi r16, 1 << TXC0
                sts UCSR0A, r16

                ldi r16, low(1)
                ldi r17, byte2(1)
                ldi r18, byte3(1)

set_sr_loop0:   lds r15, UCSR0A
                sbrs r15, UDRE0
                rjmp set_sr_loop0

                sts UDR0, r19

                sub r7, r16
                sbc r8, r17
                sbc r9, r18
                brne set_sr_loop0

set_sr_loop0a:  lds r15, UCSR0A
                sbrs r15, TXC0
                rjmp set_sr_loop0a

                sbi LATCH_PORT, LATCH_PIN
                ldi r16, 0
                dec r16
                brne PC - 1
                cbi LATCH_PORT, LATCH_PIN

                cbi ENABLE_PORT, ENABLE_PIN ; must be careful what you load in SR because of this
                ret         

TEST_SET_SR_AUT:sbi ENABLE_PORT, ENABLE_PIN

                clr r10
                clr r11
                clr r12

                ldi r16, 1 << TXC0
                sts UCSR0A, r16

                ldi r16, ((D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE * D01_LED_COLORS) / 8) + (D01_CUBE_EDGE_SIZE / 8)
                
set_sr_loop1:   lds r15, UCSR0A
                sbrs r15, UDRE0
                rjmp set_sr_loop1

                sts UDR0, r19

                dec r16
                brne set_sr_loop1

set_sr_loop2:   lds r15, UCSR0A
                sbrs r15, TXC0
                rjmp set_sr_loop2

set_sr_loop3:   lds r15, UCSR0A
                sbrs r15, RXC0
                rjmp set_sr_cont

                lds r15, UDR0
                rjmp set_sr_loop3

set_sr_cont:    ldi r16, low(1)
                ldi r17, byte2(1)
                ldi r18, byte3(1)

set_sr_loop4:   lds r15, UCSR0A
                sbrc r15, UDRE0
                sts UDR0, r19

                sbrs r15, RXC0
                rjmp set_sr_loop4

                lds r15, UDR0
                cp r15, r19
                breq set_sr_loop4a

                add r10, r16
                adc r11, r17
                adc r12, r18

set_sr_loop4a:  sub r7, r16
                sbc r8, r17
                sbc r9, r18
                brne set_sr_loop4

set_sr_loop5:   lds r15, UCSR0A
                sbrs r15, TXC0
                rjmp set_sr_loop5

                ldi YL, low(TEST_GET_SR_DATA)
                ldi YH, high(TEST_GET_SR_DATA)

                std Y + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 0, r10
                std Y + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 1, r11
                std Y + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 2, r12
                ret

//////////////////////////////////////////////////

TEST_SET_LEDS:  ldi YL, low(TEST_SET_LEDS_DATA)
                ldi YH, high(TEST_SET_LEDS_DATA)
                
                ldd r16, Y + D01_TEST_SET_LEDS_START_LED_OFFSET
                cpi r16, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                brlo PC + 2
                ret

                ldd r17, Y + D01_TEST_SET_LEDS_END_LED_OFFSET
                cpi r17, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                brlo PC + 2
                ret

                cp r17, r16
                brsh PC + 2
                ret

                ldd r18, Y + D01_TEST_SET_LEDS_COLOR_OFFSET
                cpi r18, D01_TEST_SET_LEDS_COLOR_COUNT
                brlo PC + 2
                ret

                ldd r19, Y + D01_TEST_SET_LEDS_LEVEL_OFFSET
                cpi r19, D01_CUBE_EDGE_SIZE + 1
                brlo PC + 2
                ret

                swap r18
                lsl r18

                clr r15

set_leds_loop:  clr r11
                cp r15, r16
                brlo PC + 4
                cp r17, r15
                brlo PC + 2
                mov r11, r18

                .if COMMON_K == 1
                com r11
                .endif

                ldi r20, D01_LED_COLORS

                lsl r11
                rol r12
                rol r13
                rol r14
                dec r20
                brne PC - 5

                inc r15
                ldi r20, D01_CUBE_EDGE_SIZE - 1
                and r20, r15
                brne set_leds_loop

                lds r11, UCSR0A
                sbrs r11, UDRE0
                rjmp PC - 3
                sts UDR0, r14

                lds r11, UCSR0A
                sbrs r11, UDRE0
                rjmp PC - 3
                sts UDR0, r13

                lds r11, UCSR0A
                sbrs r11, UDRE0
                rjmp PC - 3
                sts UDR0, r12

                ldi r20, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                cp r20, r15
                brne set_leds_loop

                ldi r16, 1 << (D01_CUBE_EDGE_SIZE - 1)

                tst r19
                breq PC + 4

                lsr r16
                dec r19
                brne PC - 2

                .if COMMON_K == 0
                com r16
                .endif

                ldi r17, 1 << TXC0
                sts UCSR0A, r17

                lds r11, UCSR0A
                sbrs r11, UDRE0
                rjmp PC - 3
                sts UDR0, r16

                lds r11, UCSR0A
                sbrs r11, TXC0
                rjmp PC - 3

                sbi LATCH_PORT, LATCH_PIN
                ldi r16, 0
                dec r16
                brne PC - 1
                cbi LATCH_PORT, LATCH_PIN

                cbi ENABLE_PORT, ENABLE_PIN
                ret
