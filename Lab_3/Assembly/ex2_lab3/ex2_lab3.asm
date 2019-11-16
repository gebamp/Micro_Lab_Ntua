
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

