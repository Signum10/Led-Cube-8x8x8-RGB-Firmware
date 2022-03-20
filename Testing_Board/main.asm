.include "definitions.inc"

start:          ldi r16, low(RAMEND)
                out SPL, r16
                ldi r16, high(RAMEND)
                out SPH, r16

                ldi r16, high(UBRR_INIT)
                out UBRRH, r16
                ldi r16, low(UBRR_INIT)
                out UBRRL, r16
                ldi r16, UCSRB_INIT
                out UCSRB, r16

                rcall tx_crlf
                ldi r16, '*'
                ldi r17, 32
                rcall tx_byte_repeat

                ldi r16, low(MENU_ROOT << 1)
                ldi r17, high(MENU_ROOT << 1)
                rcall menu_nav
                
                rjmp PC

MENU_ROOT:
.db "Root", 0
.db '0', "LC-8x8x8-RGB-00 (Master)",         0 \ .dw menu_nav, MENU_00 << 1
.db '1', "LC-8x8x8-RGB-01 (Led Cube Slave)", 0 \ .dw menu_nav, MENU_01 << 1
.dw 0
.dw 0, 0

MENU_00:
.db "Root/LC-8x8x8-RGB-00 (Master)", 0
.db 'i', "Interface", 0 \ .dw menu_nav, MENU_00I << 1
.db 'b', "Back",      0 \ .dw menu_back, 0
.dw 0
.dw 0, 0

MENU_00I:
.db "Root/LC-8x8x8-RGB-00 (Master)/Interface", 0
.db '0', "Slave0", 0 \ .dw prog_00i, 0
.db '1', "Slave1", 0 \ .dw prog_00i, 1
.db '2', "Slave2", 0 \ .dw prog_00i, 2
.db '3', "Slave3", 0 \ .dw prog_00i, 3
.db '4', "Slave4", 0 \ .dw prog_00i, 4
.db '5', "Slave5", 0 \ .dw prog_00i, 5
.db 'b', "Back",   0 \ .dw menu_back, 0
.dw 0
.dw prog_00i_init, 0

MENU_01:
.db "Root/LC-8x8x8-RGB-01 (Led Cube Slave)", 0
.db 'i', "Interface",                    0 \ .dw menu_nav, MENU_01I << 1
.db 'm', "Shift Registers, manual load", 0 \ .dw menu_nav, MENU_01SM << 1
.db 'a', "Shift Registers, auto load",   0 \ .dw menu_nav, MENU_01SA << 1
.db 'l', "LEDs",                         0 \ .dw menu_nav, MENU_01L << 1
.db 'c', "Cube, basic checks",           0 \ .dw menu_nav, MENU_01C << 1
.db 'f', "Cube, one color frame",        0 \ .dw menu_nav, MENU_01F << 1
.db 'b', "Back",                         0 \ .dw menu_back, 0
.dw 0
.dw 0, 0

MENU_01I:
.db "Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Interface", 0
.dw 0
.dw prog_01i_init, 0

MENU_01SM:
.db "Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Shift Registers, manual load", 0
.db 'a', "Previous frequency", 0 \ .dw prog_01sm_fq, -1
.db 'q', "Next frequency",     0 \ .dw prog_01sm_fq, 1
.db 's', "Byte -= 1",          0 \ .dw prog_01sm_by, -1
.db 'S', "Byte -= 16",         0 \ .dw prog_01sm_by, -16
.db 'w', "Byte += 1",          0 \ .dw prog_01sm_by, 1
.db 'W', "Byte += 16",         0 \ .dw prog_01sm_by, 16
.db 'd', "Count -= 1",         0 \ .dw prog_01sm_cn, -1
.db 'D', "Count -= 8",         0 \ .dw prog_01sm_cn, -8
.db 'e', "Count += 1",         0 \ .dw prog_01sm_cn, 1
.db 'E', "Count += 8",         0 \ .dw prog_01sm_cn, 8
.db 't', "Send",               0 \ .dw prog_01sm_tx, 0
.db 'b', "Back",               0 \ .dw menu_back, 0
.dw 0
.dw prog_01sm_init, 0

MENU_01SA:
.db "Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Shift Registers, auto load", 0
.dw 0
.dw prog_01sa_init, 0

MENU_01L:
.db "Root/LC-8x8x8-RGB-01 (Led Cube Slave)/LEDs", 0
.db '0', "None installed",               0 \ .dw prog_01l_mode, 0
.db '1', "Installed slice 1 (back)",     0 \ .dw prog_01l_mode, 1
.db '2', "Installed slice 2",            0 \ .dw prog_01l_mode, 2
.db '3', "Installed slice 3",            0 \ .dw prog_01l_mode, 3
.db '4', "Installed slice 4",            0 \ .dw prog_01l_mode, 4
.db '5', "Installed slice 5",            0 \ .dw prog_01l_mode, 5
.db '6', "Installed slice 6",            0 \ .dw prog_01l_mode, 6
.db '7', "Installed slice 7",            0 \ .dw prog_01l_mode, 7
.db '8', "Installed slice 8 (front)",    0 \ .dw prog_01l_mode, 8
.db '9', "All installed",                0 \ .dw prog_01l_mode, 9
.db 'p', "Previous step",                0 \ .dw prog_01l_step, -1
.db 'P', "Previous 100 steps",           0 \ .dw prog_01l_step, -100
.db 'n', "Next step",                    0 \ .dw prog_01l_step, 1
.db 'N', "Next 100 steps",               0 \ .dw prog_01l_step, 100
.db 'b', "Back",                         0 \ .dw menu_back, 0
.dw 0
.dw prog_01l_init, 0

