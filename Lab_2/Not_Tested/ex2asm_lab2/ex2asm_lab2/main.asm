;
; ex2asm_lab2.asm
;
; Created: 25/10/2019 12:35:19 πμ
; Author : Superminiala
;


; Replace with your application code
.include "m16def.inc"
.org  0x0
rjmp  reset
.org  0x04
rjmp  ISR1
.org  0x10
rjmp  ISR_TIMER1_OVF

.def input  = r16
.def output = r17
.def interupt_clr = r18
.def timer_init   = r19
.def is_already_on =r20
.def deb_mask = r21
.def deb_mask_2 = r22

reset:
  ldi r24,low(RAMEND)           ;Initialize stack pointer
  out SPL,r24
  ldi r24,high(RAMEND)  
  out SPH,r24
  
  ldi r24,(1<<ISC11 | 1<<ISC10) ;set intr_1 on rising_edge 
  out MCUCR,r24                 
  clr r24  
  
  ldi r24,(1<<INT1)             ;Enable interupt 1
  out GICR,r24  
  clr r24
  
  ldi r24,(1<<TOIE1)            ;Enable timer interupts
  out TIMSK,r24
  clr r24

  ldi r24,(1<<CS12)|(0<<CS11)|(1<<CS10) ;Set interval of increment of timer ck/1024
  out TCCR1B,r24

  sei
 
  
  ser r24                       ;Initialise port_b for output
  out DDRB,r24                  
  clr r24 
  out DDRA,r24                  ;Initialise port_a for input
  clr is_already_on
main:
  in   input,PINA               ;Read Input from pina
  sbrs input,7                  ;if PA7 = 1 continue else keep spining
  jmp  main
restore:                        ;Keeps reading until PA7 is reset
  in   input,PINA
  cpi  input,0x80
  breq restore

  in   is_already_on,portb      ;Checks input if found on then we need do turn on all 
  sbrc is_already_on,0          ;the leds if not then we just need to  turn it on now
  jmp  found_it_on

  ldi timer_init,0x85           ;Sets initial value to count 4 secs 
  out TCNT1H,timer_init
  ldi timer_init,0x26
  out TCNT1L,timer_init
  
  ldi  output,0x01              ;Turns on led PB00
  out  portb,output
  jmp  main
found_it_on:
   
  ldi  output,0xFF              ;If  the led was already on turn on all the PB leds
  out  portb,output             ;for 0.5 seconds and reset the counter of the timer interupt
  call delay_500ms
  
  ldi  timer_init,0x85
  out  TCNT1H,timer_init
  ldi  timer_init,0x26
  out  TCNT1L,timer_init

  ldi  output,0x01              ;Turn on led PB00
  out  portb,output
  jmp  main


ISR1:
    

debounce:                       ;Debounce mechanism
	ldi   deb_mask,(1<<INTF1)
	out   GIFR,deb_mask

	ldi   r24,52
    ldi   r25,242
delay:                          ;Delay of 5ms for debounce
	dec  r25
    brne delay
    dec  r24
    brne delay
    nop

    in    deb_mask_2,GIFR
	sbrc  deb_mask_2,7
	jmp   debounce
 
    in    is_already_on,portb   ;Checks if led is already on
	sbrc  is_already_on,0       ;if it is then  do the same thing as before
	jmp   found_it_on_inside_intr


    ldi timer_init,0x85         ;Set timer for interupt
    out TCNT1H,timer_init
    ldi timer_init,0x26
    out TCNT1L,timer_init
  
    ldi  output,0x01            ;Turn on led PB00
    out  portb,output
    reti

found_it_on_inside_intr:        ;If the led was already on
    ldi  output,0xFF            ;Blink all leds for 0.5 seconds
    out  portb,output

    ldi  r23, 21                ;delay for 0.5 seconds
    ldi  r26, 75
    ldi  r27, 191
delay_2:
    dec  r27
    brne delay_2
    dec  r26
    brne delay_2
    dec  r23
    brne delay_2
    nop

    
    ldi  timer_init,0x85       ;Reset interupt timer
    out  TCNT1H,timer_init
    ldi  timer_init,0x26
    out  TCNT1L,timer_init

	ldi output,0x01            ;Turn on led PB00
	out portb,output
			
	reti

ISR_TIMER1_OVF:
    clr interupt_clr          ;Turns off the led
	out Portb,interupt_clr
    reti

delay_500ms:
    
    ldi  r28, 21
    ldi  r29, 75
    ldi  r30, 191
L1: dec  r30
    brne L1
    dec  r29
    brne L1
    dec  r28
    brne L1
    nop

    ret
