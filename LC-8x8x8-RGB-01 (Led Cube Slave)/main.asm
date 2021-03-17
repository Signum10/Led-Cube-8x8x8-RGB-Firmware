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
.org OC2Baddr   reti
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

start:          ldi r16, SPCR_INIT
                out SPCR, r16

                ldi r16, EICRA_INIT
                sts EICRA, r16
                ldi r16, EIMSK_INIT
                out EIMSK, r16

                ldi r16, UCSR0C_INIT
                sts UCSR0C, r16
                ldi r16, UCSR0B_INIT
                sts UCSR0B, r16

                ldi r16, PORTB_INIT
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

                ldi SPI_STATE_REGISTER, SPI_STATE_END
                clt
                sei

loop:           brtc loop
                clt

                cpi SPI_OPCODE_REGISTER, D01_TEST_SET_INT
                brne PC + 2
                rjmp TEST_SET_INT


                cpi SPI_OPCODE_REGISTER, D01_TEST_SET_SR
                brne PC + 2
                rjmp TEST_SET_SR

                cpi SPI_OPCODE_REGISTER, D01_TEST_SET_LEDS
                brne PC + 2
                rjmp TEST_SET_LEDS

                rjmp loop

//////////////////////////////////////////////////

INT_SPI:        ld SPI_DATA_REGISTER, X
                out SPDR, SPI_DATA_REGISTER
                in SPI_DATA_REGISTER, SPDR

STATE_READ:     cpi SPI_STATE_REGISTER, SPI_STATE_READ
                brne STATE_WRITE

                adiw X, 1

                cp XL, SPI_POINTER_END_L
                cpc XH, SPI_POINTER_END_H
                brsh PC + 2
                reti

                ldi SPI_STATE_REGISTER, SPI_STATE_END
                reti
        
STATE_WRITE:    cpi SPI_STATE_REGISTER, SPI_STATE_WRITE
                brne STATE_START

                st X+, SPI_DATA_REGISTER
                
                cp XL, SPI_POINTER_END_L
                cpc XH, SPI_POINTER_END_H
                brsh PC + 2
                reti

                set
                ldi SPI_STATE_REGISTER, SPI_STATE_END
                reti

STATE_START:    cpi SPI_STATE_REGISTER, SPI_STATE_START
                brne STATE_END

                mov SPI_OPCODE_REGISTER, SPI_DATA_REGISTER