MENU_01C:
.db "Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Cube, basic checks", 0
.dw 0
.dw prog_01c_init, 0

MENU_01F:
.db "Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Cube, one color frame", 0
.db 'a', "Red -= 1",        0 \ .dw prog_01f_r, -1
.db 'q', "Red += 1",        0 \ .dw prog_01f_r, 1
.db 's', "Green -= 1",      0 \ .dw prog_01f_g, -1
.db 'w', "Green += 1",      0 \ .dw prog_01f_g, 1
.db 'd', "Blue -= 1",       0 \ .dw prog_01f_b, -1
.db 'e', "Blue += 1",       0 \ .dw prog_01f_b, 1
.db 'f', "Brightness -= 1", 0 \ .dw prog_01f_br, -1
.db 'r', "Brightness += 1", 0 \ .dw prog_01f_br, 1
.db 'b', "Back",            0 \ .dw menu_back, 0
.dw 0
.dw prog_01f_init, 0

////////////////////////////////////////////////// Shared

menu_nav:       movw r3:r2, r17:r16

menu_nav_ref:   movw Z, r3:r2

                rcall tx_crlf
                ldi r16, '*'
                ldi r17, 3
                rcall tx_byte_repeat
                ldi r16, ' '
                rcall tx_byte

                rcall tx_string_crlf
                sbrc ZL, 0
                adiw Z, 1

menu_nav_opt:   lpm r17, Z+
                tst r17
                breq menu_nav_func
                
                ldi r16, '['
                rcall tx_byte
                mov r16, r17
                rcall tx_byte
                ldi r16, ']'
                rcall tx_byte
                ldi r16, ' '
                rcall tx_byte

                rcall tx_string_crlf
                sbrc ZL, 0
                adiw Z, 1
                adiw Z, 4
                rjmp menu_nav_opt

menu_nav_func:  adiw Z, 1
                lpm r24, Z+
                lpm r25, Z+
                adiw r25:r24, 0
                breq menu_nav_wait

                lpm r16, Z+
                lpm r17, Z+
                movw Z, r25:r24

                push r2
                push r3
                icall
                pop r3
                pop r2

menu_nav_wait:  movw Z, r3:r2
                
                lpm r16, Z+
                tst r16
                brne PC - 2
                sbrc ZL, 0
                adiw Z, 1

                lpm r16, Z
                tst r16
                breq menu_refresh

                rcall rx_byte
                mov r12, r16

menu_nav_chk:   lpm r13, Z+
                tst r13
                breq menu_nav_wait
                
                lpm r16, Z+
                tst r16
                brne PC - 2
                sbrc ZL, 0
                adiw Z, 1

                lpm r14, Z+
                lpm r15, Z+
                lpm r16, Z+
                lpm r17, Z+

                cp r12, r13
                brne menu_nav_chk

                movw Z, r15:r14
                push r2
                push r3
                icall ; these should return with menu_back, menu_continue or menu_refresh
                pop r3
                pop r2

                cpi r16, RET_MENU_BACK
                brne PC + 3
                rcall spi_close
                rjmp menu_refresh

                cpi r16, RET_MENU_CONTINUE
                brne PC + 2
                rjmp menu_nav_wait

                cpi r16, RET_MENU_REFRESH
                brne PC + 2
                rjmp menu_nav_ref

                rjmp menu_nav_ref

menu_back:      ldi r16, RET_MENU_BACK
                ret

menu_continue:  ldi r16, RET_MENU_CONTINUE
                ret

menu_refresh:   ldi r16, RET_MENU_REFRESH
                ret

PASS_STRING:    .db "PASS", 0
FAIL_STRING:    .db "FAIL", 0
RESULT_STRING:  .db "RESULT: ", 0

step_prog:      ldi r16, RET_STEP_PASS
                mov r2, r16

step_prog1:     lpm r16, Z
                tst r16
                breq step_prog_exit
               
                rcall tx_string
                sbrc ZL, 0
                adiw Z, 1

                ldi r16, '.'
                ldi r17, 3
                rcall tx_byte_repeat
                ldi r16, ' '
                rcall tx_byte

                lpm r16, Z+
                lpm r17, Z+

                push ZL
                push ZH
                push r2
                movw Z, r17:r16
                icall ; these should return with step_pass or step_fail
                pop r2
                pop ZH
                pop ZL

                cpi r16, RET_STEP_PASS
                breq step_prog1

                ldi r16, RET_STEP_FAIL
                mov r2, r16
                rjmp step_prog1

step_prog_exit: rcall tx_crlf
                ldi ZL, low(RESULT_STRING << 1)
                ldi ZH, high(RESULT_STRING << 1)
                rcall tx_string
                
                mov r16, r2
                cpi r16, RET_STEP_PASS
                breq step_pass
                rjmp step_fail

step_pass:      ldi ZL, low(PASS_STRING << 1)
                ldi ZH, high(PASS_STRING << 1)
                rcall tx_string_crlf

                ldi r16, RET_STEP_PASS
                ret

step_fail:      ldi ZL, low(FAIL_STRING << 1)
                ldi ZH, high(FAIL_STRING << 1)
                rcall tx_string_crlf
                
                ldi r16, RET_STEP_FAIL
                ret

////////////////////////////////////////////////// Comms

tx_8_bit_b16:   mov r16, r17
                swap r16
                rcall tx_4_bit_b16
                mov r16, r17
                rjmp tx_4_bit_b16

