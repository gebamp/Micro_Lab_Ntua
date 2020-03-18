
; Replace with your application code
; ---- ���� �������� ���������
.nolist
.include "m16def.inc"
.list
.DSEG
 _tmp_: .byte 2
; ---- ����� �������� ���������
.CSEG
.include "m16def.inc"
#define input1   r16
#define input2   r17
#define mon      r18
#define ten      r19
#define hundreds r20
#define sign     r21
.org  0x0
rjmp   reset

reset:
  ldi r24,low(RAMEND)          ;Initialize stack pointer
  out SPL,r24
  ldi r24,high(RAMEND)  
  out SPH,r24
  ser r24
  out DDRD,r24
  out DDRA,r24
  clr r24
  ldi r24,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4) 
  out DDRC,r24                 ;Set the 4 msb as output
  rcall lcd_init
main: 
  clr r24                      ; clear r24
  ldi   r24,0x0A               ; insert debounce_delay
  rcall scan_keypad_rising_edge; call keypad scan routine
  mov   r30,r24                ; save input in r21,r22
  mov   r31,r25
  rcall keypad_to_ascii        ; convert to ascii
  cpi   r24,0x00               ; chehck if something was pressed
  breq  main                          
  mov   input1,r24             ; input1 is the first hex digit
pressed_first:
  ldi   r24,0x0A               
  rcall scan_keypad_rising_edge
  mov   r28,r24                ; save input2 in r28,r29
  mov   r29,r25
  rcall keypad_to_ascii        ; convert to ascii
  cpi   r24,0x00
  breq  pressed_first
  mov   input2,r24
  clr   r24
  ; ldi r24,0x01
  ; rcal lcd_command
  ; clr r24
  rcall lcd_init               ; init display
  mov   r24,input1             ; print ascii value of input1
  rcall lcd_data
  mov   r24,input2             ; print ascii value of input2
  rcall lcd_data               ; print =
  ldi   r24,'=' 
  rcall lcd_data               
  mov   r24,r30                ; restore input1
  mov   r25,r31
  rcall keypad_to_hex          ; convert to hex value
  mov   input1,r24             
  mov   r24,r28                ; restore input2
  mov   r25,r29
  rcall keypad_to_hex          ; convert to hex value 
  mov   input2,r24         
  lsl   input1                 ; join the 2 values 
  lsl   input1
  lsl   input1
  lsl   input1
  or    input1,input2          
  mov   r24,input1 
  rcall get_digits             ; get digits
  mov   r24,sign
  rcall lcd_data               ; print sign
  mov   r24,hundreds           ; get hundreds and convert the to their ascii value
  ldi   r25,48
  add   r24,r25
  rcall lcd_data               ; print hundreds
  mov   r24,ten                ; get hundreds and convert the to their ascii value
  ldi   r25,48  
  add   r24,r25
  rcall lcd_data               ; print tens
  mov   r24,mon                ; get monads and convert the to their ascii value
  ldi   r25,48
  add   r24,r25
  rcall lcd_data               ; print monads
end:  
  jmp main


get_digits:
  ldi  sign,'+'
  sbrc r24,7
  ldi  sign,'-'
  clr mon
  clr ten
  clr hundreds
  cpi sign,0x2D
  breq negative
flag:
  cpi  r24,100
  brlo tenths
hund:
  ldi  hundreds,1    
  subi r24,0x64
tenths:
  cpi  r24,0x0A
  brlo monads
  inc  ten
  subi r24,0x0A
  jmp tenths
monads: 
  mov  mon,r24
  ret
negative:
  com  r24
  ldi  r25,0x01
  add  r24,r25
  jmp  flag




lcd_init:
ldi r24 ,40       ; ���� � �������� ��� lcd ������������� ��
ldi r25 ,0        ; ����� ������� ��� ���� ��� ������������.
rcall wait_msec   ; ������� 40 msec ����� ���� �� �����������.
ldi r24 ,0x30     ; ������ ��������� �� 8 bit mode
out PORTD ,r24    ; ������ ��� �������� �� ������� �������
sbi PORTD ,PD3    ; ��� �� ���������� ������� ��� �������
cbi PORTD ,PD3    ; ��� ������, � ������ ������������ ��� �����
ldi r24 ,39
ldi r25 ,0        ; ��� � �������� ��� ������ ��������� �� 8-bit mode
rcall wait_usec   ; ��� �� ������ ������, ���� �� � �������� ���� ����������
                  ; ������� 4 bit �� ������� �� ���������� 8 bit
