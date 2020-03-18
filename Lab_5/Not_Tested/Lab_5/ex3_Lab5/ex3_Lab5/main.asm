;
; ex1_Lab5.asm
;
; Created: 12/10/2019 1:01:19 PM
; Author : superminiala
;


; Replace with your application code
; Begin of data segment
.DSEG 
;End of data segment start of code segment
.CSEG
#define counter           r16
#define voltage_high      r17
#define voltage_low       r18
#define voltage_high_temp r19
#define voltage_low_temp  r20  
#define rol_counter       r21
#define first_dot_number  r30
#define second_dot_number r31

.include "m16def.inc"
.org 0x00
rjmp reset
.org 0x1C
rjmp ADC_routine
reset:
	ldi r24,low(RAMEND)
	out spl,r24
	ldi r24,high(RAMEND)
	out sph,r24
	rcall usart_init
	rcall ADC_init
	ser r24
	out DDRB,r24
counter_reset:	
	ldi   counter,0
main:
    sei
	out  PORTB,counter
	ldi  r24,low(200)
	ldi  r25,high(200)
	rcall wait_msec
	inc  counter
	cpi  counter,255
	breq counter_reset
	jmp  main

 ADC_routine:
	push r25
	push r24
	ldi  r24,'I'
	rcall usart_transmit
	ldi first_dot_number,0
	ldi second_dot_number,0
	ldi voltage_low, ADCL ;0x73
	ldi voltage_high,ADCH ;0x01
 	mov voltage_high_temp,voltage_high
	mov voltage_low_temp,voltage_low
	clc 
	rol voltage_low
	rol voltage_high
	rol voltage_low
	rol voltage_high
	clc
	add voltage_low,voltage_low_temp
	adc voltage_high,voltage_high_temp
	ldi rol_counter,10
keep_rolling:
	clc  
	ror voltage_high
	ror voltage_low
	subi rol_counter,1
	cpi  rol_counter,2
	brne  not_yet_again
	sbrc  voltage_low,1
	ldi   second_dot_number,1
not_yet_again:
	cpi  rol_counter,1
	brne not_yet
	sbrc voltage_low,1
	ldi  first_dot_number,1
not_yet:
	cpi  rol_counter,0x00
	brne keep_rolling
	mov  r24, voltage_low
	ldi  r25, 0x30
	add  r24,r25
	rcall usart_transmit
	ldi  r24,'.'
	rcall usart_transmit
	ldi  r24,'7'
	sbrs first_dot_number,0
	ldi  r24,'0'
	rcall usart_transmit 
	ldi  r24, '5'
	sbrs second_dot_number,0
	ldi  r24, '0'
	rcall usart_transmit
	ldi  r24,'V'
	rcall usart_transmit
	ldi  r24,0x0D
	rcall usart_transmit
	pop r24
	pop r25
	reti

 ADC_init:
 ldi r24,(1<<REFS0) ; Vref: Vcc
 out ADMUX,r24 ;MUX4:0 = 00000 for A0.
 ;ADC is Enabled (ADEN=1)
 ;ADC Interrupts are Enabled (ADIE=1)
 ;Set Prescaler CK/128 = 62.5Khz (ADPS2:0=111)
 ;Isos thelei ena |(1 << ADCS)
 ldi r24,(1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
 out ADCSRA,r24
 ret

usart_init:
clr r24                              ; initialize UCSRA to zero
out UCSRA ,r24
ldi r24 ,(1<<RXEN) | (1<<TXEN)       ; activate transmitter/receiver
out UCSRB ,r24
ldi r24 ,0                           ; baud rate = 9600
out UBRRH ,r24
ldi r24 ,51
out UBRRL ,r24
ldi r24 ,(1 << URSEL) | (3 << UCSZ0) ; 8-bit character size,
out UCSRC ,r24                       ; 1 stop bit
ret

usart_transmit:
sbis UCSRA ,UDRE                     ; check if usart is ready to transmit
rjmp usart_transmit                  ; if no check again, else transmit
out UDR ,r24                         ; content of r24
ret

usart_receive:
sbis UCSRA ,RXC                      ; check if usart received byte
rjmp usart_receive                   ; if no check again, else read
in r24 ,UDR                          ; receive byte and place it in
ret                                  ; r24

wait_msec:
 push r24                            ; 2 cycles (0.250 microsec)
 push r25                            ; 2 cycles
 ldi r24 , low(998)                  ; load . r25:r24  998 (1 cycle - 0.125 microsec)
 ldi r25 , high(998)                 ; 1 cycle (0.125 microsec)
 rcall wait_usec                     ; 3 cycles (0.375 microsec), total_delay 998.375 microsec
 pop r25                             ; 2 cycles (0.250 microsec)
 pop r24                             ; 2 cycles
 sbiw r24 , 1                        ; 2 cycles
 brne wait_msec                      ; 1 or 2 cycles (0.125 or 0.250 microsec)
 ret                                 ; 4 cycles (0.500 microsec)

wait_usec:
sbiw r24 ,1                         ; 2 cycles (0.250 microsec)
nop                                 ; 1 cycle (0.125 microsec)
nop                                 ; 1 cycle (0.125 microsec)
nop                                 ; 1 cycle (0.125 microsec)
nop                                 ; 1 cycle (0.125 microsec)
brne wait_usec                      ; 1 or 2 cycles (0.125 or 0.250 microsec)
ret                                 ; 4 cycles (0.500 microsec)