tx_4_bit_b16:   andi r16, 0x0F
                subi r16, -'0'
                cpi r16, '9' + 1
                brlo PC + 2
                subi r16, -('A' - '9' - 1)
                rjmp tx_byte

tx_24_bit_b10:  clt

                ldi r16, '0' - 1
                inc r16
                subi r17, low(10000000)
                sbci r18, byte2(10000000)
                sbci r19, byte3(10000000)
                brcc PC - 4
                subi r17, low(-10000000)
                sbci r18, byte2(-10000000)
                sbci r19, byte3(-10000000)

                brts PC + 4
                cpi r16, '0'
                breq PC + 3
                set
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(1000000)
                sbci r18, byte2(1000000)
                sbci r19, byte3(1000000)
                brcc PC - 4
                subi r17, low(-1000000)
                sbci r18, byte2(-1000000)
                sbci r19, byte3(-1000000)

                brts PC + 4
                cpi r16, '0'
                breq PC + 3
                set
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(100000)
                sbci r18, byte2(100000)
                sbci r19, byte3(100000)
                brcc PC - 4
                subi r17, low(-100000)
                sbci r18, byte2(-100000)
                sbci r19, byte3(-100000)

                brts PC + 4
                cpi r16, '0'
                breq PC + 3
                set
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(10000)
                sbci r18, byte2(10000)
                sbci r19, byte3(10000)
                brcc PC - 4
                subi r17, low(-10000)
                sbci r18, byte2(-10000)
                sbci r19, byte3(-10000)

                brts PC + 4
                cpi r16, '0'
                breq PC + 3
                set
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(1000)
                sbci r18, high(1000)
                brcc PC - 3
                subi r17, low(-1000)
                sbci r18, high(-1000)

                brts PC + 4
                cpi r16, '0'
                breq PC + 3
                set
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, low(100)
                sbci r18, high(100)
                brcc PC - 3
                subi r17, low(-100)
                sbci r18, high(-100)

                brts PC + 4
                cpi r16, '0'
                breq PC + 3
                set
                rcall tx_byte

                ldi r16, '0' - 1
                inc r16
                subi r17, 10
                brcc PC - 2
                subi r17, -10

                brts PC + 4
                cpi r16, '0'
                breq PC + 3
                set
                rcall tx_byte

                ldi r16, '0'
                add r16, r17
                rjmp tx_byte

tx_string_crlf: rcall tx_string
                rjmp tx_crlf

tx_string:      lpm r16, Z+
                tst r16
                brne PC + 2
                ret
                rcall tx_byte
                rjmp tx_string

tx_crlf:        ldi r16, 0x0D
                rcall tx_byte
                ldi r16, 0x0A
                rjmp tx_byte

tx_byte_repeat: rcall tx_byte
                dec r17
                brne tx_byte_repeat
                ret

tx_byte:        sbis UCSRA, UDRE
                rjmp tx_byte
                out UDR, r16
                ret

rx_byte:        sbis UCSRA, RXC
                rjmp rx_byte
                in r16, UDR
                ret

spi_master:     ldi r18, MASTER_PORT_INIT
                out PORT, r18
                ldi r18, MASTER_DDR_INIT
                out DDR, r18
                ldi r18, MASTER_SPSR_INIT
                out SPSR, r18
                ldi r18, MASTER_SPCR_INIT
                out SPCR, r18
                ret

spi_slave:      ldi r18, SLAVE_PORT_INIT
                out PORT, r18
                ldi r18, SLAVE_DDR_INIT
                out DDR, r18
                ldi r18, SLAVE_SPCR_INIT
                out SPCR, r18
                ret

spi_close:      ldi r18, CLOSE_SPCR_INIT
                out SPCR, r18
                ldi r18, CLOSE_DDR_INIT
                out DDR, r18
                ldi r18, CLOSE_PORT_INIT
                out PORT, r18
                ret

tx_slave_set:   cbi PORT, SS_PIN
                rcall txrx_spi

                sbiw r25:r24, 0
                breq PC + 7

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

                ld r16, X+
                rcall txrx_spi
                sbiw r25:r24, 1
                brne PC - 3

                sbi PORT, SS_PIN
                ret

tx_slave_get:   cbi PORT, SS_PIN
                rcall txrx_spi

                rcall txrx_spi ; dummy for slave to have enough time to load response

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)

                rcall txrx_spi
                st X+, r16
                sbiw r25:r24, 1
                brne PC - 3

                sbi PORT, SS_PIN
                ret

txrx_spi:       out SPDR, r16
                sbis SPSR, SPIF
                rjmp PC - 1
                in r16, SPDR
                ret

////////////////////////////////////////////////// Root/LC-8x8x8-RGB-00 (Master)/Interface

prog_00i_init:  ldi r16, 'i'
                rjmp tx_byte

prog_00i:       subi r16, -'0'
                rcall tx_byte
                rjmp menu_continue

////////////////////////////////////////////////// Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Interface

PROG_01I_STEPS:
.db "TX & RX big packet @ 250 kHz", 0 \ .dw prog_01i_s0
.db "TX & RX big packet @ 500 kHz", 0 \ .dw prog_01i_s1
.db "TX & RX big packet @ 1 MHz",   0 \ .dw prog_01i_s2
.db "TX & RX big packet @ 2 MHz",   0 \ .dw prog_01i_s3
.db "Check INT, pass 1",            0 \ .dw prog_01i_s4
.db "Check INT, pass 2",            0 \ .dw prog_01i_s4
.dw 0

