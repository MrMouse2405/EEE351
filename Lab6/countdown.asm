extern nanosleep
extern printf
extern exit
default rel

section .data
    TimeSpec:
        tv_sec  dq 0
        tv_nsec dq 100000000          ; 100 ms

    ; prints: H T : O  (as you wrote: "%d%d:%d")
    TimerFormat db "%d%d:%d", 10, 0
    ExitString  db "Timer hit zero!", 10, 0

    StartTime   dd 99

section .text
    global main

main:
    ; Prologue: keep stack 16B-aligned for calls from main
    push rbp
    mov  rbp, rsp
    sub  rsp, 8

    mov  ebx, [StartTime]            ; counter = 999

.loop:
    ; EDI = counter
    mov  edi, ebx
    call extract                     ; EAX = 0xHH00TT00OO

    ; display(EAX)
    mov  edi, eax
    call display

    ; sleep ~100ms
    call delay100ms

    ; counter--
    sub  ebx, 1

    ; loop until zero
    test ebx, ebx
    jne  .loop

    ; print exit line
    lea  rdi, [ExitString]
    xor  eax, eax
    call printf

    add  rsp, 8

    ; exit(0)
    xor rdi, rdi ; status = 0
    call exit

    ret


; ---------------------------------------
; display: print packed decimal digits H,T,O
;   IN:  EDI = 0xHH00TT00OO
; ---------------------------------------
display:
    mov  eax, edi

    ; hundreds -> RSI
    mov  esi, eax
    shr  esi, 16
    and  esi, 0xFF

    ; tens -> RDX
    mov  edx, eax
    shr  edx, 8
    and  edx, 0xFF

    ; ones -> RCX
    and  eax, 0xFF
    mov  ecx, eax

    ; printf("%d%d:%d", H, T, O)
    lea  rdi, [TimerFormat]
    xor  eax, eax                    ; 0 float args
    call printf
    ret


; ---------------------------------------
; extract: pack decimal digits into bytes
;   IN:  EDI = N (>=0)
;   OUT: EAX = (H<<16) | (T<<8) | O
;   O -> zero's place, T -> Ten's place,
;   H -> hundred's place
; ---------------------------------------
extract:
    mov  eax, edi
    mov  ecx, 10

    ; O = N % 10
    xor  edx, edx
    div  ecx                ; EAX = N/10, EDX = N%10
    mov  r8d, edx           ; r8d = O

    ; T = (N/10) % 10
    xor  edx, edx
    div  ecx                ; EAX = N/100, EDX = T
    shl  edx, 8
    or   r8d, edx

    ; H = (N/100) % 10
    xor  edx, edx
    div  ecx                ; EAX = N/1000, EDX = H
    shl  edx, 16
    or   r8d, edx

    mov  eax, r8d
    ret


; ---------------------------------------
; delay100ms: nanosleep(&TimeSpec, NULL)
; ---------------------------------------
delay100ms:
    lea  rdi, [TimeSpec]
    xor  rsi, rsi
    call nanosleep
    ret
