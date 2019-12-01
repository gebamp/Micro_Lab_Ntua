;
; ex1_asm.asm
;
; Created: 11/30/2019 7:11:55 PM
; Author : superminiala
;
; Replace with your application code
.include "m16def.inc"
#define temp_save r16
#define mon      r18
#define ten      r19
#define hundreds r20
#define sign     r21
.org  0x0
rjmp  reset  
reset:
  ldi r24,low(RAMEND)    ;Initialize stack pointer
  out SPL,r24
  ldi r24,high(RAMEND)  
  out SPH,r24
  ser r24
  out DDRB,r24
  clr r24
  rcall lcd_init
main:
	ldi sign,'+'
    rcall return_temp ;isos thelei mia allagi r24 se r25
	sbrs  r25,0
	ldi sign,'-'
	mov   temp_save,r24
	rcall get_digits
	ldi  r24,0x02
	rcall lcd_command
	cpi  hundreds,0x01
	breq its_getting_hot_in_here
so_take_off_all_your_clothes:
    mov  r24,ten
	ldi  r25,48
	add  r24,r25
	rcall lcd_data
	mov  r24,mon
	ldi  r25,48
	add  r24,r25
	rcall lcd_data
	ldi  r24,248
	rcall lcd_data
	ldi  r24,'C'
	rcall lcd_data
	rjmp main
its_getting_hot_in_here:
	mov r24,hundreds
	rcall lcd_data
	jmp so_take_off_all_your_clothes

get_digits:
	clr mon
	clr ten
	cld hundreds
	cpi sign,0x02D
	breq negative
flag:
	cpi r24,100
	brlo tenths
hund:
	ldi hundreds,1
	subi r24,0x64
tenths:
   cpi r24,0x0A
   brlo monads
   inc  ten
   subi r24,0x0A
   jmp tenths
monads:
   mov mon,r24
   ret
negative:
  com r24
  ldi r25,0x01
  add r24,r25
  jmp flag

return_temp:
rcall one_wire_reset
cpi   r24,0x00
breq  no_device
ldi   r24,0xCC
rcall one_wire_transmit_byte
ldi   r24,0x44
not_finished:
rcall one_wire_receive_bit
sbrs  r24,0
jmp   not_finished
rcall one_wire_reset
ldi   r24,0xCC
rcall one_wire_transmit_byte
ldi   r24,0xBE
rcall one_wire_transmit_byte
rcall one_wire_receive_byte
mov   r25,r24  ;isos auto thelei alagi  sthn epomenh ekana thn upothesi oti prwta stelnei sign kai meta stelnei to noumero
rcall one_wire_receive_byte
lsr   r24
no_device:
  ldi r24,low(0x8000)
  ldi r25,high(0x8000)

ret

one_wire_receive_byte:
ldi r27 ,8
clr r26
loop_:
rcall one_wire_receive_bit
lsr r26
sbrc r24 ,0
ldi r24 ,0x80
or r26 ,r24
dec r27
brne loop_
mov r24 ,r26
ret

one_wire_receive_bit:
sbi DDRA ,PA4
cbi PORTA ,PA4 ; generate time slot
ldi r24 ,0x02
ldi r25 ,0x00
rcall wait_usec
cbi DDRA ,PA4 ; release the line
cbi PORTA ,PA4
ldi r24 ,10
; wait 10 ?s
ldi r25 ,0
rcall wait_usec
clr r24
; sample the line
sbic PINA ,PA4
ldi r24 ,1
push r24
ldi r24 ,49
; delay 49 ?s to meet the standards
ldi r25 ,0
; for a minimum of 60 ?sec time slot
rcall wait_usec ; and a minimum of 1 ?sec recovery time
pop r24
ret

one_wire_transmit_byte:
mov r26 ,r24
ldi r27 ,8
_one_more_:
clr r24
sbrc r26 ,0
ldi r24 ,0x01
rcall one_wire_transmit_bit
lsr r26
dec r27
brne _one_more_
ret

one_wire_transmit_bit:
push r24
; save r24
sbi DDRA ,PA4
cbi PORTA ,PA4 ; generate time slot
ldi r24 ,0x02
ldi r25 ,0x00
rcall wait_usec
pop r24
; output bit
sbrc r24 ,0
sbi PORTA ,PA4
sbrs r24 ,0
cbi PORTA ,PA4
ldi r24 ,58
; wait 58 ?sec for the
ldi r25 ,0
; device to sample the line
rcall wait_usec
cbi DDRA ,PA4 ; recovery time
cbi PORTA ,PA4
ldi r24 ,0x01
ldi r25 ,0x00
rcall wait_usec
ret

