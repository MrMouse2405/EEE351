/********************************************************************************
* File: countdown_pos.s
*
* Author: OCdt Syed & OCdt Tchameni Moko
*
* Description: Implement a simple timer using Binary Coded Decimal (BCD)
********************************************************************************/

        .syntax unified
        .global _start
        .include "EEE351.inc"
/*******EQUATES*****************************************************************/
        .equ        TIMER_START, 999 // in 10th's of a second (99.9s)
        .equ        DELAY,       400000

/*******Global Constants********************************************************/
        .section    .rodata


/*******Global Variables********************************************************/
        .section    .data


/*******Code Section************************************************************/
        .section    .text
        .thumb_func
_start:
        BL initializeGPIOs
        BL countdown
        BKPT  #1

/********************************************************************************
 * Subroutine: countdown
 *
 * Description:
 *   This subroutine counts down every 100 ms and displays the value on the
 *   seven-segment display and LEDs.
 *
 * Notes:
 *   - r0–r1 and r6–r8 are modified by this subroutine.
 *   - Timer is represented in 1/10 seconds and converted to BCD for display.
 *
 * Inputs:
 *   None
 *
 * Outputs:
 *   None
 ********************************************************************************/
countdown:
    PUSH    {r6-r8, lr}

    LDR     r8, =TIMER_START        @ initial timer value
    LDR     r7, =GPIOB_ODR          @ seven-segment display port
    LDR     r6, =GPIOC_ODR          @ LED display port

0:
    /* Convert binary to BCD */
    MOV     r0, r8
    BL      splitBCD                @ r0 = high two digits (seconds)
                                    @ r1 = last digit (100 ms)

    /* Display on seven-segment display and LEDs */
    STRB    r0, [r7]                @ display seconds (0xAB: A=10s, B=1s)
    STRB    r1, [r6]                @ display 1/10 seconds (0xC)

    /* Termination condition */
    CMP     r8, #0
    BEQ     1f

    /* Countdown and delay 100 ms */
    SUB     r8, r8, #1
    BL      delay100ms
    B       0b

1:
    POP     {r6-r8, lr}
    BX      lr



/********************************************************************************
 * Subroutine: splitBCD
 *
 * Description:
 *   Converts a timer value (in 1/10 seconds, as an integer) into a BCD format
 *   suitable for display on the seven-segment display and LEDs.
 *
 * Notes:
 *   - r0–r1 and r6–r8 are modified by this subroutine.
 *   - Timer is represented in 1/10 seconds, converted to BCD for display.
 *   - If X is the timer value (e.g., 987 → ABC digits),
 *     this subroutine converts it into:
 *       r0 = 0xAB (tens and ones)
 *       r1 = 0xC  (hundredths)
 *
 * Inputs:
 *   r0 = X (timer value to be converted)
 *
 * Outputs:
 *   r0 = 0xAB  → upper two digits (tens and ones)
 *   r1 = 0xC   → lowest digit (hundredths)
 ********************************************************************************/

splitBCD:
    PUSH    {LR}

    /* First divide: extract upper two digits and last digit */
    MOV     r1, #10
    BL      x86StyleUnsignedDivide   @ r0 = quotient  (987 => 98)
                                     @ r1 = remainder (987 => 7)
    MOV     r2, r1                   @ save last digit (r2 = 7)

    /* Convert 98 → 0x99 (decimal to BCD) */
    MOV     r1, #10
    BL      x86StyleUnsignedDivide   @ r0 = quotient  (98 => 9)
                                     @ r1 = remainder (98 → 8)

    LSL     r0, r0, #4               @ shift high nibble (9 => 0x90)
    ORR     r0, r0, r1               @ combine (0x90 | 0x08 = 0x98)
    MOV     r1, r2                   @ r1 = 0x07 (last digit in BCD)

    /* Commentary:
     * turns out I am optimizing this like a compiler, the lab report will tell
     * you how we reached to this conclusion; prior x86 experience
     * helped optimize the algorithm.
     */

    POP     {LR}
    BX      LR

/********************************************************************************
 * Subroutine: x86StyleUnsignedDivide
 *
 * Description:
 *   Performs an unsigned integer division similar to the x86 DIV instruction.
 *   Given a dividend and divisor, it returns both the quotient and remainder.
 *
 * Notes:
 *   - r0–r3 are modified by this subroutine.
 *   - The algorithm uses the ARM `UDIV` instruction for hardware division:
 *       quotient  = dividend / divisor
 *       remainder = dividend - (quotient * divisor)
 *   - Equivalent to x86’s `DIV` instruction, which outputs:
 *       AX / r/m8 → AL = quotient, AH = remainder
 *   - https://stackoverflow.com/questions/35351470/obtaining-remainder-using-single-aarch64-instruction
 *
 * Inputs:
 *   r0 = dividend
 *   r1 = divisor
 *
 * Outputs:
 *   r0 = quotient
 *   r1 = remainder
 ********************************************************************************/
