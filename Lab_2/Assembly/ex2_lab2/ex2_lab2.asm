;
; ex2_lab2.asm
;
; Created: 25/10/2019 12:53:18 pµ
; Author : Superminiala
;


; Replace with your application code
.include "m16def.inc"
.org  0x0
rjmp  reset
.org  0x02
rjmp  ISR0
.def  counter  = r16
.def  leds_in  = r17
.def  ones_in  = r19 
.def  leds_out = r20
.def  ones_out = r21  
.def  or_setter = r22
reset:
  ldi r24,low(RAMEND)           ;Initialize stack pointer
  out SPL,r24
  ldi r24,high(RAMEND)  
  out SPH,r24
  
  ldi r24,(1<<ISC01 | 1<<ISC00) ;set intr_0 on rising_edge 
  out MCUCR,r24                 
  
  ldi r24,(1<<INT0)              ;Enable interupt 0
  out GICR,r24  
  sei

  ser  r24                       ;Initialize port_b,c for output
  out  DDRB,r24                  ;Initialize port_a,d for input
  out  DDRC,r24
  clr  r24
  out  DDRA,r24
  out  DDRD,r24

  clr counter                    ;Reset Everything
  clr leds_in
  clr ones_in
  clr leds_out
  clr ones_out

main:
    out   Portb,counter          ;Counter program same as ex1
    rcall wait_200ms
    inc   counter
    cpi   counter,255
    brne  main
    clr   counter
    jmp   main


ISR0:       
	debounce:                  ;Same concept as the debounce of the previous 
	ldi   r18,(1<<INTF0)       ;exercise but uses the 6th bit instead of the 
	out   GIFR,r18             ;7th bit since it is the intr_0 and not intr_1

    ldi   r30,52
    ldi   r31,242
delay: 
	dec  r31
    brne delay
    dec  r30
    brne delay
    nop

    in    r29,GIFR
	sbrc  r29,6
	jmp   debounce

    in    leds_in,pina       
	ldi   ones_in,8         
	ldi   or_setter,1       ;and store the total number of ones to print in ones_out
	clr   ones_out
	clr   leds_out
get_one:
    sbrc  leds_in,0         ;Gets the  total  number of ones in pinA
	inc   ones_out          ;Just a simple counter program checks everything
	lsr   leds_in           ;and store the total number of ones to print in ones_out
	dec   ones_in
	brne  get_one
	tst   ones_out
	breq  print_output
put_one:                    ;Sets the apropriate amount of ones in the coresponding position from lsb to msb
    or    leds_out,or_setter
	lsl   or_setter
	dec   ones_out
	cpi   ones_out,0
	brne  put_one
print_output:
	out   portc,leds_out    ;Prints the output in portc
		
	reti





wait_200ms:
	ldi  r24, 9
    ldi  r25, 30
    ldi  r26, 229
L1: 
	dec  r26
    brne L1
    dec  r25
    brne L1
    dec  r24
    brne L1
    nop
	ret

