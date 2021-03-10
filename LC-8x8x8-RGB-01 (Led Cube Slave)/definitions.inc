.nolist
.include "../Shared/m328Pdef.inc"
.include "../Shared/definitions.inc"

.equ F_CPU = 16000000

.equ INT_PIN        = PB0
.equ INT_PORT       = PORTB
.equ LED_PIN        = PB1
.equ MISO_PIN       = PB4
.equ LATCH_PIN      = PD3
.equ LATCH_PORT     = PORTD
.equ SHIFT_PIN      = PD4
.equ ENABLE_PIN     = PD5
.equ ENABLE_PORT    = PORTD

; SPI used to communicate with master
.equ SPCR_INIT = (1 << SPIE) | (1 << SPE) | (1 << CPHA)

; INT0 used for interrupt when SPI Slave is selected
.equ EICRA_INIT = (1 << ISC01)
.equ EIMSK_INIT = (1 << INT0)

; USART used in SPI master mode to load shift registers
.equ UCSR0B_INIT = (1 << RXEN0) | (1 << TXEN0)
.equ UCSR0C_INIT = (1 << UMSEL00) | (1 << UMSEL01)

; TIMER1 used to blink LED
.equ TCCR1A_INIT = (1 << COM1A0)
.equ TCCR1B_INIT = (1 << WGM12) | (1 << CS12)
.equ OCR1A_INIT  = (F_CPU / 256) - 1

; PORTS
.equ PORTB_INIT = (1 << INT_PIN) | (1 << LED_PIN)
.equ DDRB_INIT  = (1 << INT_PIN) | (1 << LED_PIN) | (1 << MISO_PIN)
.equ PORTC_INIT = 0b00111111
.equ DDRC_INIT  = 0b00000000
.equ PORTD_INIT = (1 << ENABLE_PIN)
.equ DDRD_INIT  = (1 << LATCH_PIN) | (1 << SHIFT_PIN) | (1 << ENABLE_PIN)

; Registers / RAM Addresses
.def SPI_DATA_OUT_REGISTER  = r2
.def SPI_DATA_IN_REGISTER   = r22
.def SPI_STATE_REGISTER     = r23
.def SPI_DATA_COUNT_L       = r24
.def SPI_DATA_COUNT_H       = r25

.equ SPI_STATE_START    = 0
.equ SPI_STATE_WRITE    = 1
.equ SPI_STATE_READ     = 2
.equ SPI_STATE_END      = 3

.dseg
.equ TEST_DATA_SIZE = D01_FRAME_SIZE
TEST_DATA: .byte TEST_DATA_SIZE

.cseg
.list
