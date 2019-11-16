
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
main: 
      clr seconds_first_digit
      clr minutes_first_digit
      clr seconds_second_digit
      clr minutes_second_digit
      rcall lcd_init
timer_loop:
      rcall print_time
      in  button,PINB
	  rcall lcd_init
      sbrs button,0
	  jmp timer_loop
       
      rcall print_time
     
      ldi r24,low(840)
	  ldi r25,high(840)
	  rcall wait_msec
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
	   rcall lcd_init


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
ldi r24 ,40       ; Όταν ο ελεγκτής της lcd τροφοδοτείται με
ldi r25 ,0        ; ρεύμα εκτελεί την δική του αρχικοποίηση.
rcall wait_msec   ; Αναμονή 40 msec μέχρι αυτή να ολοκληρωθεί.
ldi r24 ,0x30     ; εντολή μετάβασης σε 8 bit mode
out PORTD ,r24    ; επειδή δεν μπορούμε να είμαστε βέβαιοι
sbi PORTD ,PD3    ; για τη διαμόρφωση εισόδου του ελεγκτή
cbi PORTD ,PD3    ; της οθόνης, η εντολή αποστέλλεται δύο φορές
ldi r24 ,39
ldi r25 ,0        ; εάν ο ελεγκτής της οθόνης βρίσκεται σε 8-bit mode
rcall wait_usec   ; δεν θα συμβεί τίποτα, αλλά αν ο ελεγκτής έχει διαμόρφωση
                  ; εισόδου 4 bit θα μεταβεί σε διαμόρφωση 8 bit
ldi r24 ,0x30
out PORTD ,r24
sbi PORTD ,PD3
cbi PORTD ,PD3
ldi r24 ,39
ldi r25 ,0
rcall wait_usec
ldi r24 ,0x20     ; αλλαγή σε 4-bit mode
out PORTD ,r24
sbi PORTD ,PD3
cbi PORTD ,PD3
ldi r24 ,39
ldi r25 ,0
rcall wait_usec
ldi r24 ,0x28     ; επιλογή χαρακτήρων μεγέθους 5x8 κουκίδων
rcall lcd_command ; και εμφάνιση δύο γραμμών στην οθόνη
ldi r24 ,0x0c     ; ενεργοποίηση της οθόνης, απόκρυψη του κέρσορα
rcall lcd_command
ldi r24 ,0x01     ; καθαρισμός της οθόνης
rcall lcd_command
ldi r24 ,low(1530)
ldi r25 ,high(1530)
rcall wait_usec
ldi r24 ,0x06     ; ενεργοποίηση αυτόματης αύξησης κατά 1 της διεύθυνσης
rcall lcd_command ; που είναι αποθηκευμένη στον μετρητή διευθύνσεων και
                  ; απενεργοποίηση της ολίσθησης ολόκληρης της οθόνης
ret


write_2_nibbles:
push r24         ; στέλνει τα 4 MSB
in r25 ,PIND     ; διαβάζονται τα 4 LSB και τα ξαναστέλνουμε
andi r25 ,0x0f   ; για να μην χαλάσουμε την όποια προηγούμενη κατάσταση
andi r24 ,0xf0   ; απομονώνονται τα 4 MSB και
add r24 ,r25     ; συνδυάζονται με τα προϋπάρχοντα 4 LSB
out PORTD ,r24   ; και δίνονται στην έξοδο
sbi PORTD ,PD3   ; δημιουργείται παλμός Enable στον ακροδέκτη PD3
cbi PORTD ,PD3   ; PD3=1 και μετά PD3=0
pop r24          ; στέλνει τα 4 LSB. Ανακτάται το byte.
swap r24         ; εναλλάσσονται τα 4 MSB με τα 4 LSB
andi r24 ,0xf0   ; που με την σειρά τους αποστέλλονται
add r24 ,r25
out PORTD ,r24
sbi PORTD ,PD3   ; Νέος παλμός Enable
cbi PORTD ,PD3
ret

lcd_data:
sbi PORTD ,PD2   ; επιλογή του καταχωρητή δεδομένων (PD2=1)
rcall write_2_nibbles ; αποστολή του byte
ldi r24 ,43      ; αναμονή 43μsec μέχρι να ολοκληρωθεί η λήψη
ldi r25 ,0       ; των δεδομένων από τον ελεγκτή της lcd
rcall wait_usec
ret

lcd_command:
cbi PORTD ,PD2         ; επιλογή του καταχωρητή εντολών (PD2=1)
rcall write_2_nibbles  ; αποστολή της εντολής και αναμονή 39μsec
ldi r24 ,39            ; για την ολοκλήρωση της εκτέλεσης της από τον ελεγκτή της lcd.
ldi r25 ,0             ; ΣΗΜ.: υπάρχουν δύο εντολές, οι clear display και return home,
rcall wait_usec        ; που απαιτούν σημαντικά μεγαλύτερο χρονικό διάστημα.
ret