prog_01i_init:  rcall spi_master
                ldi ZL, low(PROG_01I_STEPS << 1)
                ldi ZH, high(PROG_01I_STEPS << 1)
                rjmp step_prog

prog_01i_s0:    sbi SPSR, SPI2X
                ldi r16, MASTER_SPCR_INIT | (1 << SPR1)
                out SPCR, r16
                rjmp prog_01i_s0_3

prog_01i_s1:    cbi SPSR, SPI2X
                ldi r16, MASTER_SPCR_INIT | (1 << SPR0)
                out SPCR, r16
                rjmp prog_01i_s0_3

prog_01i_s2:    sbi SPSR, SPI2X
                ldi r16, MASTER_SPCR_INIT | (1 << SPR0)
                out SPCR, r16
                rjmp prog_01i_s0_3

prog_01i_s3:    cbi SPSR, SPI2X
                ldi r16, MASTER_SPCR_INIT
                out SPCR, r16
                rjmp prog_01i_s0_3

prog_01i_s0_3:  ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)
                ldi r24, low(D01_TEST_SET_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_DATA_SIZE)
                clr r16

                st X+, r16
                inc r16
                sbiw r25:r24, 1
                brne PC - 3

                ldi r16, D01_TEST_SET
                ldi r24, low(D01_TEST_SET_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_DATA_SIZE)
                rcall tx_slave_set

                ldi r16, D01_TEST_GET
                ldi r24, low(D01_TEST_GET_DATA_SIZE)
                ldi r25, high(D01_TEST_GET_DATA_SIZE)
                rcall tx_slave_get

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)
                ldi r24, low(D01_TEST_GET_DATA_SIZE)
                ldi r25, high(D01_TEST_GET_DATA_SIZE)
                clr r16

                ld r17, X+
                cp r17, r16
                breq PC + 2
                rjmp step_fail
                inc r16
                sbiw r25:r24, 1
                brne PC - 6

                rjmp step_pass

prog_01i_s4:    ldi r16, D01_TEST_SET_INT
                ldi r24, low(D01_TEST_SET_INT_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_INT_DATA_SIZE)
                rcall tx_slave_set

                ldi r16, 0
                dec r16
                brne PC - 1

                sbis PINREG, INT_PIN
                rjmp step_fail

                ldi r16, D01_CMD_GET_INT
                ldi r24, low(D01_CMD_GET_INT_DATA_SIZE)
                ldi r25, high(D01_CMD_GET_INT_DATA_SIZE)
                rcall tx_slave_get

                sbic PINREG, INT_PIN
                rjmp step_fail

                lds r16, PACKET_BUFFER
                andi r16, 1 << D01_CMD_GET_INT_FLAG_TEST_RDY
                brne PC + 2
                rjmp step_fail

                rjmp step_pass

////////////////////////////////////////////////// Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Shift Registers, manual load

.macro PROG_01SM_MACRO
.dd @0
.dw (D01_F_CPU / (2 * @0)) - 1
.endmacro

PROG_01SM_FREQUENCIES:
PROG_01SM_MACRO 10000
PROG_01SM_MACRO 100000
PROG_01SM_MACRO 250000
PROG_01SM_MACRO 500000
PROG_01SM_MACRO 1000000
PROG_01SM_MACRO 2000000
PROG_01SM_MACRO 4000000
PROG_01SM_MACRO 8000000

PROG_01SM_STRING:
.db "Frequency: ", 0, " Hz (Prescalar: ", 0, "), Byte: 0x", 0, ", Count: ", 0

PROG_01SM_STRING_SENT:
.db "Sent !", 0

prog_01sm_init: rcall spi_master

                ldi r16, 0
                sts PROGRAM_DATA + 0, r16
                sts PROGRAM_DATA + 1, r16
                sts PROGRAM_DATA + 2, r16
                rjmp prog_01sm_upd

.macro PROG_01SM_MACRO1
                lds r18, PROGRAM_DATA + @0
                add r18, r16
                sts PROGRAM_DATA + @0, r18
                rjmp prog_01sm_upd
.endmacro

prog_01sm_fq:   PROG_01SM_MACRO1 0
                
prog_01sm_by:   PROG_01SM_MACRO1 1

prog_01sm_cn:   PROG_01SM_MACRO1 2

prog_01sm_upd:  rcall tx_crlf
                
                ldi ZL, low(PROG_01SM_STRING << 1)
                ldi ZH, high(PROG_01SM_STRING << 1)
                rcall tx_string
                movw X, Z

                ldi ZL, low(PROG_01SM_FREQUENCIES << 1)
                ldi ZH, high(PROG_01SM_FREQUENCIES << 1)
                lds r16, PROGRAM_DATA + 0
                andi r16, 8 - 1
                ldi r17, 6
                mul r16, r17
                add ZL, r0
                adc ZH, r1

                lpm r17, Z+
                lpm r18, Z+
                lpm r19, Z+
                adiw Z, 1
                rcall tx_24_bit_b10
                movw Y, Z

                movw Z, X
                rcall tx_string
                movw X, Z

                movw Z, Y
                lpm r17, Z+
                lpm r18, Z+
                ldi r19, 0
                sts PACKET_BUFFER + D01_TEST_SET_SR_PRESCALAR_OFFSET + 0, r17
                sts PACKET_BUFFER + D01_TEST_SET_SR_PRESCALAR_OFFSET + 1, r18
                rcall tx_24_bit_b10

                movw Z, X
                rcall tx_string

                lds r17, PROGRAM_DATA + 1
                sts PACKET_BUFFER + D01_TEST_SET_SR_BYTE_OFFSET, r17
                rcall tx_8_bit_b16

                rcall tx_string

                lds r17, PROGRAM_DATA + 2
                ldi r18, 0
                ldi r19, 0
                sts PACKET_BUFFER + D01_TEST_SET_SR_COUNT_OFFSET + 0, r17
                sts PACKET_BUFFER + D01_TEST_SET_SR_COUNT_OFFSET + 1, r18
                sts PACKET_BUFFER + D01_TEST_SET_SR_COUNT_OFFSET + 2, r19
                rcall tx_24_bit_b10

                rjmp menu_continue

