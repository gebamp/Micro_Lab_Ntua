/*
 * ex3c_lab2.c
 *
 * Created: 25/10/2019 12:33:02 pµ
 * Author : Superminiala
 */ 


#define F_CPU 8000000UL  // 8 MHz
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

unsigned char debounce_delay;
unsigned char input_1,input_2,input_1_ascii,input_2_ascii;
unsigned char flag_1,flag_2;
unsigned char temp,input_value_check,save_delay;
unsigned char row1,row2,row3,row4,input_value;
int input,temp1,temp2,temp3,temp4,save;

void correct_password(void){
   PORTB = 0xFF;
   _delay_ms(4000);
   PORTB = 0x00;

}
void wrong_password(void){
  for(int i =0;i<8; i++){
  if ((i % 2 )== 0){
     PORTB = 0xFF;
	 _delay_ms(250);
  }
  else{
     PORTB = 0x00;
	 _delay_ms(250);
  }
  }
}

int  scan_row(unsigned char input){
  temp = 0x08;
  while(input !=0 ){
  temp = temp << 1;
  input--;
  }
  PORTC = temp;
  asm volatile(
  "nop" "\n"
  "nop" "\n");
  input = PINC;
  input = input & 0x0F;
  return input;
  
}
unsigned char  keypad_to_ascii(int input){
 save = input;
 if ((input & 0x0001)==0){
  input = '*';
  return  input;
 }
 else if ((input & 0x0002)==0){
  input = '0';
  return input;}
 else if ((input & 0x0004)==0){
  input = '#';
  return input;}
 else if ((input & 0x0008)==0){
  input = 'D';
  return input;}
 else if ((input & 0x0010)==0){
  input = '7';
  return input;}
 else if ((input & 0x0020)==0){
  input = '8';
  return input;}
 else if ((input & 0x0040)==0){
  input = '9';
  return input;}
 else if ((input & 0x0080)==0){
  input = 'C';
  return input;}
 else if ((input & 0x0100)==0){
  input = '4';
  return input;}
 else if ((input & 0x0200)==0){
  input = '5';
  return input;}
 else if ((input & 0x0400)==0){
  input = '6';
  return input;}
 else if ((input & 0x0800)==0){
  input = 'B';
  return input;}
 else if ((input & 0x1000)==0){
  input = '1';
  return input;}
 else if ((input & 0x2000)==0){
  input = '2';
  return input;}
 else if ((input & 0x4000)==0){
  input = '3';
  return input;}
 else if ((input & 0x4000)==0){
  input = 'A';
  return input;}
 else {
  input = 0;
  return input;
  }
}
int  scan_keypad(void){
 row1=1;
 temp1 = scan_row(1);
 temp1 = temp1 << 12 ;
 temp2 = scan_row(2);
 temp2 = temp2 << 8;
 temp3 = scan_row(3);
 temp3 = temp2 << 4;
 temp4 = scan_row(4);
 input = temp1 | temp2 | temp3 | temp4;
 return input;

}
int  scan_keypad_rising_edge(unsigned char debounce_delay){
  save_delay = debounce_delay;
  input_value =  scan_keypad();
  _delay_ms(10);
  input_value_check = scan_keypad();
  return input_value_check;

}
int main(void){
    DDRB=0xFF;
	DDRC=(1<<PC7)|(1<<PC6)|(1<<PC5)|(1<<PC4);
    flag_1=0;
	flag_2=0;
	   
	while(1){
	while(flag_1 == 0){
	debounce_delay = 0x0A;
	input_1= scan_keypad_rising_edge(debounce_delay);
	input_1_ascii= keypad_to_ascii(input_1);
	if (input_1_ascii != 0){
	 flag_1=1;
	 }
	 
	}
	while(flag_2 == 0){
	debounce_delay = 0x0A;
	input_2= scan_keypad_rising_edge(debounce_delay);
	input_2_ascii= keypad_to_ascii(input_2);
	if (input_2_ascii != 0){
	 flag_2=1;
	 }

	}
    if( input_1_ascii == '0' && input_2_ascii == '9'){
	  correct_password();
	}
	else{
	  wrong_password();
	}
	_delay_ms(4000);
	flag_1=0;
	flag_2=0;	
	}
	return 0;
}
