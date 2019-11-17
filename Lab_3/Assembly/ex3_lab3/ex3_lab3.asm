
; Replace with your application code
.nolist
.include "m16def.inc"
.list
.DSEG
 _tmp_: .byte 2
; ---- Code segment
.CSEG
.include "m16def.inc"

.org  0x0
rjmp   reset

;scan_row r24,r25
;scan_keypad r27,r26,r25,r24
;scan_keypad_rising_edge r27,r26,r25,r24,r23,r22
;keypad_to_ascii 27,26,25,24
;write_2_nimbles input r24 uses r24,r25
;lcd_data input r24 uses r24,r25
;lcd_command  input r24 uses r24,r25
;lcd_init  uses  r24,r25
;available r16,r17,r18,r19,r20,r21,r28,r29,r30,r31
#define seconds_first_digit  r16
#define seconds_second_digit r17
#define minutes_first_digit  r18
#define minutes_second_digit r19
#define ascii_const r20
#define button r21
reset:
  ldi r24,low(RAMEND)          ;Initialize stack pointer
  out SPL,r24
  ldi r24,high(RAMEND)  
  out SPH,r24
  ser r24
  out DDRD,r24
  clr r24
  out DDRB,r24
  clr r24
  clr ascii_const
  ldi ascii_const,48
  ;lcd_init
main: 
    clr seconds_first_digit
    clr minutes_first_digit
    clr seconds_second_digit
    clr minutes_second_digit
    ;ldi r24,0x01
    ;rcall lcd_commad
    rcall lcd_init
    rcall print_time
timer_loop:
    ;ldi r24,0x01
    ;rcall lcd_command
    rcall lcd_init
    rcall print_time
    in  button,PINB
    ;ldi r24,0x01
    ;rcall lcd_command
    sbrc button,7
	  jmp  main
    sbrs button,0
	  jmp timer_loop
  
    ;rcall print_time
     
    ldi r24,low(840)
	  ldi r25,high(840)
	  rcall wait_msec
    ;1st_Adition
    ;ldi r24,low (950)
	  ;ldi r25,high(950)
	  ;rcall wait_msec
    
;     ldi  r28,0
;     ldi  r29,249
;     jmp  keep_checking
; 250_ms:
;     inc r28
;     cpi r28,3
;     breq 1_second_has_passed
; keep_checking:
;     in   r30,PINB
;     sbrc r30,7
;     jmp   main
;     sbrs r30,0
;     jmp timer_loop
;     ldi r24,low(1)
;     ldi r25,high(1)
;     rcall wait_msec
;     dec r29
;     breq r29,250_ms
;     jmp keep_checking
; 1_second_has_passed:
;     ;
	  inc   seconds_second_digit
    cpi   seconds_second_digit,10
	  brne  dont_increment_something
	  clr   seconds_second_digit
    inc   seconds_first_digit
	  cpi   seconds_first_digit,6
    brne  dont_increment_something
	  clr   seconds_first_digit
	  inc   minutes_second_digit
	  cpi   minutes_second_digit,10
	  brne  dont_increment_something
	  clr   minutes_second_digit
	  inc   minutes_first_digit
dont_increment_something:
    
end:
	  cpi   minutes_first_digit,6
	  breq  main
    jmp timer_loop


print_time:
  mov   r24,minutes_first_digit
  add   r24,ascii_const
rcall lcd_data
  mov   r24,minutes_second_digit
  add   r24,ascii_const
rcall lcd_data
  ldi   r24,' '
rcall lcd_data
  ldi r24,'M'
rcall lcd_data
  ldi r24,'I'
rcall lcd_data
  ldi r24,'N'
rcall lcd_data
  ldi r24,':'
rcall lcd_data
  mov   r24,seconds_first_digit
  add   r24,ascii_const
rcall lcd_data
  mov   r24,seconds_second_digit
  add   r24,ascii_const
rcall lcd_data
  ldi   r24,' '
rcall lcd_data
  ldi r24,'S'
rcall lcd_data
  ldi r24,'E'
rcall lcd_data
  ldi r24,'C'
rcall lcd_data 
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
 ldi r24 ,0x06     ; activate auto increment by one which is stored in
 rcall lcd_command ; address counter deactivate for entire shifting for 
                  ; entire monitor
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
 
  
keypad_to_ascii:        ; ������ �1� ���� ������ ��� ���������� r26 ��������
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
 push r24           ; 2 cylcles (0.250 �sec)
 push r25           ; 2 cycles
 ldi r24 , low(998) ; ������� ��� �����. r25:r24 �� 998 (1 ������ - 0.125 �sec)
 ldi r25 , high(998); 1 cycle (0.125 �sec)
 rcall wait_usec    ; 3 cycle (0.375 �sec), �������� �������� ����������� 998.375 �sec
 pop r25            ; 2 cycle (0.250 �sec)
 pop r24            ; 2 cycle
 sbiw r24 , 1       ; 2 cycle
 brne wait_msec     ; 1 if succces  2 if fail (0.125 � 0.250 �sec)
 ret                ; 4 cycles (0.500 �sec)
wait_usec:
	sbiw r24 ,1     ; 2 cycles (0.250 �sec)
	nop             ; 1 cycle (0.125 �sec)
	nop
	nop             ; 1 cycle (0.125 �sec)
	nop             ; 1 cycle (0.125 �sec)
	nop             ; 1 cycle (0.125 �sec)
	brne wait_usec  ; 1 cycle if false 2 if true (0.125 ? 0.250 �sec)
	ret             ; 4 cycles (0.500 �sec)

