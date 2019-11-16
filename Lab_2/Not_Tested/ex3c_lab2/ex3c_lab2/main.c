/*
 * ex3c_lab2.c
 *
 * Created: 25/10/2019 12:33:02 πμ
 * Author : Superminiala
 */ 



#define F_CPU 8000000UL  // 8 MHz
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

volatile unsigned char temp;

ISR(INT1_vect){
	do{
		GIFR = (1<<INTF1);
		_delay_ms(5);
		temp = GIFR;

	}while((temp & 0x80) == 0x80);
	/*GIFR = (0<<INTF1);*/
	if((PORTB & 0x01) == 0x00)
	{
		TCNT1=0x8526;
		PORTB=0x01;
	}
	else if((PORTB & 0x01) == 0x01)
	{
		PORTB = 0XFF;
		_delay_ms(500);
		TCNT1 = 0x8526;
		PORTB = 0x01;
	}
	

}

ISR(TIMER1_OVF_vect)
{
	PORTB = 0x00;
}



int main(void){
	MCUCR = (1<<ISC11)|(1<<ISC10);
	GICR  = (1<<INT1);
	TIMSK = (1<<TOIE1);
	TCCR1B =((1<<CS12)|(0<<CS11)|(1<<CS10));
	sei();

	DDRB  = 0xFF;
	DDRA  = 0x00;

	while(1){
		if((PINA & 0x80)==0x80){
			while((PINA & 0x80)== 0x80);
			if((PORTB & 0x01)==0x00)
			{
				TCNT1=0x8526;
				PORTB=0x01;
			}
			else if((PORTB & 0x01) == 0x01)
			{
				PORTB = 0xFF;
				_delay_ms(500);
				TCNT1 = 0X8526;
				PORTB = 0X01;
			}
			
		}
	}
	return 0;
}