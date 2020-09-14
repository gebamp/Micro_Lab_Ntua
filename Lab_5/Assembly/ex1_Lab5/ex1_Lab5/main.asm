;
; ex1_Lab5.asm
;
; Created: 12/10/2019 1:01:19 PM
; Author : superminiala
;


; Replace with your application code
; Begin of data segment
.DSEG  
_string_storage_: .byte 60
;End of data segment start of code segment
.CSEG
#define string_input r16
.include "m16def.inc"
.org 0x00
rjmp reset
reset:
	ldi r24,low(RAMEND)
	out spl,r24
	ldi r24,high(RAMEND)
	out sph,r24
	rcall usart_init

main:
	rcall store_string
	rcall print_string
string_read:
	jmp  string_read


store_string:
    ldi r26,low(_string_storage_)
	ldi r27,high(_string_storage_)
	ldi string_input,'H'
	st  x+,string_input
	ldi string_input,'E'
	st  x+,string_input
	ldi string_input,'L'
	st  x+,string_input
	ldi string_input,'L'
	st  x+,string_input
	ldi string_input,'O'
	st  x+,string_input
	ldi string_input,' '
	st  x+,string_input
	ldi string_input,'W'
	st  x+,string_input
	ldi string_input,'O'
	st  x+,string_input
	ldi string_input,'R'
	st  x+,string_input
	ldi string_input,'L'
	st  x+,string_input
	ldi string_input,'D'
	st  x+,string_input
	ldi string_input,'!'
	st  x+,string_input
	ldi string_input,'\0'
	st  x,string_input
	ret

print_string:
    ldi r26,low(_string_storage_)
	ldi r27,high(_string_storage_)
while:
	ld    r24,X+
	rcall usart_transmit
	cpi   r24,'\0'
	breq  return
	jmp   while
return:
	ldi   r24,'\n'
	rcall usart_transmit
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