TEST_SET_OP:    cpi SPI_OPCODE_REGISTER, D01_TEST_SET
                brne TEST_GET_OP

                ldi XL, low(TEST_DATA + D01_TEST_SET_DATA_SIZE)
                ldi XH, high(TEST_DATA + D01_TEST_SET_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(TEST_DATA)
                ldi XH, high(TEST_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
                reti

TEST_GET_OP:    cpi SPI_OPCODE_REGISTER, D01_TEST_GET
                brne TEST_SET_INT_OP

                ldi XL, low(TEST_DATA + D01_TEST_GET_DATA_SIZE)
                ldi XH, high(TEST_DATA + D01_TEST_GET_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(TEST_DATA)
                ldi XH, high(TEST_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_READ
                reti

TEST_SET_INT_OP:cpi SPI_OPCODE_REGISTER, D01_TEST_SET_INT
                brne TEST_SET_SR_OP

                ldi XL, low(TEST_DATA + D01_TEST_SET_INT_DATA_SIZE)
                ldi XH, high(TEST_DATA + D01_TEST_SET_INT_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(TEST_DATA)
                ldi XH, high(TEST_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
                reti

TEST_SET_SR_OP: cpi SPI_OPCODE_REGISTER, D01_TEST_SET_SR
                brne TEST_GET_SR_OP

                ldi XL, low(TEST_DATA + D01_TEST_SET_SR_DATA_SIZE)
                ldi XH, high(TEST_DATA + D01_TEST_SET_SR_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(TEST_DATA)
                ldi XH, high(TEST_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
                reti

TEST_GET_SR_OP: cpi SPI_OPCODE_REGISTER, D01_TEST_GET_SR
                brne TEST_SET_LEDS_O

                ldi XL, low(TEST_DATA + D01_TEST_GET_SR_DATA_SIZE)
                ldi XH, high(TEST_DATA + D01_TEST_GET_SR_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(TEST_DATA)
                ldi XH, high(TEST_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_READ
                reti

TEST_SET_LEDS_O:cpi SPI_OPCODE_REGISTER, D01_TEST_SET_LEDS
                brne INVALID_OPCODE

                ldi XL, low(TEST_DATA + D01_TEST_SET_LEDS_DATA_SIZE)
                ldi XH, high(TEST_DATA + D01_TEST_SET_LEDS_DATA_SIZE)
                movw SPI_POINTER_END_H:SPI_POINTER_END_L, X

                ldi XL, low(TEST_DATA)
                ldi XH, high(TEST_DATA)
                
                ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
                reti

INVALID_OPCODE: ldi SPI_STATE_REGISTER, SPI_STATE_END
STATE_END:      reti

//////////////////////////////////////////////////

TEST_SET_INT:   lds r16, TEST_DATA + D01_TEST_SET_INT_STATE_OFFSET
                
                tst r16
                brne PC + 3
                cbi INT_PORT, INT_PIN
                rjmp loop

                sbi INT_PORT, INT_PIN
                rjmp loop

//////////////////////////////////////////////////

TEST_SET_SR:    sbi INT_PORT, INT_PIN
                sbi ENABLE_PORT, ENABLE_PIN

                ldi YL, low(TEST_DATA)
                ldi YH, high(TEST_DATA)

                ldd r16, Y + D01_TEST_SET_SR_PRESCALAR_OFFSET + 0
                ldd r17, Y + D01_TEST_SET_SR_PRESCALAR_OFFSET + 1

                sts UBRR0H, r17
                sts UBRR0L, r16

                ldd r7, Y + D01_TEST_SET_SR_COUNT_OFFSET + 0
                ldd r8, Y + D01_TEST_SET_SR_COUNT_OFFSET + 1
                ldd r9, Y + D01_TEST_SET_SR_COUNT_OFFSET + 2
                clr r10
                clr r11
                clr r12

                ldi r16, ((D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE * D01_LED_COLORS) / 8) + (D01_CUBE_EDGE_SIZE / 8)
                ldi r19, D01_TEST_SET_SR_TX_BYTE

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

                clr r16
                sts UBRR0H, r16
                sts UBRR0L, r16

                std Y + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 0, r10
                std Y + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 1, r11
                std Y + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 2, r12

                cbi INT_PORT, INT_PIN
                rjmp loop

//////////////////////////////////////////////////

TEST_SET_LEDS:  ldi YL, low(TEST_DATA)
                ldi YH, high(TEST_DATA)
                
                ldd r16, Y + D01_TEST_SET_LEDS_START_LED_OFFSET
                cpi r16, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                brlo PC + 2
                rjmp loop

                ldd r17, Y + D01_TEST_SET_LEDS_END_LED_OFFSET
                cpi r17, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                brlo PC + 2
                rjmp loop

                cp r17, r16
                brsh PC + 2
                rjmp loop

                ldd r18, Y + D01_TEST_SET_LEDS_COLOR_OFFSET
                cpi r18, D01_TEST_SET_LEDS_COLOR_COUNT
                brlo PC + 2
                rjmp loop

                ldd r19, Y + D01_TEST_SET_LEDS_LEVEL_OFFSET
                cpi r19, D01_CUBE_EDGE_SIZE + 1
                brlo PC + 2
                rjmp loop

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

                ldi r20, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                cp r20, r15
                breq set_leds_end

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

                rjmp set_leds_loop

set_leds_end:   ldi r16, 1 << (D01_CUBE_EDGE_SIZE - 1)

                tst r19
                breq PC + 4

                lsr r16
                dec r19
                brne PC - 2

                .if COMMON_K == 0
                com r16
                .endif

                lds r11, UCSR0A
                sbrs r11, UDRE0
                rjmp PC - 3
                sts UDR0, r16

                sbi LATCH_PORT, LATCH_PIN
                cbi ENABLE_PORT, ENABLE_PIN
                cbi LATCH_PORT, LATCH_PIN
                rjmp loop
