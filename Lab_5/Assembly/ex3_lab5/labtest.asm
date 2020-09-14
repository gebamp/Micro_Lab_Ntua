.CSEG
.org 0x0
rjmp reset
.org 0x1C
rjmp ADC_int

.include "m16def.inc"


reset:
	ldi r24, low(RAMEND)
	out SPL, r24
	ldi r24, high(RAMEND)
	out SPH, r24 ; initialize the stack pointer
	rcall usart_init
	rcall ADC_init
	ser r24
	out DDRB,r24
	sei
	clr r22
	rjmp main

ADC_int:
	push r24
	push r25
	in r24 , ADCL
	in r25 , ADCH

	mov r26,r24
	mov r27,r25

	lsl r24
	rol r25
	lsl r24
	rol r25//2 shifts left = multiplication by 4

	add r24,r26 //add the initial value so we have a multiplication by 5
	adc r25,r27

	lsr r25
	ror r24
	lsr r25
	ror r24
	//r25 keeps the base
	//r26 keeps the floating point decimals
	ldi r28,50 //50 because 1/2=0.50, we will shift this to the right every loop so it will go from 0.50 to 0.25 to 0.12 etc
	ldi r29,6  //loop 6 times,50 has only 6 bits
	clr r26	
loop:
	sbrc r24,7
	add r26,r28
	lsl r24
	lsr r28
	dec r29
	brne loop

	mov r24,r25
	subi r24,-48
	rcall usart_transmit
	ldi r24,'.'
	rcall usart_transmit

	clr r16//r16 keeps the most significant floating point digit
			
loop2:	   //convert the hex to a two digit decimal
	cpi r26,10
	brlo finished
	subi r26,10
	inc r16
	rjmp loop2

finished:	//the remaining value in r26 is the least significat floating point digit
	mov r24,r16
	subi r24,-48
	rcall usart_transmit
	mov r24,r26
	subi r24,-48
	rcall usart_transmit

	ldi r24,(1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)|(1<<ADSC)
	out ADCSRA,r24

	ldi r24,'\n'
	rcall usart_transmit
	pop r25
	pop r24
	reti


main:
	cli
	ldi r24,low(200)
	ldi r25,high(200)
	rcall wait_msec
	inc r22
	out PORTB , r22
	sei
    rjmp main

	

	




























wait_msec:
	push r24 
	push r25 
	ldi r24 , low(998) 
	ldi r25 , high(998) 
	rcall wait_usec 
	pop r25 
	pop r24 
	sbiw r24 , 2 
	brne wait_msec 
	ret 
wait_usec:
	sbiw r24 ,1 ; 2 cycles (0.250 탎ec)
	nop ; 1 cycle (0.125 탎ec)
	nop
	nop ; 1 cycle (0.125 탎ec)
	nop ; 1 cycle (0.125 탎ec)
	nop ; 1 cycle (0.125 탎ec)
	brne wait_usec ; 1 cycle if false 2 if true (0.125 ? 0.250 탎ec)
	ret ; 4 cycles (0.500 탎ec)

; Routine: ADC_init
; Description:
; This routine initializes the
; ADC as shown below.
; ------- INITIALIZATIONS -------
;
; Vref: Vcc (5V for easyAVR6)
; Selected pin is A0
; ADC Interrupts are Enabled
; Prescaler is set as CK/128 = 62.5kHz
; --------------------------------
; parameters: None.
; return value: None.
; registers affected: r24
; routines called: None
 ADC_init:
 ldi r24,(1<<REFS0) ; Vref: Vcc
 out ADMUX,r24 ;MUX4:0 = 00000 for A0.
 ;ADC is Enabled (ADEN=1)
 ;ADC Interrupts are Enabled (ADIE=1)
 ;Set Prescaler CK/128 = 62.5Khz (ADPS2:0=111)
 ldi r24,(1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)|(1<<ADSC)
 out ADCSRA,r24
 ret


; Routine: usart_init
; Description:
; This routine initializes the
; usart as shown below.
; ------- INITIALIZATIONS -------
;
; Baud rate: 9600 (Fck= 8MH)
; Asynchronous mode
; Transmitter on
; Reciever on
; Communication parameters: 8 Data ,1 Stop , no Parity
; --------------------------------
; parameters: None.
; return value: None.
; registers affected: r24
; routines called: None
usart_init:
clr r24 ; initialize UCSRA to zero
out UCSRA ,r24
ldi r24 ,(1<<RXEN) | (1<<TXEN) ; activate transmitter/receiver
out UCSRB ,r24
ldi r24 ,0 ; baud rate = 9600
out UBRRH ,r24
ldi r24 ,51
out UBRRL ,r24
ldi r24 ,(1 << URSEL) | (3 << UCSZ0) ; 8-bit character size,
out UCSRC ,r24 ; 1 stop bit
ret

; Routine: usart_transmit
; Description:
; This routine sends a byte of data
; using usart.
; parameters:
; r24: the byte to be transmitted
; must be stored here.
; return value: None.
; registers affected: r24
; routines called: None.
usart_transmit:
sbis UCSRA ,UDRE ; check if usart is ready to transmit
rjmp usart_transmit ; if no check again, else transmit
out UDR ,r24 ; content of r24
ret

; Routine: usart_receive
; Description:
; This routine receives a byte of data
; from usart.
; parameters: None.
; return value: the received byte is
; returned in r24.
; registers affected: r24
; routines called: None.
usart_receive:
sbis UCSRA ,RXC ; check if usart received byte
rjmp usart_receive ; if no check again, else read
in r24 ,UDR ; receive byte and place it in
ret ; r24
