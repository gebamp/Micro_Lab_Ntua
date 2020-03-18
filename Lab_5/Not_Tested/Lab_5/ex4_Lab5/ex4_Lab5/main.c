/*
 * ex2_Lab5.c
 *
 * Created: 12/10/2019 1:47:02 PM
 * Author : superminiala
 */ 
#define F_CPU 8000000UL  // 8 MHz
#include <avr/io.h>#include <avr/interrupt.h>
#include <util/delay.h>

void usart_init(void){
	UCSRA = 0; //Initialize USCRA as 0
	// Activate transmitter receiver
	UCSRB = (1 << RXEN) | (1<< TXEN);
	//Baud rate = 9600
	UBRRH = 0;
	UBRRL = 51;
	// 8 bit character size 1 stop bit
	UCSRC = (1 << URSEL) | (3 << UCSZ0);
}

void usart_transmit(unsigned char byte){
	while(!(UCSRA & (1 << UDRE)));
	UDR = byte;
}
unsigned char  usart_receive(void ){
	while(!(UCSRA &(1 << RXC)));
	return  UDR;
}
void ADC_init(void){
	ADMUX  = (1 << REFS0);
	ADCSRA = (1 << ADEN) | (1<< ADPS2) | (1 <<  ADPS1) | (1 << ADPS0) ;
	return ; 
}
int main(void)
{	unsigned char voltage_input_high,voltage_input_low,first_digit=0,second_digit=0;
	unsigned int voltage_input ;
	usart_init();
	ADC_init();
     while (1) 
    {
		 ADCSRA |= (1 << ADSC);
		 while ( (ADCSRA & 0X70) == 0x70 );
		 voltage_input_low  = ADCL;
		 voltage_input_high = ADCH;
		 voltage_input_high = (voltage_input_high << 7);   
		 voltage_input = voltage_input_high | voltage_input_low ; 
		 voltage_input = voltage_input * 5;
		 for(int i =0;i<10;i++){
			 voltage_input = voltage_input >>1;
			 if(i==7){
			 second_digit = '5';
			 if((voltage_input & 0x01)!=1){
				second_digit = '0';
			 }
			 continue;
			 }
			 else if (i==8){
				first_digit = '7';
				if((voltage_input & 0x01)!=1){
					first_digit = '0';
				}
				continue; 
			 }
		 }
		 
		 usart_transmit(voltage_input + 0x30);
		 usart_transmit('.');
		 usart_transmit(first_digit);
		 usart_transmit(second_digit);
		 usart_transmit('V');
		 usart_transmit(0x0D);
		 
    } 
	
}

