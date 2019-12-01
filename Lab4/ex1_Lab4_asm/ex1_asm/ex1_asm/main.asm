;
; ex1_asm.asm
;
; Created: 11/30/2019 7:11:55 PM
; Author : superminiala
;
; Replace with your application code
.include "m16def.inc"
.org  0x0
rjmp  reset  
reset:
  ldi r24,low(RAMEND)    ;Initialize stack pointer
  out SPL,r24
  ldi r24,high(RAMEND)  
  out SPH,r24
  ser r24
  out DDRB,r24
main:
    rcall return_temp
	out   PORTB,r24
    rjmp main



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