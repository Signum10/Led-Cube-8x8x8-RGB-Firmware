.include "definitions.inc"

.org 0x0000		rjmp start
.org INT0addr	ldi SPI_STATE_REGISTER, SPI_STATE_START
				reti
.org INT1addr	reti
.org PCI0addr	reti
.org PCI1addr	reti
.org PCI2addr	reti
.org WDTaddr	reti
.org OC2Aaddr	reti
.org OC2Baddr	reti
.org OVF2addr	reti
.org ICP1addr	reti
.org OC1Aaddr	reti
.org OC1Baddr	reti
.org OVF1addr	reti
.org OC0Aaddr	reti
.org OC0Baddr	reti
.org OVF0addr	reti
.org SPIaddr	out SPDR, SPI_DATA_OUT_REGISTER
				rjmp INT_SPI
.org URXCaddr	reti
.org UDREaddr	reti
.org UTXCaddr	reti
.org ADCCaddr	reti
.org ERDYaddr	reti
.org ACIaddr	reti
.org TWIaddr	reti
.org SPMRaddr	reti
.org INT_VECTORS_SIZE

start:			ldi r16, SPCR_INIT
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

loop:			brtc loop
				clt
				icall
				rjmp loop

//////////////////////////////////////////////////

INT_SPI:		in SPI_DATA_IN_REGISTER, SPDR

STATE_READ:		cpi SPI_STATE_REGISTER, SPI_STATE_READ
				brne STATE_WRITE

				ld SPI_DATA_OUT_REGISTER, X+
				sbiw SPI_DATA_COUNT_H:SPI_DATA_COUNT_L, 1
				breq PC + 2
				reti

				ldi SPI_STATE_REGISTER, SPI_STATE_END
				reti
		
STATE_WRITE:	cpi SPI_STATE_REGISTER, SPI_STATE_WRITE
				brne STATE_START

				st X+, SPI_DATA_IN_REGISTER
				sbiw SPI_DATA_COUNT_H:SPI_DATA_COUNT_L, 1
				breq PC + 2
				reti

				ldi SPI_STATE_REGISTER, SPI_STATE_END
				reti

STATE_START:	cpi SPI_STATE_REGISTER, SPI_STATE_START
				brne STATE_END

SET_TEST_DATA:	cpi SPI_DATA_IN_REGISTER, SET_TEST_DATA_OPCODE
				brne GET_TEST_DATA

				ldi XL, low(TEST_DATA)
				ldi XH, high(TEST_DATA)
				ldi SPI_DATA_COUNT_L, low(TEST_DATA_SIZE)
				ldi SPI_DATA_COUNT_H, high(TEST_DATA_SIZE)
				ldi SPI_STATE_REGISTER, SPI_STATE_WRITE
				reti

GET_TEST_DATA:	cpi SPI_DATA_IN_REGISTER, GET_TEST_DATA_OPCODE
				brne SET_INT_HIGH

				ldi XL, low(TEST_DATA)
				ldi XH, high(TEST_DATA)
				ldi SPI_DATA_COUNT_L, low(TEST_DATA_SIZE)
				ldi SPI_DATA_COUNT_H, high(TEST_DATA_SIZE)
				ldi SPI_STATE_REGISTER, SPI_STATE_READ
				reti

SET_INT_HIGH:	cpi SPI_DATA_IN_REGISTER, SET_INT_HIGH_OPCODE
				brne SET_INT_LOW

				sbi INT_PORT, INT_PIN
				ldi SPI_STATE_REGISTER, SPI_STATE_END
				reti

SET_INT_LOW:	cpi SPI_DATA_IN_REGISTER, SET_INT_LOW_OPCODE
				brne START_SR_TEST

				cbi INT_PORT, INT_PIN
				ldi SPI_STATE_REGISTER, SPI_STATE_END
				reti

START_SR_TEST:	cpi SPI_DATA_IN_REGISTER, START_SR_TEST_OPCODE
				brne START_SR_LOAD

				set
				ldi ZL, low(SR_TEST >> 1)
				ldi ZH, high(SR_TEST >> 1)
				ldi SPI_STATE_REGISTER, SPI_STATE_END
				reti

START_SR_LOAD:	cpi SPI_DATA_IN_REGISTER, START_SR_LOAD_OPCODE
				brne INVALID_OPCODE

				set
				ldi ZL, low(SR_LOAD >> 1)
				ldi ZH, high(SR_LOAD >> 1)
				ldi SPI_STATE_REGISTER, SPI_STATE_END
				reti

INVALID_OPCODE:	ldi SPI_STATE_REGISTER, SPI_STATE_END
STATE_END:		reti

//////////////////////////////////////////////////

SR_TEST:		sbi INT_PORT, INT_PIN
				sbi ENABLE_PORT, ENABLE_PIN

				ldi YL, low(TEST_DATA)
				ldi YH, high(TEST_DATA)

				ldd r16, Y + SR_TEST_PRESCALAR_OFFSET + 0
				ldd r17, Y + SR_TEST_PRESCALAR_OFFSET + 1

				sts UBRR0H, r17
				sts UBRR0L, r16

				ldd r7, Y + SR_TEST_COUNT_OFFSET + 0
				ldd r8, Y + SR_TEST_COUNT_OFFSET + 1
				ldd r9, Y + SR_TEST_COUNT_OFFSET + 2
				clr r10
				clr r11
				clr r12

				ldi r16, SR_COUNT
				ldi r19, SR_TEST_BYTE

sr_test_loop1:	lds r15, UCSR0A
				sbrs r15, UDRE0
				rjmp sr_test_loop1

				sts UDR0, r17

				dec r16
				brne sr_test_loop1

sr_test_loop2:	lds r17, UCSR0A
				sbrs r17, TXC0
				rjmp sr_test_loop2

sr_test_loop3:	lds r17, UCSR0A
				sbrs r17, RXC0
				rjmp sr_test_cont

				lds r17, UDR0
				rjmp sr_test_loop3

sr_test_cont:	ldi r16, low(1)
				ldi r17, byte2(1)
				ldi r18, byte3(1)

sr_test_loop4:	lds r15, UCSR0A
				sbrc r15, UDRE0
				sts UDR0, r19

				sbrs r15, RXC0
				rjmp sr_test_loop4

				lds r15, UDR0
				cp r15, r19
				breq sr_test_loop4a

				add r10, r16
				adc r11, r17
				adc r12, r18

sr_test_loop4a:	sub r7, r16
				sbc r8, r17
				sbc r9, r18
				brne sr_test_loop4

				clr r16
				sts UBRR0H, r16
				sts UBRR0L, r16

				std Y + SR_TEST_ERROR_COUNT_OFFSET + 0, r10
				std Y + SR_TEST_ERROR_COUNT_OFFSET + 1, r11
				std Y + SR_TEST_ERROR_COUNT_OFFSET + 2, r12

				cbi INT_PORT, INT_PIN
				ret

//////////////////////////////////////////////////

SR_LOAD:		ldi YL, low(TEST_DATA)
				ldi YH, high(TEST_DATA)
				ldi r16, SR_COUNT

sr_load_loop:	lds r15, UCSR0A
				sbrs r15, UDRE0
				rjmp sr_load_loop

				ld r15, Y+
				sts UDR0, r15

				dec r16
				brne sr_load_loop
		
				sbi LATCH_PORT, LATCH_PIN
				cbi ENABLE_PORT, ENABLE_PIN
				cbi LATCH_PORT, LATCH_PIN
				ret
