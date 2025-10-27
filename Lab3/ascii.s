/********************************************************************************
* File: ascii_given.s
*
* Author: OCDT Syed & OCDT Tchameni Moko
*
* Description:
  The program processes a long string stored in read-only memory.
 It counts the number of capital letters using a loop that compares each character to ASCII values.
 It copies the original string into another memory area. After copying, it converts all lowercase letters to uppercase using ASCII arithmetic.
 These tasks are done through three subroutines: CapCount, Copy, and Convert.
 The result is stored in different memory sections and can be inspected during debugging.

*
* Revision History:
********************************************************************************/

        .syntax unified
        .global _start
        .thumb_func

/********EQUATES****************************************************************/
        .equ    CapA, 0x41 //'A'
        .equ    CapZ, 0x5A //'Z'
        .equ    MinA, 0x61 //'a'
        .equ    MinZ, 0x7A //'z'

/*******Global Constants********************************************************/
        .section .rodata
PBText:
    .ascii "Prince Humperdinck dove for his weapons, and a sword flashed in his thick hands."
	.ascii "To the death, he said, advancing."
	.ascii "Westley gave a soft shake of his head. No, he corrected. To the pain."
	.ascii "It was an odd phrase, and for the moment it brought the Prince up short."
	.ascii "I don't think I quite understand that."
	.ascii "I'm going to tell you something once and then whether you die is strictly up to you,"
	.ascii "Westley said, lying pleasantly on the bed."
	.ascii "What I'm going to tell you is this: drop your sword, and if you do, then I will leave"
	.ascii "with this baggage here -he glanced at Buttercup-"
	.ascii "and you will be tied up but not fatally, and will be free to go about your business."
	.ascii "And if you choose to fight, well, then, we will not both leave alive."
	.ascii "You are only alive now because you said 'to the pain.' I want that phrase explained."
	.ascii "My pleasure. To the pain means this: if we duel and you win, death for me."
	.ascii "If we duel and I win, life for you. But life on my terms. The first thing you lose will be your feet."
	.ascii "Below the ankle. You will have stumps available to use within six months."
	.ascii "Then your hands, at the wrists. They heal somewhat quicker. Five months is a fair average."
	.ascii "Next your nose. No smell of dawn for you. Followed by your tongue. Deeply cut away."
	.ascii "Not even a stump left. And then your left eye-"
	.ascii "And then my right eye, and then my ears, and shall we get on with it? the Prince said."
	.ascii "Wrong! Westley's voice rang across the room."
	.ascii "Your ears you keep, so that every shriek of every child shall be yours to cherish"
	.ascii "-every babe that weeps in fear at your approach, every woman that cries"
	.ascii "'Dear God, what is that thing?' will reverberate forever with your perfect ears."
	.ascii "That is what 'to the pain' means. It means that I leave you in anguish, in humiliation,"
	.ascii "in freakish misery until you can stand it no more: so there you have it, pig,"
	.ascii "there you know, you miserable vomitous mass, and I say this now, and live or die,"
	.ascii "it's up to you: Drop your sword!"
	.asciz "The sword crashed to the floor."
PBTextEnd:


/*******Global Variables*******************************************************/
        .section .data
NumCap:
      .space 4
NumCap2:
      .space 4
CloneString:
    .space (PBTextEnd-PBText)
CloneStringEnd:
CapitalString:
  .space (PBTextEnd-PBText)
CapitalStringEnd:
/*******Code Section***********************************************************/
        .text

_start:

        /*

          CapCount Demo

          Answer in NumCap

        */
        LDR r1,=PBText
        LDR r2,=PBTextEnd
        LDR r3,=NumCap
        BL CapCount


        /*

          Copy Demo

          Answer in CloneString -> CloneStringEnd

        */
        LDR r0,=PBText
        LDR r1,=PBTextEnd
        LDR r2,=CloneString
        LDR r3,=CloneStringEnd
        BL Copy


       /*

          Convert Demo

          Converted String in CapitalString -> CapitalStringEnd
          New Capital Characters Count in NumCap2

        */

        LDR r0,=PBText
        LDR r1,=PBTextEnd
        LDR r2,=CapitalString
        LDR r3,=CapitalStringEnd
        BL Copy

        LDR r0,=CapitalString
        LDR r1,=CapitalStringEnd
        BL Convert

        LDR r1,=CapitalString
        LDR r2,=CapitalStringEnd
        LDR r3,=NumCap2
        BL CapCount

        BKPT 1

/********************************************************************************
* Subroutine: Convert
*
* Description: Convert from lower case to upper case
*
* Notes:   R2 = Overwritten to hold characters
*
* Inputs:  R0 = Start Address, R1 = End Address
* Outputs: None
********************************************************************************/
Convert:
1:
        LDRB r2, [r0]

        // 'a' <= x < 'z'
        CMP r2, MinA-1 // BLS is LOWER & EQUAL TO
        BLS 2f
        CMP r2, MinZ
        BHI 2f
        SUB r2, MinA-CapA

2:
        STRB r2, [r0], 1
        //start != end, goto loop
        CMP r0,r1
        BNE 1b

        BX LR

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

/********************************************************************************
* Subroutine: CapCount
*
* Description: Code that counts the number of capital letters in a string
*
* Notes:    R0 = Overwritten to hold characters
            R4 = Overwritten to hold the count of capital letters
*
* Inputs:   R1 = Start Address, R2 = End Address, R3 = Result Address (4 bytes)
********************************************************************************/
CapCount:
1:
        LDRB r0, [r1], 1

        // 'A' <= x < 'Z'
        CMP r0, CapA-1 // BLS is LOWER & EQUAL TO
        BLS 2f
        CMP r0, CapZ
        BHI 2f
        ADD r4,r4,#1

2:      //start != end, goto loop
        CMP r1,r2
        BNE 1b

        STR r4, [r3]
        BX LR


/**************end****************************/
        .end