ldi r24 ,0x30
out PORTD ,r24
sbi PORTD ,PD3
cbi PORTD ,PD3
ldi r24 ,39
ldi r25 ,0
rcall wait_usec
ldi r24 ,0x20     ; ������ �� 4-bit mode
out PORTD ,r24
sbi PORTD ,PD3
cbi PORTD ,PD3
ldi r24 ,39
ldi r25 ,0
rcall wait_usec
ldi r24 ,0x28     ; ������� ���������� �������� 5x8 ��������
rcall lcd_command ; ��� �������� ��� ������� ���� �����
ldi r24 ,0x0c     ; ������������ ��� ������, �������� ��� �������
rcall lcd_command
ldi r24 ,0x01     ; ���������� ��� ������
rcall lcd_command
ldi r24 ,low(1530)
ldi r25 ,high(1530)
rcall wait_usec
ldi r24 ,0x06     ; ������������ ��������� ������� ���� 1 ��� ����������
rcall lcd_command ; ��� ����� ������������ ���� ������� ����������� ���
                  ; �������������� ��� ��������� ��������� ��� ������
ret


write_2_nibbles:
push r24         ; ������� �� 4 MSB
in r25 ,PIND     ; ����������� �� 4 LSB ��� �� �������������
andi r25 ,0x0f   ; ��� �� ��� ��������� ��� ����� ����������� ���������
andi r24 ,0xf0   ; ������������� �� 4 MSB ���
add r24 ,r25     ; ������������ �� �� ������������ 4 LSB
out PORTD ,r24   ; ��� �������� ���� �����
sbi PORTD ,PD3   ; ������������� ������ Enable ���� ��������� PD3
cbi PORTD ,PD3   ; PD3=1 ��� ���� PD3=0
pop r24          ; ������� �� 4 LSB. ��������� �� byte.
swap r24         ; ������������� �� 4 MSB �� �� 4 LSB
andi r24 ,0xf0   ; ��� �� ��� ����� ���� �������������
add r24 ,r25
out PORTD ,r24
sbi PORTD ,PD3   ; ���� ������ Enable
cbi PORTD ,PD3
ret

lcd_data:
sbi PORTD ,PD2   ; ������� ��� ���������� ��������� (PD2=1)
rcall write_2_nibbles ; �������� ��� byte
ldi r24 ,43      ; ������� 43�sec ����� �� ����������� � ����
ldi r25 ,0       ; ��� ��������� ��� ��� ������� ��� lcd
rcall wait_usec
ret

lcd_command:
cbi PORTD ,PD2         ; ������� ��� ���������� ������� (PD2=1)
rcall write_2_nibbles  ; �������� ��� ������� ��� ������� 39�sec
ldi r24 ,39            ; ��� ��� ���������� ��� ��������� ��� ��� ��� ������� ��� lcd.
ldi r25 ,0             ; ���.: �������� ��� �������, �� clear display ��� return home,
rcall wait_usec        ; ��� �������� ��������� ���������� ������� ��������.
ret

scan_keypad_rising_edge:
  mov r22 ,r24         ; ���������� �� ����� ������������ ���� r22
  rcall scan_keypad    ; ������ �� ������������ ��� ���������� ���������
  push r24             ; ��� ���������� �� ����������
  push r25
  mov r24 ,r22         ; ����������� r22 ms (������� ����� 10-20 msec ��� ����������� ��� ���
  ldi r25 ,0           ; ������������ ��� ������������� � ������������� ������������)
  rcall wait_msec
  rcall scan_keypad    ; ������ �� ������������ ���� ��� ��������
  pop r23              ; ��� ������� ���������� �����������
  pop r22
  and r24 ,r22
  and r25 ,r23
  ldi r26 ,low(_tmp_)  ; ������� ��� ��������� ��� ��������� ����
  ldi r27 ,high(_tmp_) ; ����������� ����� ��� �������� ����� r27:r26
  ld r23 ,X+
  ld r22 ,X
  st X ,r24            ; ���������� ��� RAM �� ��� ���������
  st -X ,r25           ; ��� ���������
  com r23
  com r22              ; ���� ���� ��������� ��� ����� ������ �������
  and r24 ,r22
  and r25 ,r23
  ret


scan_row:
  ldi r25 , 0x08       ; ������������ �� �0000 1000�
  back: lsl r25        ; �������� �������� ��� �1� ����� ������
  dec r24              ; ���� ����� � ������� ��� �������
  brne back
  out PORTC , r25      ; � ���������� ������ ������� ��� ������ �1�
  nop
  nop                  ; ����������� ��� �� �������� �� ����� � ������ ����������
  in r24 , PINC        ; ����������� �� ������ (������) ��� ��������� ��� ����� ���������
  andi r24 ,0x0f       ; ������������� �� 4 LSB ���� �� �1� �������� ��� ����� ���������
  ret                  ; �� ���������.




scan_keypad:
ldi r24 , 0x01         ; ������ ��� ����� ������ ��� �������������
rcall scan_row
swap r24               ; ���������� �� ����������
mov r27 , r24          ; ��� 4 msb ��� r27
ldi r24 ,0x02          ; ������ �� ������� ������ ��� �������������
rcall scan_row
add r27 , r24          ; ���������� �� ���������� ��� 4 lsb ��� r27
ldi r24 , 0x03         ; ������ ��� ����� ������ ��� �������������
rcall scan_row
swap r24               ; ���������� �� ����������
mov r26 , r24          ; ��� 4 msb ��� r26
ldi r24 ,0x04          ; ������ ��� ������� ������ ��� �������������
rcall scan_row
add r26 , r24          ; ���������� �� ���������� ��� 4 lsb ��� r26
movw r24 , r26         ; �������� �� ���������� ����� ����������� r25:r24
ret


