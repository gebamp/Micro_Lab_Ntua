#include <avr/io.h>
#include <avr/interrupt.h>
#define F_CPU 8000000UL
#include <util/delay.h>
#include <stdio.h>
void usart_init();
void usart_transmit(char data);
char usart_receive();
void ADC_init();

int main(void)
{	unsigned char low_input,high_input;
	char string_to_print[30] ;
	int input,i;
	float ADC_input;
	ADC_init();
	usart_init();
	ADCSRA|=(1<<ADSC);
	while(1)
	{
		while( ADCSRA & (1<<ADSC) );
		low_input  = ADCL;
		high_input = ADCH;
		input = ( high_input << 8 ) | low_input;
		ADC_input = input;
		ADC_input*=5;
		ADC_input=ADC_input / 1024;
		// usart_transmit(0x30+ADC_input);
		sprintf(string_to_print,"%.3f V",ADC_input);
		i=0;
		while(string_to_print[i] != '\0'){
			usart_transmit(string_to_print[i]);
			i++;
		} 
		usart_transmit('\n');
		ADCSRA|=(1<<ADSC);

		
	}
}


void ADC_init()
{
	ADMUX = 1<<REFS0;
	ADCSRA = (1<<ADEN)|(0<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);
	return;
}


/*Routine: usart_init
Description:
This routine initializes the
usart as shown below.
------- INITIALIZATIONS -------
Baud rate: 9600 (Fck= 8MH)
Asynchronous mode
Transmitter on
Receiver on
Communication parameters: 8 Data ,1 Stop , no Parity */
void usart_init()
{
	UCSRA = 0x00;
	UCSRB = (1<<RXEN) | (1<<TXEN);
	UBRRH = 0x00;
	UBRRL = 51;
	UCSRC = (1<<URSEL) | (3<<UCSZ0);
}

//Function that transmits the value of DATA using USART
void usart_transmit(char data)
{
	while( !(UCSRA & (1<<UDRE)) ); //check if USART is ready to transmit else wait
	UDR = data;
	return;
}

//Function receives a byte of data through the USART
char usart_receive()
{
	while( !(UCSRA & (1<<RXC)) );
	return UDR;
}
