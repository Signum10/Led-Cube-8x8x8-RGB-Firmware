.nolist
.include "../Shared/m328Pdef.inc"
.include "../Shared/definitions.inc"

.equ F_CPU    = D01_F_CPU
.equ COMMON_K = 1 ; 1 if LEDs have common cathode, 0 for common anode

.equ INT_PIN        = PB0
.equ INT_PORT       = PORTB
.equ LED_PIN        = PB1
.equ MISO_PIN       = PB4
.equ MISO_DDR       = DDRB
.equ LATCH_PIN      = PD3
.equ LATCH_PORT     = PORTD
.equ SHIFT_PIN      = PD4
.equ ENABLE_PIN     = PD5
.equ ENABLE_PORT    = PORTD

; GPIOR used for flags
.equ FLAGS                = GPIOR0
.equ FLAG_TEST_STATE      = 0
.equ FLAG_TEST_STATE_REQ  = 1
.equ FLAG_MODE_CHECK      = 2
.equ FLAG_FRAME_CHANGED   = 3
.equ FLAG_BRIGHT_CHANGED  = 4

; PORTS
.equ PORTB_INIT = (1 << INT_PIN)
.equ DDRB_INIT  = (1 << INT_PIN) | (1 << LED_PIN)
.equ PORTC_INIT = 0b00111111
.equ DDRC_INIT  = 0b00000000
.equ PORTD_INIT = (1 << ENABLE_PIN)
.equ DDRD_INIT  = (1 << LATCH_PIN) | (1 << SHIFT_PIN) | (1 << ENABLE_PIN)

; SPI used to communicate with master
.equ SPCR_INIT = (1 << SPIE) | (1 << SPE) | (1 << CPHA)

; INT0 used for interrupt when SPI Slave is selected
.equ EICRA_INIT = (1 << ISC01)
.equ EIMSK_INIT = (1 << INT0)

; USART used in SPI master mode to load shift registers
.equ UCSR0B_INIT = (1 << RXEN0) | (1 << TXEN0)
.equ UCSR0C_INIT = (1 << UMSEL00) | (1 << UMSEL01)
.equ UBRR0_INIT  = (F_CPU / (2 * 2000000)) - 1

; TIMER1 used to blink LED
.equ TCCR1A_INIT = (1 << COM1A1) | (1 << WGM11)
.equ TCCR1B_INIT = (1 << WGM13) | (1 << WGM12) | (1 << CS12)
.equ ICR1_INIT   = (F_CPU / 256) - 1
.equ OCR1A_INIT  = (F_CPU / 256) / 8 - 1

; TIMER2 used to control shift register latch and to basically control the cube refresh rate
; Cube Refresh Rate = F_CPU / ((1 << TIMER_BITS) * TIMER_PRESCALAR * CUBE_LEVELS * ((1 << COLOR_BITS) - 1)) = 16000000 / (256 * 8 * 8 * 15) = 65.1 Hz
.equ TCCR2A_INIT = (1 << COM2B1) | (1 << COM2B0) | (1 << WGM21) | (1 << WGM20)
.equ TCCR2B_INIT = (1 << CS21)
.equ OCR2B_INIT  = (256 / 2) - 1
.equ TIMSK2_INIT = (1 << OCIE2B)
.equ TIFR2_CLR   = (1 << OCF2B)

; Registers / RAM Addresses
.def SPI_POINTER_END_L   = r2
.def SPI_POINTER_END_H   = r3
.def SPI_DATA_REGISTER   = r4
.def SPI_SREG_SAVE       = r5
.def CURRENT_FRAME_L     = r6
.def CURRENT_FRAME_H     = r7
.def NEXT_FRAME_L        = r8
.def NEXT_FRAME_H        = r9
.def CURRENT_BRIGHT      = r10
.def CURRENT_STAGE       = r20
.def CURRENT_LEVEL       = r21
.def SPI_OPCODE_REGISTER = r22
.def SPI_STATE_REGISTER  = r23

.equ SPI_STATE_START    = 0
.equ SPI_STATE_WRITE    = 1
.equ SPI_STATE_READ     = 2
.equ SPI_STATE_END      = 3

.dseg
CMD_GET_DEVID_DATA:  .byte D01_CMD_GET_DEVID_DATA_SIZE
CMD_GET_INT_DATA:    .byte D01_CMD_GET_INT_DATA_SIZE
CMD_SET_FRAME_DATA:  .byte D01_FRAME_SIZE * 2
CMD_SET_BRIGHT_DATA: .byte D01_CMD_SET_BRIGHT_DATA_SIZE
TEST_SET_SR_DATA:    .byte D01_TEST_SET_SR_DATA_SIZE
TEST_GET_SR_DATA:    .byte D01_TEST_GET_SR_DATA_SIZE
TEST_SET_LEDS_DATA:  .byte D01_TEST_SET_LEDS_DATA_SIZE

.cseg
.list