keypad_to_ascii:       ; ������ �1� ���� ������ ��� ���������� r26 ��������
movw r26 ,r24          ; �� �������� ������� ��� ��������
ldi r24 ,'E'           ; ��������� �� ascii value ��� e anti gia to *
sbrc r26 ,0
ret
ldi r24 ,'0'
sbrc r26 ,1
ret
ldi r24 ,'F'           ; ��������� ��� ���� F ���� ���� ��� ��� #
sbrc r26 ,2       
ret                
ldi r24 ,'D'
sbrc r26 ,3            ; �� ��� ����� �1������������ ��� ret, ������ (�� ����� �1�)
ret                    ; ���������� �� ��� ���������� r24 ��� ASCII ���� ��� D.
ldi r24 ,'7'
sbrc r26 ,4
ret
ldi r24 ,'8'
sbrc r26 ,5
ret
ldi r24 ,'9'
sbrc r26 ,6
ret
ldi r24 ,'C'
sbrc r26 ,7
ret    
ldi r24 ,'4'          ; ������ �1� ���� ������ ��� ���������� r27 ��������
sbrc r27 ,0           ; �� �������� ������� ��� ��������
ret
ldi r24 ,'5'
sbrc r27 ,1
ret
ldi r24 ,'6'
sbrc r27 ,2
ret
ldi r24 ,'B'
sbrc r27 ,3
ret
ldi r24 ,'1'
sbrc r27 ,4
ret
ldi r24 ,'2'
sbrc r27 ,5
ret
ldi r24 ,'3'
sbrc r27 ,6
ret
ldi r24 ,'A'
sbrc r27 ,7
ret
clr r24
ret

keypad_to_hex:       ; ������ �1� ���� ������ ��� ���������� r26 ��������
movw r26 ,r24        ; �� �������� ������� ��� ��������
ldi r24 ,0x0E        ; ��������� �� ascii value ��� e anti gia to *  
sbrc r26 ,0
ret
ldi r24 ,0x00
sbrc r26 ,1
ret
ldi r24 ,0x0F        ; ��������� ��� ���� F ���� ���� ��� ��� #
sbrc r26 ,2
ret
ldi r24 ,0x0D
sbrc r26 ,3          ; �� ��� ����� �1������������ ��� ret, ������ (�� ����� �1�)
ret                  ; ���������� �� ��� ���������� r24 ��� HEX ���� ��� D.
ldi r24 ,0x07
sbrc r26 ,4
ret
ldi r24 ,0x08
sbrc r26 ,5
ret
ldi r24 ,0x09
sbrc r26 ,6
ret
ldi r24 ,0x0C
sbrc r26 ,7
ret
ldi r24 ,0x04        ; ������ �1� ���� ������ ��� ���������� r27 ��������
sbrc r27 ,0          ; �� �������� ������� ��� ��������
ret
ldi r24 ,0x05
sbrc r27 ,1
ret
ldi r24 ,0x06
sbrc r27 ,2
ret
ldi r24 ,0x0B
sbrc r27 ,3
ret
ldi r24 ,0x01
sbrc r27 ,4
ret
ldi r24 ,0x02
sbrc r27 ,5
ret
ldi r24 ,0x03
sbrc r27 ,6
ret
ldi r24 ,0x0A
sbrc r27 ,7
ret
clr r24
ret


wait_msec:
 push r24           ; 2 ������ (0.250 �sec)
 push r25           ; 2 ������
 ldi r24 , low(998) ; ������� ��� �����. r25:r24 �� 998 (1 ������ - 0.125 �sec)
 ldi r25 , high(998); 1 ������ (0.125 �sec)
 rcall wait_usec    ; 3 ������ (0.375 �sec), �������� �������� ����������� 998.375 �sec
 pop r25            ; 2 ������ (0.250 �sec)
 pop r24            ; 2 ������
 sbiw r24 , 1       ; 2 ������
 brne wait_msec     ; 1 � 2 ������ (0.125 � 0.250 �sec)
 ret                ; 4 ������ (0.500 �sec)
wait_usec:
	sbiw r24 ,1     ; 2 cycles (0.250 �sec)
	nop             ; 1 cycle (0.125 �sec)
	nop
	nop             ; 1 cycle (0.125 �sec)
	nop             ; 1 cycle (0.125 �sec)
	nop             ; 1 cycle (0.125 �sec)
	brne wait_usec  ; 1 cycle if false 2 if true (0.125 ? 0.250 �sec)
	ret             ; 4 cycles (0.500 �sec)

