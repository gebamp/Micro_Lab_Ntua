;
; ex1_lab2.asm
;
; Created: 25/10/2019 12:48:58 pµ
; Author : Superminiala
;


; Replace with your application code
.include "m16def.inc"
.org  0x0
rjmp  reset
.org  0x04
rjmp  ISR1
.def  counter = r16
.def  intr_counter =r17
reset:
  ldi r24,low(RAMEND)           ;Initialize stack pointer
  out SPL,r24
  ldi r24,high(RAMEND)  
  out SPH,r24
  
  ldi r24,(1<<ISC11 | 1<<ISC10) ;set intr_1 on rising_edge 
  out MCUCR,r24                 
  
  ldi r24,(1<<INT1)             ;Enable interupt 1
  out GICR,r24  
  sei

  ser r24                       ;Initialize port_b,a for output
  out DDRB,r24                  ;Initialize port_d for input
  out DDRA,r24
  clr r24
  out DDRD,r24
  clr counter
  clr intr_counter
main:
    out   Portb,counter         ;Main program counts from 0 to 255 
 	rcall wait_200ms            ;Routine call for 200ms delay
    inc   counter
	cpi   counter,255
	brne  main
	clr   counter
	jmp   main


ISR1:
debounce:
	ldi   r18,(1<<INTF1)       ;The following part of the code Checks for the debounce effect
	out   GIFR,r18             ;If bit7=0 then continue with interupt service
                               ;Else keep looping
    ldi   r27,52               
    ldi   r28,242
delay:                         ;Delay for 5msec
	dec  r28
    brne delay
    dec  r27
    brne delay
    nop

    in    r19,GIFR
	sbrc  r19,7
	jmp   debounce
    
	in    r26,pind             ;Checks PD7 if it is set if it is then increment intr_counter by 1
	sbrc  r26,7                ;else skip the inc command and just  print the intr_counter in portA
    inc   intr_counter
    out   porta,intr_counter	
	
	reti




wait_200ms:
	ldi  r29, 9
    ldi  r30, 30
    ldi  r31, 229
L1: 
	dec  r31
    brne L1
    dec  r30
    brne L1
    dec  r29
    brne L1
    nop
	ret
