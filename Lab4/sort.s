/********************************************************************************
* File: sort.s
*
* Author: OCdt Tchameni Moko & OCdt Syed
*
* Description: Implements BubbleSort
*
* Revision History: 
********************************************************************************/ 
        .syntax unified
        .global _start
        .include "EEE351.inc"
/*******EQUATES*****************************************************************/
        .equ ListEndMarker, 0xFF

/*******Global Constants********************************************************/
        .section    .rodata
NewList:
        .byte       71, 87, 87, 11, 51, 67, 41, 100 
        .byte       51, 0, 77, 52, 11, 14, 55, 56
        .byte       99, 92, 54, 56, 64, 2, 51, 9
        .byte       0xFF
        
EmptyList:
        .byte       0xFF
        
OneList:
        .byte       127, 0xFF

PreList:
        .byte       0, 1, 2, 3, 4, 5, 6, 6, 6, 6, 9, 10, 0xFF

WorstList:
        .byte       15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 0xFF

EndList:       

/*******Global Variables********************************************************/
        .section    .data
NewListSorted:
          .space (EmptyList-NewList)
EmptyListSorted:
          .space (OneList-EmptyList)
OneListSorted:
          .space (PreList-OneList)
PreListSorted:
          .space (WorstList-PreList)
WorstListSorted:
          .space (EndList-WorstList)
EndListSorted:

/*******Code Section************************************************************/
        .section    .text
        .thumb_func
_start:

        /*
        
            Copy all lists from ROM to RAM
        
        */  
        LDR r0,=NewList
        LDR r1,=EndList
        LDR r2,=NewListSorted
        LDR r3,=EndListSorted
        BL Copy

        /*
        
          BubbleSort NewList

          Answer in NewListSorted
        
        */  

        LDR r0,=NewListSorted
        BL BubbleSort

        /*
        
          BubbleSort EmptyList

          Answer in EmptyListSorted
        
        */  

        LDR r0,=EmptyListSorted
        BL BubbleSort

        /*
        
          BubbleSort OneList

          Answer in OneListSorted
        
        */  

        LDR r0,=OneListSorted
        BL BubbleSort

        /*
        
          BubbleSort PreList

          Answer in PreListSorted
        
        */  

        LDR r0,=PreListSorted
        BL BubbleSort

        /*
        
          BubbleSort WorstList

          Answer in WorstListSorted
        
        */  
        LDR r0,=WorstListSorted
        BL BubbleSort

        BKPT        1        

/********************************************************************************
* Subroutine: BubbleSort
*
* Description: Sorts an array of bytes in ascending order using Bubble Sort.
*              The array is terminated by a special value called ListEndMarker.
*
* Notes:   
*          r0 - Base address of the array
*          r1 - Current pointer during iteration
*          r2 - Swap flag (1 if any swap happened during the pass, 0 otherwise)
*          r3 - Current element (i)
*          r4 - Next element (j)
*
* Inputs:  R0 = Start Address of array (byte values), terminated by ListEndMarker
* Outputs: None (in-place sort)
********************************************************************************/ 
BubbleSort:
0:
       MOV r1, r0           // r1 to point to start of array
       MOV r2, #0           // Clear swap flag before each pass

1:
       LDRB r3, [r1]        // Load current byte (i) into r3
       CMP  r3, ListEndMarker
       BEQ  3f              

       LDRB r4, [r1, #1]    // Load next byte (j) into r4
       CMP  r4, ListEndMarker
       BEQ  3f              

       CMP r3, r4           // Compare current and next elements
       BLS 2f               // If in order (r3 <= r4), skip swap

       // Swap r3 and r4
       STRB r3, [r1, #1]    // Store r3 (current) into next position
       STRB r4, [r1]        // Store r4 (next) into current position
       MOV  r2, #1          // Set swap flag

2:
       ADD r1, r1, #1       // Move to next pair in the array
       B 1b                 // Repeat pass

3:
       CMP r2, #0           // Check if any swap occurred
       BNE 0b               // If swaps happened, repeat the sort pass

       BX LR                // Return from subroutine (done sorting)




/********************************************************************************
* Subroutine: Copy
*
* Description: Code that copies data from one location to another
*
* Notes:    R4 = Overwritten to hold Characters
*           Copying ends as soon as one of the end addresses is reached IOT protect data.
*
* Inputs:   R0 = Source Start Address, R1 = Source End Address, 
*           R2 = Destination Start Address, R3 = Destination End Address
* Outputs:  None
********************************************************************************/ 
Copy:
1:
        // destination start > end then stop
        CMP r2,r3
        BHI 2f

        // source start > end, then loop
        CMP r0,r1
        BHI 2f

        LDRB r4, [r0], 1
        STRB r4, [r2], 1
        B 1b
2:
        BX LR

        .end