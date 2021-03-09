.nolist
.include "../Shared/m328Pdef.inc"

.equ F_CPU = 16000000
.equ SR_COUNT = 25 ; Number of shift registers

.equ INT_PIN = PB0
.equ INT_PORT = PORTB
.equ LED_PIN = PB1
.equ MISO_PIN = PB4
.equ LATCH_PIN = PD3
.equ LATCH_PORT = PORTD
.equ SHIFT_PIN = PD4
.equ ENABLE_PIN = PD5
.equ ENABLE_PORT = PORTD

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
.equ OCR1A_INIT = (F_CPU / 256) - 1

; PORTS
.equ PORTB_INIT = (1 << INT_PIN) | (1 << LED_PIN)
.equ DDRB_INIT = (1 << INT_PIN) | (1 << LED_PIN) | (1 << MISO_PIN)
.equ PORTC_INIT = 0b00111111
.equ DDRC_INIT = 0b00000000
.equ PORTD_INIT = (1 << ENABLE_PIN)
.equ DDRD_INIT = (1 << LATCH_PIN) | (1 << SHIFT_PIN) | (1 << ENABLE_PIN)

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

; These are used to test SPI transfer reliability
.equ SET_TEST_DATA_OPCODE = 1
.equ GET_TEST_DATA_OPCODE = 2
.equ TEST_DATA_SIZE = 1024

; These are used to test that INT pin works
.equ SET_INT_HIGH_OPCODE = 3
.equ SET_INT_LOW_OPCODE = 4

; These are used to test that loading shift register works
.equ START_SR_TEST_OPCODE = 5
.equ SR_TEST_PRESCALAR_SIZE = 2
.equ SR_TEST_COUNT_SIZE = 3
.equ SR_TEST_ERROR_COUNT_SIZE = SR_TEST_COUNT_SIZE
.equ SR_TEST_PRESCALAR_OFFSET = 0
.equ SR_TEST_COUNT_OFFSET = SR_TEST_PRESCALAR_OFFSET + SR_TEST_PRESCALAR_SIZE
.equ SR_TEST_ERROR_COUNT_OFFSET = SR_TEST_COUNT_OFFSET + SR_TEST_COUNT_SIZE
.equ SR_TEST_BYTE = 0xAA

; This is used to customly load shift registers
.equ START_SR_LOAD_OPCODE = 6

.dseg
TEST_DATA: .byte TEST_DATA_SIZE

.cseg
.list