one_wire_reset:
sbi DDRA ,PA4 ; PA4 configured for output
cbi PORTA ,PA4 ; 480 ?sec reset pulse
ldi r24 ,low(480)
ldi r25 ,high(480)
rcall wait_usec
cbi DDRA ,PA4 ; PA4 configured for input
cbi PORTA ,PA4
ldi r24 ,100
; wait 100 ?sec for devices
ldi r25 ,0
; to transmit the presence pulse
rcall wait_usec
in r24 ,PINA ; sample the line
push r24
ldi r24 ,low(380) ; wait for 380 ?sec
ldi r25 ,high(380)
rcall wait_usec
pop r25
clr r24
sbrs r25 ,PA4
ldi r24 ,0x01
ret

lcd_init:
 ldi r24 ,40       ; Otan o elektis trofodotite me revma
 ldi r25 ,0        ; o elekths ektelei diki tou arxikopoihsh
 rcall wait_msec   ; wait 40msec until it is over
 ldi r24 ,0x30     ; go into 8 bit mode
 out PORTD ,r24    ; send instruction 2 times in order to make sure
 sbi PORTD ,PD3    ; 
 cbi PORTD ,PD3    ; 
 ldi r24 ,39
 ldi r25 ,0        ; an eimaste idi se 8 bit mode tote no change
 rcall wait_usec   ; an eimaste se 4bit mode tote change
 ldi r24 ,0x30
 out PORTD ,r24
 sbi PORTD ,PD3
 cbi PORTD ,PD3
 ldi r24 ,39
 ldi r25 ,0
 rcall wait_usec
 ldi r24 ,0x20     ; change to 4 bit mode
 out PORTD ,r24
 sbi PORTD ,PD3
 cbi PORTD ,PD3
 ldi r24 ,39
 ldi r25 ,0
 rcall wait_usec
 ldi r24 ,0x28     ; choose charcters 5*8 dots
 rcall lcd_command ; show 2 lines in screen
 ldi r24 ,0x0c     ; activate lcd hide cursor
 rcall lcd_command
 ldi r24 ,0x01     ; clear lcd
 rcall lcd_command
 ldi r24 ,low(1530)
 ldi r25 ,high(1530)
 rcall wait_usec
 ldi r24 ,0x06     
 rcall lcd_command 
 ret
write_2_nibbles:
 push r24        
 in r25 ,PIND     
 andi r25 ,0x0f   
 andi r24 ,0xf0   
 add r24 ,r25     
 out PORTD ,r24   
 sbi PORTD ,PD3   
 cbi PORTD ,PD3   
 pop r24         
 swap r24        
 andi r24 ,0xf0   
 add r24 ,r25
 out PORTD ,r24
 sbi PORTD ,PD3  
 cbi PORTD ,PD3
 ret

lcd_data:
 sbi PORTD ,PD2  
 rcall write_2_nibbles 
 ldi r24 ,43      
 ldi r25 ,0      
 rcall wait_usec
 ret
lcd_command:
 cbi PORTD ,PD2         
 rcall write_2_nibbles  
 ldi r24 ,39            
 ldi r25 ,0             
 rcall wait_usec        
 ret

wait_msec:
 push r24           ; 2 cycles (0.250 microsec)
 push r25           ; 2 cycles
 ldi r24 , low(998) ; load r25:r24 with  998 (1 cycle - 0.125 microsec)
 ldi r25 , high(998); 1 cycles (0.125 ìsec)
 rcall wait_usec    ; 3 cycles (0.375 ìsec), causes delay of 998.375 microsec
 pop r25            ; 2 cycles (0.250 ìsec)
 pop r24            ; 2 cycles
 sbiw r24 , 1       ; 2 cycles
 brne wait_msec     ; 1 or 2 cycles (0.125 or 0.250 microsec)
 ret                ; 4 cycles (0.500 ìsec)
wait_usec:
	sbiw r24 ,1     ; 2 cycles (0.250 µsec)
	nop             ; 1 cycle (0.125 µsec)
	nop
	nop             ; 1 cycle (0.125 µsec)
	nop             ; 1 cycle (0.125 µsec)
	nop             ; 1 cycle (0.125 µsec)
	brne wait_usec  ; 1 cycle if false 2 if true (0.125 or 0.250 µsec)
	ret             ; 4 cycles (0.500 µsec)