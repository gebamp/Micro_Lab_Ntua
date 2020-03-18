.include "m16def.inc"
#define mon r18
#define tens r19
#define hundreds r20
#define sign r21
.org  0x0
rjmp   reset


reset:
  ldi r24,low(RAMEND)    ;Initialize stack pointer
  out SPL,r24
  ldi r24,high(RAMEND)  
  out SPH,r24
  ser r24
main:
  ldi  r24,0x60

get_digits:
  ldi  sign,'+'
  sbrc r24,7
  ldi  sign,'-'
  clr mon
  clr tens
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
  inc  tens
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


end:  
  jmp main