prog_01sm_tx:   ldi r16, D01_TEST_SET_SR_MODE_MANUAL
                sts PACKET_BUFFER + D01_TEST_SET_SR_MODE_OFFSET, r16

                ldi r16, D01_TEST_SET_SR
                ldi r24, low(D01_TEST_SET_SR_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_SR_DATA_SIZE)
                rcall tx_slave_set

prog_01sm_tx_lp:sbis PINREG, INT_PIN
                rjmp prog_01sm_tx_lp
                
                ldi r16, D01_CMD_GET_INT
                ldi r24, low(D01_CMD_GET_INT_DATA_SIZE)
                ldi r25, high(D01_CMD_GET_INT_DATA_SIZE)
                rcall tx_slave_get

                lds r16, PACKET_BUFFER
                andi r16, 1 << D01_CMD_GET_INT_FLAG_TEST_RDY
                breq prog_01sm_tx_lp
                
                rcall tx_crlf

                ldi ZL, low(PROG_01SM_STRING_SENT << 1)
                ldi ZH, high(PROG_01SM_STRING_SENT << 1)
                rcall tx_string

                rjmp menu_continue

////////////////////////////////////////////////// Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Shift Registers, auto load

PROG_01SA_STEPS:
.db "Load and read shift registers @ 250 kHz for 1 minute", 0 \ .dw prog_01sa_s0
.db "Load and read shift registers @ 500 kHz for 1 minute", 0 \ .dw prog_01sa_s1
.db "Load and read shift registers @ 1 MHz for 1 minute",   0 \ .dw prog_01sa_s2
.db "Load and read shift registers @ 2 MHz for 1 minute",   0 \ .dw prog_01sa_s3
.db "Load and read shift registers @ 4 MHz for 30 seconds", 0 \ .dw prog_01sa_s4
.dw 0

PROG_01SA_ERROR_STRING: .db " errors ", 0

prog_01sa_init: rcall spi_master
                ldi ZL, low(PROG_01SA_STEPS << 1)
                ldi ZH, high(PROG_01SA_STEPS << 1)
                rjmp step_prog

.macro PROG_01SA_MACRO
                ldi r18, low(D01_F_CPU / (2 * @0) - 1)
                ldi r19, high(D01_F_CPU / (2 * @0) - 1)
                ldi r20, low(@1 * (@0 / 8))
                ldi r21, byte2(@1 * (@0 / 8))
                ldi r22, byte3(@1 * (@0 / 8))
                rjmp prog_01sa_s0_4
.endmacro

prog_01sa_s0:   PROG_01SA_MACRO 250000, 60

prog_01sa_s1:   PROG_01SA_MACRO 500000, 60

prog_01sa_s2:   PROG_01SA_MACRO 1000000, 60

prog_01sa_s3:   PROG_01SA_MACRO 2000000, 60

prog_01sa_s4:   PROG_01SA_MACRO 4000000, 30

prog_01sa_s0_4: ldi r16, D01_TEST_SET_SR_MODE_AUTO
                ldi r17, 0xAA
                
                sts PACKET_BUFFER + D01_TEST_SET_SR_MODE_OFFSET, r16
                sts PACKET_BUFFER + D01_TEST_SET_SR_BYTE_OFFSET, r17
                sts PACKET_BUFFER + D01_TEST_SET_SR_PRESCALAR_OFFSET + 0, r18
                sts PACKET_BUFFER + D01_TEST_SET_SR_PRESCALAR_OFFSET + 1, r19
                sts PACKET_BUFFER + D01_TEST_SET_SR_COUNT_OFFSET + 0, r20
                sts PACKET_BUFFER + D01_TEST_SET_SR_COUNT_OFFSET + 1, r21
                sts PACKET_BUFFER + D01_TEST_SET_SR_COUNT_OFFSET + 2, r22

                ldi r16, D01_TEST_SET_SR
                ldi r24, low(D01_TEST_SET_SR_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_SR_DATA_SIZE)
                rcall tx_slave_set

prog_01sa_tx_lp:sbis PINREG, INT_PIN
                rjmp prog_01sa_tx_lp
                
                ldi r16, D01_CMD_GET_INT
                ldi r24, low(D01_CMD_GET_INT_DATA_SIZE)
                ldi r25, high(D01_CMD_GET_INT_DATA_SIZE)
                rcall tx_slave_get

                lds r16, PACKET_BUFFER
                andi r16, 1 << D01_CMD_GET_INT_FLAG_TEST_RDY
                breq prog_01sa_tx_lp

                ldi r16, D01_TEST_GET_SR
                ldi r24, low(D01_TEST_GET_SR_DATA_SIZE)
                ldi r25, high(D01_TEST_GET_SR_DATA_SIZE)
                rcall tx_slave_get

                lds r17, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 0
                lds r18, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 1
                lds r19, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 2
                
                rcall tx_24_bit_b10
                ldi ZL, low(PROG_01SA_ERROR_STRING << 1)
                ldi ZH, high(PROG_01SA_ERROR_STRING << 1)
                rcall tx_string

                lds r17, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 0
                lds r18, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 1
                lds r19, PACKET_BUFFER + D01_TEST_GET_SR_ERROR_COUNT_OFFSET + 2

                clr r16
                cp r17, r16
                cpc r18, r16
                cpc r19, r16
                breq PC + 2
                rjmp step_fail
                rjmp step_pass