x86StyleUnsignedDivide:
    UDIV    r2, r0, r1        @ r2 = quotient = dividend / divisor
    MUL     r3, r2, r1        @ r3 = quotient * divisor
    SUB     r3, r0, r3        @ r3 = dividend - (quotient * divisor)

    MOV     r0, r2            @ return quotient in r0
    MOV     r1, r3            @ return remainder in r1

    BX      LR

/********************************************************************************
 * Subroutine: delay100ms
 *
 * Description:
 *   This subroutine causes a blocking delay of approximately 100ms
 *
 * Notes:
 *   - r0 is modified for this subroutine.
 *   - The inner loop is approximately 4 cycles.
 *   - The default clock speed is 16Mhz.
 *
 * Inputs:
 *   None
 *
 * Outputs:
 *   None
 ********************************************************************************/
delay100ms:
    LDR     r0, =DELAY

0:
    CBZ     r0, 0f               @ 1 cycle when no branch is taken
    SUB     r0, r0, #1           @ 1 cycle
    B       0b                   @ 1 + P cycles where P depends on the branch distance

0:
    BX      LR


/********************************************************************************
* Subroutine: initializeGPIOs
*
* Description: This subroutine is where GPIO ports B & C are initialized.
*              Output Mode - Push Pull Mode - Slow Speed - No Internal Resistors
*
* Notes: r0-r3 are modifed in this subroutine for register addresses and values.
*
* Inputs: None
*
* Outputs: None
********************************************************************************/
initializeGPIOs:
                                                    @ Enable GPIOs B & C
    LDR     r0, =RCC_AHB2ENR
    LDR     r1, [r0]
    LDR     r2, =0x00000006
    ORR     r1, r1, r2
    STR     r1, [r0]

                                                    @ Set GPIO PB7-PB0 to Output Mode (0x01)
    LDR     r0, =GPIOB_MODER
    LDR     r1, [r0]
    LDR     r2, =0x0000FFFF
    BIC     r1, r1, r2
    LDR     r3, =0x00005555
    ORR     r1, r1, r3
    STR     r1, [r0]

                                                    @ Set GPIO PC3-PC0 to Output Mode (0x01)
    LDR     r0, =GPIOC_MODER
    LDR     r1, [r0]
    LDR     r2, =0x000000FF
    BIC     r1, r1, r2
    LDR     r3, =0x00000055
    ORR     r1, r1, r3
    STR     r1, [r0]

                                                    @ Set GPIO PB7-PB0 to Push-Pull Mode (0x0)
    LDR     r0, =GPIOB_OTYPER
    LDR     r1, [r0]
    LDR     r2, =0x000000FF
    BIC     r1, r1, r2
    STR     r1, [r0]

                                                    @ Set GPIO PC3-PC0 to Push-Pull Mode (0x0)
    LDR     r0, =GPIOC_OTYPER
    LDR     r1, [r0]
    LDR     r2, =0x0000000F
    BIC     r1, r1, r2
    STR     r1, [r0]

                                                    @ Set GPIO PB7-PB0 to Slow Speed Mode (0x00)
    LDR     r0, =GPIOB_OSPEEDR
    LDR     r1, [r0]
    LDR     r2, =0x0000FFFF
    BIC     r1, r1, r2
    STR     r1, [r0]

                                                    @ Set GPIO PC3-PC0 to Slow Speed Mode (0x00)
    LDR     r0, =GPIOC_OSPEEDR
    LDR     r1, [r0]
    LDR     r2, =0x000000FF
    BIC     r1, r1, r2
    STR     r1, [r0]

                                                    @ Disable GPIO PB7-PB0 Internal Pull-up/Pull-down Resistors (0x00)
    LDR     r0, =GPIOB_PUPDR
    LDR     r1, [r0]
    LDR     r2, =0x0000FFFF
    BIC     r1, r1, r2
    STR     r1, [r0]

                                                    @ Disable GPIO PC3-PC0 Internal Pull-up/Pull-down Resistors (0x00)
    LDR     r0, =GPIOC_PUPDR
    LDR     r1, [r0]
    LDR     r2, =0x000000FF
    BIC     r1, r1, r2
    STR     r1, [r0]

    BX      LR

	.end
