
; Replace with your application code
; ---- Αρχή τμήματος δεδομένων
.nolist
.include "m16def.inc"
.list
.DSEG
 _tmp_: .byte 2
; ---- Τέλος τμήματος δεδομένων
.CSEG
.include "m16def.inc"

.org  0x0
rjmp  reset



reset:
  ldi r24,low(RAMEND)    ;Initialize stack pointer
  out SPL,r24
  ldi r24,high(RAMEND)  
  out SPH,r24
  ser r24
  out DDRB,r24          ;Initialize port_b for output
  clr r24
  ldi r24, (1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4) 
  out DDRC,r24           ;Set the 4 msb as output

main:
  ldi   r24,0x0A
  rcall scan_keypad_rising_edge
  rcall keypad_to_ascii
  cpi   r24,0x00
  breq  main
  mov   r16,r24
pressed_first:
  ldi   r24,0x0A
  rcall scan_keypad_rising_edge
  rcall keypad_to_ascii
  cpi   r24,0x00
  breq  pressed_first
  mov   r17,r24
check_first:
  cpi   r16,0x30 
  breq  first_was_ok
not_okay:
  rcall wrong_pass
  jmp   end
first_was_ok: 
  cpi   r17,0x39
  breq  second_was_ok
  jmp   not_okay
second_was_ok:
  rcall correct_pass
  
end:  
  jmp main


wrong_pass:
  ldi r19,8
rep: 
  ser   r18
  out   PORTB,r18
  ldi   r24,low(250)
  ldi   r25,high(250)
  rcall wait_msec
  clr   r18
  out   PORTB,r18
  ldi   r24,low(250)
  ldi   r25,high(250)
  rcall wait_msec
  dec   r19
  brne  rep

  clr r24
  clr r25
  clr r18
  out PORTB,r18
  ret

correct_pass:
  ser r18
  out PORTB,r18
  ldi r24,low(4000)
  ldi r25,high(4000)
  rcall wait_msec
  clr r24
  clr r25
  clr r18
  out PORTB,r18
  ret




scan_keypad_rising_edge:
  mov r22 ,r24      ; αποθήκευσε το χρόνο σπινθηρισμού στον r22
  rcall scan_keypad ; έλεγξε το πληκτρολόγιο για πιεσμένους διακόπτες
  push r24          ; και αποθήκευσε το αποτέλεσμα
  push r25
  mov r24 ,r22      ; καθυστέρησε r22 ms (τυπικές τιμές 10-20 msec που καθορίζεται από τον
  ldi r25 ,0        ; κατασκευαστή του πληκτρολογίου  χρονοδιάρκεια σπινθηρισμών)
  rcall wait_msec
  rcall scan_keypad ; έλεγξε το πληκτρολόγιο ξανά και απόρριψε
  pop r23           ; όσα πλήκτρα εμφανίζουν σπινθηρισμό
  pop r22
  and r24 ,r22
  and r25 ,r23
  ldi r26 ,low(_tmp_)  ; φόρτωσε την κατάσταση των διακοπτών στην
  ldi r27 ,high(_tmp_) ; προηγούμενη κλήση της ρουτίνας στους r27:r26
  ld r23 ,X+
  ld r22 ,X
  st X ,r24            ; αποθήκευσε στη RAM τη νέα κατάσταση
  st -X ,r25           ; των διακοπτών
  com r23
  com r22              ; βρες τους διακόπτες που έχουν «μόλις» πατηθεί
  and r24 ,r22
  and r25 ,r23
  ret


scan_row:
  ldi r25 , 0x08  ; αρχικοποίηση με 0000 1000
  back_: lsl r25  ; αριστερή ολίσθηση του 1 τόσες θέσεις
  dec r24         ; όσος είναι ο αριθμός της γραμμής
  brne back_
  out PORTC , r25 ; η αντίστοιχη γραμμή τίθεται στο λογικό 1
  nop
  nop             ; καθυστέρηση για να προλάβει να γίνει η αλλαγή κατάστασης
  in r24 , PINC   ; επιστρέφουν οι θέσεις (στήλες) των διακοπτών που είναι πιεσμένοι
  andi r24 ,0x0f  ; απομονώνονται τα 4 LSB όπου τα 1 δείχνουν που είναι πατημένοι
  ret             ; οι διακόπτες.




scan_keypad:
ldi r24 , 0x01    ; έλεγξε την πρώτη γραμμή του πληκτρολογίου
rcall scan_row
swap r24          ; αποθήκευσε το αποτέλεσμα
mov r27 , r24     ; στα 4 msb του r27
ldi r24 ,0x02     ; έλεγξε τη δεύτερη γραμμή του πληκτρολογίου
rcall scan_row
add r27 , r24     ; αποθήκευσε το αποτέλεσμα στα 4 lsb του r27
ldi r24 , 0x03    ; έλεγξε την τρίτη γραμμή του πληκτρολογίου
rcall scan_row
swap r24          ; αποθήκευσε το αποτέλεσμα
mov r26 , r24     ; στα 4 msb του r26
ldi r24 ,0x04     ; έλεγξε την τέταρτη γραμμή του πληκτρολογίου
rcall scan_row
add r26 , r24     ; αποθήκευσε το αποτέλεσμα στα 4 lsb του r26
movw r24 , r26    ; μετέφερε το αποτέλεσμα στους καταχωρητές r25:r24
ret



keypad_to_ascii: ; λογικό 1 στις θέσεις του καταχωρητή r26 δηλώνουν
movw r26 ,r24    ; τα παρακάτω σύμβολα και αριθμούς
ldi r24 ,'*'
sbrc r26 ,0
ret
ldi r24 ,'0'
sbrc r26 ,1
ret
ldi r24 ,'#'
sbrc r26 ,2
ret
ldi r24 ,'D'
sbrc r26 ,3      ; αν δεν είναι 1παρακάμπτει την ret, αλλιώς (αν είναι 1)
ret              ; επιστρέφει με τον καταχωρητή r24 την ASCII τιμή του D.
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
ldi r24 ,'4'    ; λογικό 1 στις θέσεις του καταχωρητή r27 δηλώνουν
sbrc r27 ,0     ; τα παρακάτω σύμβολα και αριθμούς
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


wait_msec:
 push r24           ; 2 κύκλοι (0.250 μsec)
 push r25           ; 2 κύκλοι
 ldi r24 , low(998) ; φόρτωσε τον καταχ. r25:r24 με 998 (1 κύκλος - 0.125 μsec)
 ldi r25 , high(998); 1 κύκλος (0.125 μsec)
 rcall wait_usec    ; 3 κύκλοι (0.375 μsec), προκαλεί συνολικά καθυστέρηση 998.375 μsec
 pop r25            ; 2 κύκλοι (0.250 μsec)
 pop r24            ; 2 κύκλοι
 sbiw r24 , 1       ; 2 κύκλοι
 brne wait_msec     ; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
 ret                ; 4 κύκλοι (0.500 μsec)
wait_usec:
	sbiw r24 ,1     ; 2 cycles (0.250 ΅sec)
	nop             ; 1 cycle (0.125 ΅sec)
	nop
	nop             ; 1 cycle (0.125 ΅sec)
	nop             ; 1 cycle (0.125 ΅sec)
	nop             ; 1 cycle (0.125 ΅sec)
	brne wait_usec  ; 1 cycle if false 2 if true (0.125 ? 0.250 ΅sec)
	ret             ; 4 cycles (0.500 ΅sec)