////////////////////////////////////////////////// Root/LC-8x8x8-RGB-01 (Led Cube Slave)/LEDs

PROG_01L_MODES:
.db "NON", 0 \ .dw PROG_01L_NON_STEP_COUNT, prog_01l_non
.db "SL1", 0 \ .dw PROG_01L_SL_STEP_COUNT,  prog_01l_sl
.db "SL2", 0 \ .dw PROG_01L_SL_STEP_COUNT,  prog_01l_sl
.db "SL3", 0 \ .dw PROG_01L_SL_STEP_COUNT,  prog_01l_sl
.db "SL4", 0 \ .dw PROG_01L_SL_STEP_COUNT,  prog_01l_sl
.db "SL5", 0 \ .dw PROG_01L_SL_STEP_COUNT,  prog_01l_sl
.db "SL6", 0 \ .dw PROG_01L_SL_STEP_COUNT,  prog_01l_sl
.db "SL7", 0 \ .dw PROG_01L_SL_STEP_COUNT,  prog_01l_sl
.db "SL8", 0 \ .dw PROG_01L_SL_STEP_COUNT,  prog_01l_sl
.db "FUL", 0 \ .dw PROG_01L_FUL_STEP_COUNT, prog_01l_ful

PROG_01L_STRING:
.db "Mode: ", 0, ", Step ", 0, " of ", 0

PROG_01L_COLORS_SHORTHAND:
.db "-RGYBMCW"

prog_01l_init:  rcall spi_master

prog_01l_mode:  sts PROGRAM_DATA + 0, r16

                ldi r17, 0
                sts PROGRAM_DATA + 1, r17
                sts PROGRAM_DATA + 2, r17

                ldi ZL, low(PROG_01L_MODES << 1)
                ldi ZH, high(PROG_01L_MODES << 1)
                ldi r17, 8
                mul r16, r17
                add ZL, r0
                adc ZH, r1

                sts PROGRAM_DATA + 3, ZL
                sts PROGRAM_DATA + 4, ZH

                adiw Z, 4
                lpm r16, Z+
                lpm r17, Z+
                sts PROGRAM_DATA + 5, r16
                sts PROGRAM_DATA + 6, r17

                lpm r16, Z+
                lpm r17, Z+
                sts PROGRAM_DATA + 7, r16
                sts PROGRAM_DATA + 8, r17

                rjmp prog_01l_upd

prog_01l_step:  lds r18, PROGRAM_DATA + 1
                lds r19, PROGRAM_DATA + 2
                add r18, r16
                adc r19, r17

                ldi r16, low(0)
                ldi r17, high(0)
                cp r18, r16
                cpc r19, r17
                brge PC + 2
                movw r19:r18, r17:r16

                lds r16, PROGRAM_DATA + 5
                lds r17, PROGRAM_DATA + 6
                cp r18, r16
                cpc r19, r17
                brlt PC + 4
                movw r19:r18, r17:r16
                subi r18, low(1)
                sbci r19, high(1)

                lds r16, PROGRAM_DATA + 1
                lds r17, PROGRAM_DATA + 2
                cp r18, r16
                cpc r19, r17
                brne PC + 2
                rjmp menu_continue

                sts PROGRAM_DATA + 1, r18
                sts PROGRAM_DATA + 2, r19
                rjmp prog_01l_upd

prog_01l_upd:   lds r23, PROGRAM_DATA + 0
                lds r24, PROGRAM_DATA + 1
                lds r25, PROGRAM_DATA + 2
                lds ZL, PROGRAM_DATA + 7
                lds ZH, PROGRAM_DATA + 8

                icall

                sts PACKET_BUFFER + D01_TEST_SET_LEDS_START_LED_OFFSET, r16
                sts PACKET_BUFFER + D01_TEST_SET_LEDS_END_LED_OFFSET, r17
                sts PACKET_BUFFER + D01_TEST_SET_LEDS_COLOR_OFFSET, r18
                sts PACKET_BUFFER + D01_TEST_SET_LEDS_LEVEL_OFFSET, r19

                ldi r16, D01_TEST_SET_LEDS
                ldi r24, low(D01_TEST_SET_LEDS_DATA_SIZE)
                ldi r25, high(D01_TEST_SET_LEDS_DATA_SIZE)
                rcall tx_slave_set

                rcall tx_crlf

                ldi ZL, low(PROG_01L_STRING << 1)
                ldi ZH, high(PROG_01L_STRING << 1)
                rcall tx_string
                movw X, Z

                lds ZL, PROGRAM_DATA + 3
                lds ZH, PROGRAM_DATA + 4
                rcall tx_string

                movw Z, X
                rcall tx_string

                lds r17, PROGRAM_DATA + 1
                lds r18, PROGRAM_DATA + 2
                ldi r19, 0
                subi r17, low(-1)
                sbci r18, high(-1)
                rcall tx_24_bit_b10

                rcall tx_string

                lds r17, PROGRAM_DATA + 5
                lds r18, PROGRAM_DATA + 6
                ldi r19, 0
                rcall tx_24_bit_b10

                rcall tx_crlf

                ldi r17, 0
                ldi r18, D01_CUBE_EDGE_SIZE - 1

                lds r19, PACKET_BUFFER + D01_TEST_SET_LEDS_START_LED_OFFSET
                lds r20, PACKET_BUFFER + D01_TEST_SET_LEDS_END_LED_OFFSET
                lds r21, PACKET_BUFFER + D01_TEST_SET_LEDS_COLOR_OFFSET
                lds r22, PACKET_BUFFER + D01_TEST_SET_LEDS_LEVEL_OFFSET

