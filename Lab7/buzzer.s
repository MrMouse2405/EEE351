/********************************************************************************
* File: buzzer.s
*
* Author:
*
* Description:
*
* Revision History: 29 March 2023 Created
********************************************************************************/

.syntax unified
.global _start
.include "EEE351.inc"

/******* EQUATES *****************************************************************/
.equ  TIMER_OVERFLOW_POINT,  469 @ ARR value for 1khz
.equ  TIMER_PRESCALER_VALUE, 16
.equ  TIMER_TARGET_VALUE,   0    @ Target value for CCR1
.equ  ISR_INTERRUPT_VALUE,  27

/******* Global Constants ********************************************************/
.section    .rodata

/******* Global Variables ********************************************************/
.section    .data

/******* Code Section ************************************************************/
.section    .text
.thumb_func

_start:
    BL initializeGPIOs
    BL turnOffLED
    BL turnOnLED
    BL configureAndStartTimer

    // This infinite loop is here by design; once your GPIO, timer, and interrupts are
    // configured, the main logic of this lab will be carried out in your ISR.
loop:
    NOP
    B loop
    BKPT 1



.thumb_func
.global TIM1_CC_IRQHandler
TIM1_CC_IRQHandler:
    // Clear Status Register
    LDR     r0, =TIM1_SR
    LDR     r1, [r0]
    LDR     r2, =0x00000002 // CC1F
    BIC     r1, r1, r2
    STR     r1, [r0]

    // Clear Interrupt Enable Register
    LDR     r0, =TIM1_DIER
    LDR     r1, [r0]
    LDR     r2, =0x00000002 // CC1IE
    ORR     r1, r1, r2
    STR     r1, [r0]

    // turn on/off
    LDR     r0, =GPIOA_ODR
    LDR     r1, [r0]
    LDR     r2, =0x00000001
    EOR     r1, r1, r2
    STR     r1, [r0]
    BX      LR



turnOnLED:
    LDR     r0, =GPIOA_ODR
    LDR     r1, [r0]
    LDR     r2, =0x00000002
    BIC     r1, r1, r2
    STR     r1, [r0]
    BX      LR


turnOffLED:
    LDR     r0, =GPIOA_ODR
    LDR     r1, [r0]
    LDR     r2, =0x00000002
    ORR     r1, r1, r2
    STR     r1, [r0]
    BX      LR

configureAndStartTimer:
    /*
      Configure Timer
    */
    // Enable TIM1
    LDR     r0, =RCC_APB2ENR
    LDR     r1, [r0]
    LDR     r2, =0x00000800
    ORR     r1, r1, r2
    STR     r1, [r0]

    // Set Prescaler Value
    LDR     r0, =TIM1_PSC
    LDR     r1, =TIMER_PRESCALER_VALUE
    STR     r1, [r0]

    // Set Overflow point
    LDR     r0, =TIM1_ARR
    LDR     r1, =TIMER_OVERFLOW_POINT
    STR     r1, [r0]

    // Stop the Timer while debugging
    LDR     r0, =DBGMCU_APB2FZ
    LDR     r1, [r0]
    LDR     r2, =0x00000800
    ORR     r1, r1, r2
    STR     r1, [r0]

    // Set Target Value
    LDR     r0, =TIM1_CCR1
    LDR     r1, =TIMER_TARGET_VALUE
    STR     r1, [r0]

    /*
      Timer Interrupts
    */
    // Clear Status Register
    LDR     r0, =TIM1_SR
    LDR     r1, [r0]
    LDR     r2, =0x00000002 // CC1F
    BIC     r1, r1, r2
    STR     r1, [r0]

    // Clear Interrupt Enable Register
    LDR     r0, =TIM1_DIER
    LDR     r1, [r0]
    LDR     r2, =0x00000002 // CC1IE
    ORR     r1, r1, r2
    STR     r1, [r0]

    // Enable NVIC
    LDR     r0, =NVIC_ISER0
    LDR     r1, [r0]
    LDR     r2, = (0x1 << ISR_INTERRUPT_VALUE)
    ORR     r1, r1, r2
    STR     r1, [r0]

    // Start Counter
    LDR     r0, =TIM1_CR1
    LDR     r1, [r0]
    LDR     r2, =0x00000001
    ORR     r1, r1, r2
    STR     r1, [r0]

    BX      LR

/********************************************************************************
* Subroutine: initializeGPIOs
*
* Description: This subroutine is where GPIO ports A
*              are initialized. It configures GPIO for LED & Buzzer:
*              - Output Mode
*              - Push Pull Mode
*              - Slow Speed
*              - No Internal Resistors
*
* Notes: r0-r3 are modified in this subroutine for register addresses and values.
*
* Inputs: None
*
* Outputs: None
********************************************************************************/
initializeGPIOs:
    /*
      LED & Buzzer
    */
    // Enable GPIO A
    LDR     r0, =RCC_AHB2ENR
    LDR     r1, [r0]
    LDR     r2, =0x00000001
    ORR     r1, r1, r2
    STR     r1, [r0]

    // Set GPIO PA0-PA1 to Output Mode (0x01)
    LDR     r0, =GPIOA_MODER
    LDR     r1, [r0]
    LDR     r2, =0x0000000F
    BIC     r1, r1, r2
    LDR     r3, =0x00000005
    ORR     r1, r1, r3
    STR     r1, [r0]

    // Set GPIO PA0-PA1 to Push-Pull Mode (0x0)
    LDR     r0, =GPIOA_OTYPER
    LDR     r1, [r0]
    LDR     r2, =0x00000003
    BIC     r1, r1, r2
    STR     r1, [r0]

    // Set GPIO PA0-PA1 to Slow Speed Mode (0x00)
    LDR     r0, =GPIOA_OSPEEDR
    LDR     r1, [r0]
    LDR     r2, =0x0000000F
    BIC     r1, r1, r2
    STR     r1, [r0]

    // Disable GPIO PA0-PA1 Internal Pull-up/Pull-down Resistors (0x00)
    LDR     r0, =GPIOA_PUPDR
    LDR     r1, [r0]
    LDR     r2, =0x0000000F
    BIC     r1, r1, r2
    STR     r1, [r0]

    BX      LR

.end
