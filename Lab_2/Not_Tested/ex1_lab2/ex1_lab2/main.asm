;
; ex1_lab2.asm
;
; Created: 25/10/2019 12:48:58 πμ
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

  ser r24                       ;Initialize port_b,c for output
  out DDRB,r24                  ;Initialize port_d for input
  out DDRA,r24
  clr r24
  in  r24,DDRD
  clr counter
  clr intr_counter
main:
    out   Portb,counter
	rcall wait_200ms
    inc   counter
	cpi   counter,255
	brne  main
	clr   counter
	jmp   main


ISR1:
debounce:
	ldi   r18,(1<<INTF1)
	out   GIFR,r18
    ldi   r24,52
    ldi   r25,242
delay: 
	dec  r25
    brne delay
    dec  r24
    brne delay
    nop

    in    r19,GIFR
	sbrc  r19,7
	jmp   debounce

    inc   intr_counter
	in    r26,pind
	sbrc  r26,7
    out   porta,intr_counter	
	
	reti




wait_200ms:
	ldi  r18, 9
    ldi  r19, 30
    ldi  r20, 229
L1: 
	dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    nop
	ret