prog_01l_upd0:  ldi r16, '-'
                cp r18, r22
                brne PC + 3
                mov r16, r18
                subi r16, -'0'

                rcall tx_byte
                
                ldi r16, '|'
                rcall tx_byte

prog_01l_upd1:  ldi r16, D01_TEST_SET_LEDS_COLOR_NONE
                cp r17, r19
                brlo PC + 4
                cp r20, r17
                brlo PC + 2
                mov r16, r21

                ldi ZL, low(PROG_01L_COLORS_SHORTHAND << 1)
                ldi ZH, high(PROG_01L_COLORS_SHORTHAND << 1)
                add ZL, r16
                ldi r16, 0
                adc ZH, r16
                lpm r16, Z

                rcall tx_byte

                inc r17
                mov r16, r17
                andi r16, D01_CUBE_EDGE_SIZE - 1
                brne prog_01l_upd1

                rcall tx_crlf
                dec r18

                cpi r17, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                brlo prog_01l_upd0
                rjmp menu_continue

.equ PROG_01L_NON_STEP_COUNT = D01_CUBE_EDGE_SIZE + (D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE) * 4

prog_01l_non:   ldi r16, low(D01_CUBE_EDGE_SIZE)
                ldi r17, high(D01_CUBE_EDGE_SIZE)
                cp r24, r16
                cpc r25, r17
                brsh PC + 6

                mov r19, r24
                clr r16
                clr r17
                ldi r18, D01_TEST_SET_LEDS_COLOR_WHITE
                ret

                sbiw r25:r24, D01_CUBE_EDGE_SIZE

                rcall prog_01l_col

                mov r16, r24
                mov r17, r24
                ldi r19, D01_CUBE_EDGE_SIZE - 1
                ret

.equ PROG_01L_SL_STEP_COUNT = (D01_CUBE_EDGE_SIZE + 1) * D01_CUBE_EDGE_SIZE * 4

prog_01l_sl:    rcall prog_01l_col

                ldi r19, -1

                inc r19
                subi r24, D01_CUBE_EDGE_SIZE + 1
                brcc PC - 2
                
                subi r24, -(D01_CUBE_EDGE_SIZE + 1)
                
                cpi r24, D01_CUBE_EDGE_SIZE
                breq PC + 4
                mov r16, r24
                mov r17, r24
                rjmp PC + 3
                ldi r16, 0
                ldi r17, D01_CUBE_EDGE_SIZE - 1

                dec r23
                ldi r20, D01_CUBE_EDGE_SIZE
                mul r23, r20

                add r16, r0
                add r17, r0
                ret

.equ PROG_01L_FUL_STEP_COUNT = (D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1) * D01_CUBE_EDGE_SIZE * 4

prog_01l_ful:   rcall prog_01l_col

                ldi r19, -1

                inc r19
                subi r24, low(D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1)
                sbci r25, high(D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1)
                brcc PC - 3
                
                subi r24, low(-(D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1))
                sbci r25, high(-(D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE + 1))
                
                cpi r24, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE
                breq PC + 4
                mov r16, r24
                mov r17, r24
                rjmp PC + 3
                ldi r16, 0
                ldi r17, D01_CUBE_EDGE_SIZE * D01_CUBE_EDGE_SIZE - 1
                ret

prog_01l_col:   mov r18, r24
                andi r18, 0x03

                lsr r25
                ror r24
                lsr r25
                ror r24

                cpi r18, 0
                brne PC + 3
                ldi r18, D01_TEST_SET_LEDS_COLOR_RED
                ret

                cpi r18, 1
                brne PC + 3
                ldi r18, D01_TEST_SET_LEDS_COLOR_GREEN
                ret

                cpi r18, 2
                brne PC + 3
                ldi r18, D01_TEST_SET_LEDS_COLOR_BLUE
                ret

                ldi r18, D01_TEST_SET_LEDS_COLOR_WHITE
                ret

////////////////////////////////////////////////// Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Cube, basic checks

PROG_01C_STEPS:
.db "Verify DEVID",                                  0 \ .dw prog_01c_s0
.db "Measure how many frames there are in 1 second", 0 \ .dw prog_01c_s1
.dw 0

PROG_01C_FRAME_STRING: .db " frames ", 0

prog_01c_init:  rcall spi_master
                ldi ZL, low(PROG_01C_STEPS << 1)
                ldi ZH, high(PROG_01C_STEPS << 1)
                rjmp step_prog

prog_01c_s0:    ldi r16, D01_CMD_GET_DEVID
                ldi r24, low(D01_CMD_GET_DEVID_DATA_SIZE)
                ldi r25, high(D01_CMD_GET_DEVID_DATA_SIZE)
                rcall tx_slave_get

                ldi r16, '0'
                rcall tx_byte
                ldi r16, 'x'
                rcall tx_byte
                lds r17, PACKET_BUFFER
                rcall tx_8_bit_b16
                ldi r16, ' '
                rcall tx_byte

                cpi r17, D01_CMD_GET_DEVID_VALUE
                breq PC + 2
                rjmp step_fail
                rjmp step_pass

