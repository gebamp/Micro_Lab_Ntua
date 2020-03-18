/*
 * GccApplication2.c
 *
 * Created: 11/17/2019 5:00:53 PM
 * Author : superminiala
 */ 

#include <avr/io.h>

#define  F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

void write_2_nibbles(unsigned char input)
{   unsigned char r25,low_nibble;
	unsigned char first_input,second_input,low_to_high_nibble;
	r25 = (PIND & 0X0F);
	// Get the 4 msb of input and send to Port_D
	first_input = (input & 0xF0) + r25;
	PORTD = first_input;
	PORTD = PORTD | (1 << PD3);
	PORTD = PORTD |(0 << PD3);
	//Get the 4 lsb and send them to portd as msb
	low_nibble =  input & 0x0F;
	low_to_high_nibble = (low_nibble <<4);
	second_input = low_to_high_nibble + r25;
	PORTD = second_input;
	PORTD = PORTD |(1 << PD3);
	PORTD = PORTD |(0 << PD3);
	return ;
}
void lcd_data(unsigned char input){
	PORTD = (1 << PD2 );
	write_2_nibbles(input);
	_delay_us(43);
	return ;
}

void lcd_command(unsigned char command){
	PORTB = (0 << PD2);
	write_2_nibbles(command);
	_delay_us(39);
	return ;
}
void lcd_init(){
	_delay_ms(40);
	PORTD = 0x30;
	PORTD =PORTD|(1 << PD3);
	PORTD =PORTD|(0 << PD3);
	_delay_us(39);

	PORTD = 0x30;
	PORTD = PORTD| (1 << PD3);
	PORTD = PORTD| (0 << PD3);
	_delay_us(39);


	PORTD = 0x20;
	PORTD = PORTD| (1 << PD3);
	PORTD = PORTD|(0 << PD3);
	_delay_us(39);

	lcd_command(0x28);
	lcd_command(0x0c);
	lcd_command(0x01);
	_delay_us(1530);
	
	lcd_command(0x06);
	return ;
}
int main(void){
	DDRB = 0x00;
	DDRD =0xFF;
	DDRC = 0X00;
	unsigned char minutes_high=0x00,seconds_high=0x00,minutes_low=0x00,seconds_low=0x00;
 	lcd_init();
	 while(1){
	 lcd_command(0x02);
	 lcd_data('M');
	 
	 }
  /*    lcd_data(minutes_low+48);
		lcd_data('M');
		lcd_data('I');
		lcd_data('N');
		lcd_data(':');
		lcd_data(seconds_high+48);
		lcd_data(seconds_low+48);
		lcd_data('S');
		lcd_data('E');
		lcd_data('C');
change_of_mind:
    	while(1){
		if((PINB & 0x80) == 0x80){
reset:	
		while((PINB & 0x80)== 0x80);
		minutes_high=0x00;
		minutes_low=0x00;
		seconds_high=0x00;
		seconds_low=0x00;
		lcd_command(0x01);
		lcd_data(minutes_high+48);
		lcd_data(minutes_low+48);
		lcd_data('M');
		lcd_data('I');
		lcd_data('N');
		lcd_data(':');
		lcd_data(seconds_high+48);
		lcd_data(seconds_low+48);
		lcd_data('S');
		lcd_data('E');
		lcd_data('C');
			
		}
		else if ( (PINB & 0x01) == 0x01 ){
		    while ( (PINB & 0x01) == 0x01 ){
			  if((PINB & 0x80) == 0x80){
			  goto reset; }
			  for(int i =0; i<1000; i ++){
				  if((PINB&0x80) == 0x80){
				  goto reset;
				  }
				  if ( (PINB&0x01) == 0x00){
				   goto change_of_mind;
				  }
				  _delay_ms(1);
			  }
			  seconds_low=seconds_low + 1;
			  if(seconds_low==10){
		      seconds_high=seconds_high+1;
			  seconds_low=0x00;}
		      if(seconds_high==6){
			  seconds_high=0;
			  minutes_low=minutes_low + 1;
			  }
			  if(minutes_low==10){
			  minutes_low=0;
			  minutes_high=minutes_high+1;
			  }
			  if(minutes_high==6){
				  minutes_high=0;
				  minutes_low=0;
				  seconds_high=0;
				  seconds_low=0;
			  }
			  lcd_command(0x01);	  
		      lcd_data(minutes_high+48);
		      lcd_data(minutes_low+48);
		      lcd_data('M');
		      lcd_data('I');
		      lcd_data('N');
		      lcd_data(':');
		      lcd_data(seconds_high+48);
		      lcd_data(seconds_low+48);
		      lcd_data('S');
		      lcd_data('E');
		      lcd_data('C');
		}
		}
	}
	return 0;*/    
}


