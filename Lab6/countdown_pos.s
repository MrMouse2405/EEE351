/********************************************************************************
* File: 
*
* Author:
*
* Description:
*
* Revision History: 
********************************************************************************/ 

        .syntax unified
        .global _start
        .include "EEE351.inc"
/*******EQUATES*****************************************************************/
        .equ        START_10s,   0x09
        .equ        START_1s,    0x09
        .equ        START_10ths, 0x09
        .equ        DELAY,       ???

/*******Global Constants********************************************************/
        .section    .rodata     


/*******Global Variables********************************************************/
        .section    .data


/*******Code Section************************************************************/
        .section    .text
        .thumb_func
_start:
        MOV r0, r0


        BKPT        1


/********************************************************************************
* Subroutine: delay100ms
*
* Description: This subroutine causes a blocking delay of approximately 100ms
*
* Notes: R5 is modifed for this subroutine.
*        The inner loop is approximately 4 cycles
*        The default clock speed is 16Mhz
*
* Inputs: None
*
* Outputs: None
********************************************************************************/
delay100ms:        
        LDR         R5, =DELAY        
delay:                                
        CBZ         R5, endDelay   // 1 Cycle when no branch is taken     
        SUB         R5, R5, #1     // 1 Cycle
        B           delay          // 1 + P Cycles where P depends on the branch distance
endDelay:                          // P = 1 with a small relative branch
        BX LR
                
/********************************************************************************
* Subroutine: initializeGPIOs
*
* Description: This subroutine is where GPIO ports A, B & C are initialized.
*              Output Mode - Open-Drain Mode - Slow Speed - No Internal Resistors
*
* Notes: R1 & R0 are modifed in this subroutine for register addresses and values.
*
* Inputs: None
*
* Outputs: None
********************************************************************************/
initializeGPIOs:
                                                    // Enable GPIOs B & C




                                                    // Set GPIO PB7-PB0 to Output Mode (0x01)

                                                    


                                                    // Set GPIO PC3-PC0 to Output Mode (0x01)




                                                    // Set GPIO PB7-PB0 to Push-Pull Mode (0x0)




                                                    // Set GPIO PC3-PC0 to Push-Pull Mode (0x0)




                                                    // Set GPIO PB7-PB0 to Slow Speed Mode (0x00)




                                                    // Set GPIO PC3-PC0 to Slow Speed Mode (0x00)




                                                    // Disable GPIO PB7-PB0 Internal Pull-up/Pull-down Resistors (0x00)




                                                    // Disable GPIO PC3-PC0 Internal Pull-up/Pull-down Resistors (0x00)


        BX LR
	


	.end