prog_01c_s1:    ldi r16, D01_CMD_GET_INT
                ldi r24, low(D01_CMD_GET_INT_DATA_SIZE)
                ldi r25, high(D01_CMD_GET_INT_DATA_SIZE)
                rcall tx_slave_get

                ldi r16, high((F_CPU / 256) - 1)
                out OCR1AH, r16
                ldi r16, low((F_CPU / 256) - 1)
                out OCR1AL, r16
                ldi r16, (1 << WGM12) | (1 << CS12)
                out TCCR1B, r16

                ldi r20, 0

prog_01c_s1_lp: in r16, TIFR
                sbrc r16, OCF1A
                rjmp prog_01c_s1_end

                sbis PINREG, INT_PIN
                rjmp prog_01c_s1_lp
                
                ldi r16, D01_CMD_GET_INT
                ldi r24, low(D01_CMD_GET_INT_DATA_SIZE)
                ldi r25, high(D01_CMD_GET_INT_DATA_SIZE)
                rcall tx_slave_get

                lds r16, PACKET_BUFFER
                andi r16, 1 << D01_CMD_GET_INT_FLAG_NEW_FRAME_RDY
                breq prog_01c_s1_lp
                
                inc r20
                rjmp prog_01c_s1_lp

prog_01c_s1_end:ldi r16, 0
                out TCCR1B, r16
                out TCNT1H, r16
                out TCNT1L, r16
                out OCR1AH, r16
                out OCR1AL, r16
                ldi r16, (1 << OCF1A)
                out TIFR, r16
                ldi r16, (1 << PSR10)
                out SFIOR, r16

                mov r17, r20
                ldi r18, 0
                ldi r19, 0
                rcall tx_24_bit_b10
                ldi r16, ' '
                rcall tx_byte

                cpi r20, D01_FRAME_RATE_APROX
                breq PC + 2
                rjmp step_fail
                rjmp step_pass

////////////////////////////////////////////////// Root/LC-8x8x8-RGB-01 (Led Cube Slave)/Cube, one color frame

PROG_01F_STRING:
.db "Red: 0x", 0, " Green: 0x", 0, " Blue: 0x", 0, " Brightness: 0x", 0

prog_01f_init:  rcall spi_master

                ldi r16, 0
                sts PROGRAM_DATA + 0, r16
                sts PROGRAM_DATA + 1, r16
                sts PROGRAM_DATA + 2, r16
                ldi r16, D01_CMD_SET_BRIGHT_MAX
                sts PROGRAM_DATA + 3, r16
                rjmp prog_01f_upd

.macro PROG_01F_MACRO
                lds r18, PROGRAM_DATA + @0
                add r18, r16
                andi r18, 0x0F
                sts PROGRAM_DATA + @0, r18
                @1
                rjmp prog_01f_upd
.endmacro

prog_01f_r:     PROG_01F_MACRO 0, set
                
prog_01f_g:     PROG_01F_MACRO 1, set

prog_01f_b:     PROG_01F_MACRO 2, set

prog_01f_br:    PROG_01F_MACRO 3, clt

prog_01f_upd:   rcall tx_crlf
                
                ldi ZL, low(PROG_01F_STRING << 1)
                ldi ZH, high(PROG_01F_STRING << 1)
                rcall tx_string
                movw X, Z

                lds r17, PROGRAM_DATA + 0
                rcall tx_8_bit_b16

                movw Z, X
                rcall tx_string
                movw X, Z

                lds r17, PROGRAM_DATA + 1
                rcall tx_8_bit_b16

                movw Z, X
                rcall tx_string
                movw X, Z

                lds r17, PROGRAM_DATA + 2
                rcall tx_8_bit_b16

                movw Z, X
                rcall tx_string
                movw X, Z

                lds r17, PROGRAM_DATA + 3
                rcall tx_8_bit_b16

                brts prog_01f_txf
                rjmp prog_01f_txbr

prog_01f_txf:   lds r16, PROGRAM_DATA + 0
                lds r17, PROGRAM_DATA + 1
                lds r18, PROGRAM_DATA + 2

                mov r19, r18
                swap r19
                or r19, r17

                mov r20, r16
                swap r20
                or r20, r18

                mov r21, r17
                swap r21
                or r21, r16

                ldi XL, low(PACKET_BUFFER)
                ldi XH, high(PACKET_BUFFER)
                ldi r24, low(D01_CMD_SET_FRAME_DATA_SIZE / 3)
                ldi r25, high(D01_CMD_SET_FRAME_DATA_SIZE / 3)

                st X+, r19
                st X+, r20
                st X+, r21
                sbiw r25:r24, 1
                brne PC - 4

                ldi r16, D01_CMD_SET_FRAME
                ldi r24, low(D01_CMD_SET_FRAME_DATA_SIZE)
                ldi r25, high(D01_CMD_SET_FRAME_DATA_SIZE)
                rcall tx_slave_set
                rjmp menu_continue

prog_01f_txbr:  lds r16, PROGRAM_DATA + 3
                sts PACKET_BUFFER, r16

                ldi r16, D01_CMD_SET_BRIGHT
                ldi r24, low(D01_CMD_SET_BRIGHT_DATA_SIZE)
                ldi r25, high(D01_CMD_SET_BRIGHT_DATA_SIZE)
                rcall tx_slave_set
                rjmp menu_continue