scan_keypad_rising_edge:
  mov r22 ,r24         ; αποθήκευσε το χρόνο σπινθηρισμού στον r22
  rcall scan_keypad    ; έλεγξε το πληκτρολόγιο για πιεσμένους διακόπτες
  push r24             ; και αποθήκευσε το αποτέλεσμα
  push r25
  mov r24 ,r22         ; καθυστέρησε r22 ms (τυπικές τιμές 10-20 msec που καθορίζεται από τον
  ldi r25 ,0           ; κατασκευαστή του πληκτρολογίου  χρονοδιάρκεια σπινθηρισμών)
  rcall wait_msec
  rcall scan_keypad    ; έλεγξε το πληκτρολόγιο ξανά και απόρριψε
  pop r23              ; όσα πλήκτρα εμφανίζουν σπινθηρισμό
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
  ldi r25 , 0x08       ; αρχικοποίηση με 0000 1000
  back: lsl r25        ; αριστερή ολίσθηση του 1 τόσες θέσεις
  dec r24              ; όσος είναι ο αριθμός της γραμμής
  brne back
  out PORTC , r25      ; η αντίστοιχη γραμμή τίθεται στο λογικό 1
  nop
  nop                  ; καθυστέρηση για να προλάβει να γίνει η αλλαγή κατάστασης
  in r24 , PINC        ; επιστρέφουν οι θέσεις (στήλες) των διακοπτών που είναι πιεσμένοι
  andi r24 ,0x0f       ; απομονώνονται τα 4 LSB όπου τα 1 δείχνουν που είναι πατημένοι
  ret                  ; οι διακόπτες.




scan_keypad:
ldi r24 , 0x01         ; έλεγξε την πρώτη γραμμή του πληκτρολογίου
rcall scan_row
swap r24               ; αποθήκευσε το αποτέλεσμα
mov r27 , r24          ; στα 4 msb του r27
ldi r24 ,0x02          ; έλεγξε τη δεύτερη γραμμή του πληκτρολογίου
rcall scan_row
add r27 , r24          ; αποθήκευσε το αποτέλεσμα στα 4 lsb του r27
ldi r24 , 0x03         ; έλεγξε την τρίτη γραμμή του πληκτρολογίου
rcall scan_row
swap r24               ; αποθήκευσε το αποτέλεσμα
mov r26 , r24          ; στα 4 msb του r26
ldi r24 ,0x04          ; έλεγξε την τέταρτη γραμμή του πληκτρολογίου
rcall scan_row
add r26 , r24          ; αποθήκευσε το αποτέλεσμα στα 4 lsb του r26
movw r24 , r26         ; μετέφερε το αποτέλεσμα στους καταχωρητές r25:r24
ret


keypad_to_ascii:       ; λογικό 1 στις θέσεις του καταχωρητή r26 δηλώνουν
movw r26 ,r24          ; τα παρακάτω σύμβολα και αριθμούς
ldi r24 ,'E'           ; Επέστρεψε το ascii value του e anti gia to *
sbrc r26 ,0
ret
ldi r24 ,'0'
sbrc r26 ,1
ret
ldi r24 ,'F'           ; Επέστρεψε την τιμή F αυτή αντι για την #
sbrc r26 ,2       
ret                
ldi r24 ,'D'
sbrc r26 ,3            ; αν δεν είναι 1παρακάμπτει την ret, αλλιώς (αν είναι 1)
ret                    ; επιστρέφει με τον καταχωρητή r24 την ASCII τιμή του D.
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
ldi r24 ,'4'          ; λογικό 1 στις θέσεις του καταχωρητή r27 δηλώνουν
sbrc r27 ,0           ; τα παρακάτω σύμβολα και αριθμούς
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

keypad_to_hex:       ; λογικό 1 στις θέσεις του καταχωρητή r26 δηλώνουν
movw r26 ,r24        ; τα παρακάτω σύμβολα και αριθμούς
ldi r24 ,0x0E        ; Επέστρεψε το ascii value του e anti gia to *  
sbrc r26 ,0
ret
ldi r24 ,0x00
sbrc r26 ,1
ret
ldi r24 ,0x0F        ; Επέστρεψε την τιμή F αυτή αντι για την #
sbrc r26 ,2
ret
ldi r24 ,0x0D
sbrc r26 ,3          ; αν δεν είναι 1παρακάμπτει την ret, αλλιώς (αν είναι 1)
ret                  ; επιστρέφει με τον καταχωρητή r24 την HEX τιμή του D.
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
ldi r24 ,0x04        ; λογικό 1 στις θέσεις του καταχωρητή r27 δηλώνουν
sbrc r27 ,0          ; τα παρακάτω σύμβολα και αριθμούς
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

