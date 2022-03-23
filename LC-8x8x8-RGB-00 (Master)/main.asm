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

loop:           rjmp loop

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