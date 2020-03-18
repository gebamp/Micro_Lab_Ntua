/*
 * ex2_Lab5.c
 *
 * Created: 12/10/2019 1:47:02 PM
 * Author : superminiala
 */ 

#include <avr/io.h>

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

void  print_invalid(void){
	usart_transmit('I');
	usart_transmit('n');
	usart_transmit('v');
	usart_transmit('a');
	usart_transmit('l');
	usart_transmit('i');
	usart_transmit('d');
	usart_transmit(' ');
	usart_transmit('N');
	usart_transmit('u');
	usart_transmit('m');
	usart_transmit('b');
	usart_transmit('e');
	usart_transmit('r');
	usart_transmit(0x00);
}
void  print_number(unsigned char number){
	usart_transmit('N');
	usart_transmit('u');
	usart_transmit('m');
	usart_transmit('b');
	usart_transmit('e');
	usart_transmit('r');
	usart_transmit(' ');	
	usart_transmit('R');
	usart_transmit('e');
	usart_transmit('a');
	usart_transmit('d');
	usart_transmit(':');
	usart_transmit(0x00);
	usart_transmit(number);
}
void turn_on_leds(unsigned char input){
switch (input){
	case '1':
	PORTB = 0x01;
	break;
	case '2':
	PORTB = 0x03;
	break;
	case '3':
	PORTB = 0X07;
	break;
	case '4':
	PORTB = 0x0F;
	break;
	case '5':
	PORTB = 0X1F;
	break;
	case '6':
	PORTB = 0X3F;
	break;
	case '7':
	PORTB = 0X7F;
	break;
	case '8':
	PORTB = 0xFF;
	break;
}
return;
}
int main(void)
{   unsigned char input;
	DDRB = 0xFF;
	usart_init();
     while (1) 
    {
		input = usart_receive();
		if(input == '9'){
			print_invalid();
			usart_transmit('\n');
		}
		else if(input== '0'){
			print_number(input);
			usart_transmit('\n');
			PORTB = 0X00;
		}
		else{
			print_number(input);
			usart_transmit('\n');
			turn_on_leds(input);	
		} 
    } 
	
}

