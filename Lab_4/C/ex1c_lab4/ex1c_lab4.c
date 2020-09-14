/*
 * ex1_Lab4.c
 *
 * Created: 1/12/2019 12:05:25 µµ
 * Author : Miniala
 */ 

#define  F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

void write_2_nibbles(char data)
{
	char previous_state = PIND;
	PORTD = (data&0xf0) | (previous_state&0x0f);
	
	PORTD |= (1<<PD3);
	PORTD &= ~(1<<PD3);
	
	PORTD = ((data&0x0f)<<4) | (previous_state&0x0f);
	
	PORTD |= (1<<PD3);
	PORTD &= ~(1<<PD3);
	
	return;
}

void lcd_data(char data)
{
	PORTD |= (1<<PD2);
	write_2_nibbles(data);
	
	_delay_us(43);
	
	return;
}


void lcd_command(char command)
{
	PORTD &= ~(1<<PD2);
	write_2_nibbles(command);
	
	_delay_us(39);
	
	return;
}


void lcd_init()
{
	_delay_ms(40);
	PORTD = 0x30;
	PORTD |= (1<<PD3);
	PORTD &= ~(1<<PD3);
	_delay_us(39);
	
	PORTD = 0x30;
	PORTD |= (1<<PD3);
	PORTD &= ~(1<<PD3);
	_delay_us(20);
	
	PORTD = 0x20;
	PORTD |= (1<<PD3);
	PORTD &= ~(1<<PD3);
	_delay_us(39);
	
	lcd_command(0x28);
	lcd_command(0x0c);
	lcd_command(0x01);
	
	_delay_us(1530);
	
	lcd_command(0x06);
	
	return;
}
unsigned char one_wire_reset(){
	unsigned char crc;
	DDRA  |=  (1 << PA4);
	PORTA &= ~(1 << PA4);
	_delay_us(480);
	// mb DDRA= (0<<PA4)
	DDRA  &= ~(1 << PA4);
	PORTA &= ~(1 << PA4);
	_delay_us(100);
	crc = PINA ;
	_delay_us(380);
	if((crc & 0x10) == 0x10){
		return 0;
	}
	else{
		return 1;
	}	
	return -1;
}

void one_wire_transmit_bit(unsigned char bit){
	DDRA  |=   (1<<PA4);
	PORTA &= ~(1<<PA4);
	_delay_us(2);
	if((bit & 0x01)==0x01){
		PORTA |= (1<<PA4);
	}
	if((bit & 0x01)==0x00){
		PORTA &= (1<<PA4);
	}
	_delay_us(58);
	DDRA  &= ~(1<<PA4);
	PORTA &= ~(1<<PA4);
	_delay_us(1);
} 

void one_wire_transmit_byte(unsigned char byte){
	unsigned char bit_to_send;
	for(int i=0; i<8; i++){
		bit_to_send = byte & 0x01;
		if(bit_to_send == 0){
		one_wire_transmit_bit(0);
		}
		else if(bit_to_send == 1){
		one_wire_transmit_bit(1);
		}
		byte = byte >> 1;
	}	
}
unsigned char one_wire_receive_bit(){
	unsigned char bit_to_return = 0;
	DDRA  |=  (1 << PA4);
	PORTA &= ~(1 << PA4);
	_delay_us(2);
	DDRA  &= ~(1 << PA4);
	PORTA &= ~(1 << PA4);
	_delay_us(10);
	if( (PINA & 0X10) == 0x10 ){
		bit_to_return = 1;
	}
	_delay_us(49);
	return bit_to_return;
}
unsigned char one_wire_receive_byte(){
	unsigned char bit_received,byte_to_return=0;
	for(int i =0 ; i<8 ; i++){
		byte_to_return = byte_to_return >> 1;
		bit_received = one_wire_receive_bit();
		if(bit_received == 1){
			bit_received = 0x80;	
		}
		byte_to_return= byte_to_return | bit_received ;
	}
	return byte_to_return;
}
unsigned int return_temp(){
	unsigned char crc,finished,temp,temp_sign;
	int sign;
	crc = one_wire_reset();
    if(crc == 0x00){
	   return 0x8000;
	}
	one_wire_transmit_byte(0xCC);
	one_wire_transmit_byte(0x44);
	while(1){
		finished = one_wire_receive_bit();
		if((finished & 0x01) == 0x01){
			break;
		}
	}
	crc = one_wire_reset();
	if(crc == 0x00){
		return 0x8000;
	}
	one_wire_transmit_byte(0xCC);
	one_wire_transmit_byte(0xBE);
	temp = one_wire_receive_byte();
	temp = temp >> 1 ;
	temp_sign = one_wire_receive_byte();
	sign =  temp_sign;
	sign = sign <<  8;
	sign = sign & 0xFF00;
	return  (sign | temp);
	
		
}
int main(void)
{   int temp;
    DDRB = 0xFF;
    while (1) 
    {
		temp = return_temp();
		PORTB = temp;
    }
	return 0;
}

