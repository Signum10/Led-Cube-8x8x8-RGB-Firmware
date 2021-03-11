.nolist
.include "../Shared/m16def.inc"
.include "../Shared/definitions.inc"

.equ F_CPU     = 8000000
.equ BAUD      = 38400

.equ INT_PIN  = PB3
.equ SS_PIN   = PB4
.equ MOSI_PIN = PB5
.equ MISO_PIN = PB6
.equ SCK_PIN  = PB7
.equ DDR      = DDRB
.equ PORT     = PORTB
.equ PINREG   = PINB

.equ UCSRB_INIT = (1 << RXEN) | (1 << TXEN)
.equ UBRR_INIT  = (F_CPU / (16 * BAUD)) - 1

.equ MASTER_SPCR_INIT = (1 << SPE) | (1 << MSTR) | (1 << CPHA)
.equ MASTER_DDR_INIT  = (1 << MOSI_PIN) | (1 << SCK_PIN) | (1 << SS_PIN)
.equ MASTER_PORT_INIT = (1 << SS_PIN)

.equ SLAVE_SPCR_INIT  = (1 << SPE) | (1 << CPHA)
.equ SLAVE_DDR_INIT   = (1 << MISO_PIN) | (1 << INT_PIN)
.equ SLAVE_PORT_INIT  = (1 << INT_PIN)

.equ CLOSE_SPCR_INIT  = 0
.equ CLOSE_DDR_INIT   = 0
.equ CLOSE_PORT_INIT  = 0

.dseg
.equ PACKET_BUFFER_SIZE = D01_FRAME_SIZE
PACKET_BUFFER:  .byte PACKET_BUFFER_SIZE

.cseg
.list
