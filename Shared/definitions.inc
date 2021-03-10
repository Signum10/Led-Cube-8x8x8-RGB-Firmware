////////////////////////////////////////////////// LC-8x8x8-RGB-01 (Led Cube Slave)
.equ D01_SR_COUNT       = 25  ; Number of shift registers
.equ D01_FRAME_SIZE     = 768 ; A frame has 8x8x8x12 bits

.equ D01_SET_TEST_DATA  = 1
.equ D01_GET_TEST_DATA  = 2
.equ D01_SET_INT_HIGH   = 3
.equ D01_SET_INT_LOW    = 4
.equ D01_START_SR_TEST  = 5
.equ D01_START_SR_LOAD  = 6

.equ D01_SR_TEST_PRESCALAR_SIZE     = 2
.equ D01_SR_TEST_COUNT_SIZE         = 3
.equ D01_SR_TEST_ERROR_COUNT_SIZE   = D01_SR_TEST_COUNT_SIZE
.equ D01_SR_TEST_PRESCALAR_OFFSET   = 0
.equ D01_SR_TEST_COUNT_OFFSET       = D01_SR_TEST_PRESCALAR_OFFSET + D01_SR_TEST_PRESCALAR_SIZE
.equ D01_SR_TEST_ERROR_COUNT_OFFSET = D01_SR_TEST_COUNT_OFFSET + D01_SR_TEST_COUNT_SIZE
.equ D01_SR_TEST_BYTE               = 0xAA
