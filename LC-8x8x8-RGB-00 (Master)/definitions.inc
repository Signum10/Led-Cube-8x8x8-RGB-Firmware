.nolist
.include "../Shared/m328Pdef.inc"
.include "../Shared/definitions.inc"

.equ F_CPU          = 16000000
.equ SLAVE_COUNT    = 6

.equ LED_PIN        = PB1
.equ SS_PIN         = PB2
.equ MOSI_PIN       = PB3
.equ MISO_PIN       = PB4
.equ SCK_PIN        = PB5
.equ INT_PIN_SLAVE0 = PC0
.equ INT_PIN_SLAVE1 = PC1
.equ INT_PIN_SLAVE2 = PC2
.equ INT_PIN_SLAVE3 = PC3
.equ INT_PIN_SLAVE4 = PC4
.equ INT_PIN_SLAVE5 = PC5
.equ INT_PINREG     = PINC
.equ SS_PIN_SLAVE0  = PD0
.equ SS_PIN_SLAVE1  = PD1
.equ SS_PIN_SLAVE2  = PD2
.equ SS_PIN_SLAVE3  = PD3
.equ SS_PIN_SLAVE4  = PD4
.equ SS_PIN_SLAVE5  = PD5
.equ SS_PORT        = PORTD

; PORTS
.equ PORTB_INIT   = 0b00000001 | (1 << SS_PIN)
.equ DDRB_INIT    = 0b00000000 | (1 << LED_PIN) | (1 << SS_PIN) | (1 << MOSI_PIN) | (1 << SCK_PIN)
.equ PORTC_INIT   = 0b00000000
.equ DDRC_INIT    = 0b00000000
.equ PORTD_INIT   = 0b11000000 | (1 << SS_PIN_SLAVE0) | (1 << SS_PIN_SLAVE1) | (1 << SS_PIN_SLAVE2) | (1 << SS_PIN_SLAVE3) | (1 << SS_PIN_SLAVE4) | (1 << SS_PIN_SLAVE5)
.equ DDRD_INIT    = 0b00000000 | (1 << SS_PIN_SLAVE0) | (1 << SS_PIN_SLAVE1) | (1 << SS_PIN_SLAVE2) | (1 << SS_PIN_SLAVE3) | (1 << SS_PIN_SLAVE4) | (1 << SS_PIN_SLAVE5)
.equ SS_PORT_INIT = PORTD_INIT

; SPI used to communicate with slaves
.equ SPCR_INIT = (1 << SPE) | (1 << MSTR) | (1 << CPHA) | (1 << SPR0) ; needs to be 1 MHz

; TIMER1 used to blink LED
.equ TCCR1A_INIT = (1 << COM1A1) | (1 << WGM11)
.equ TCCR1B_INIT = (1 << WGM13) | (1 << WGM12) | (1 << CS12)
.equ ICR1_INIT   = (F_CPU / 256) - 1
.equ OCR1A_INIT  = (F_CPU / 256) / 8 - 1

; Registers / RAM Addresses
.def CURRENT_SLAVE = r2
.def CURRENT_INT   = r3

.equ SLAVE_PROC_ELEMENT_SIZE = 2
.equ SLAVE_PROC_DATA_SIZE    = SLAVE_PROC_ELEMENT_SIZE * SLAVE_COUNT

.dseg
SLAVE_PROC:     .byte SLAVE_PROC_DATA_SIZE 
PACKET_BUFFER:  .byte D01_FRAME_SIZE * 2

.cseg
.list
