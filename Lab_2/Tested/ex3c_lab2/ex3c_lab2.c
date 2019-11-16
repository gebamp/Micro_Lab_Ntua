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

volatile unsigned char temp;
volatile unsigned char cntr;

ISR(INT1_vect){
	do{
		//Loop for debounce mechanism
		GIFR = (1<<INTF1); 
		_delay_ms(5);
		temp = GIFR;

	}while((temp & 0x80) == 0x80);
	
	if((PORTB & 0x01) == 0x00) 
	{   //If the led0 in port_b was 0 then turn on timer interrupts and set led0 in port_b to 1
	    TIMSK = (1<<TOIE1);
	    TCCR1B =((1<<CS12)|(0<<CS11)|(1<<CS10));
		TCNT1=0x8526;
		PORTB=0x01;
	}
	else if((PORTB & 0x01) == 0x01)
	{   //If led0 was already on turn on all the other leds for 0.5 s
		PORTB = 0XFF;
		_delay_ms(500);
		
	    TIMSK = (1<<TOIE1);
	    TCCR1B =((1<<CS12)|(0<<CS11)|(1<<CS10));
		TCNT1 = 0x8526;
		PORTB = 0x01;
	}
	

}

ISR(TIMER1_OVF_vect)
{   //Timer ISR when timer interrupts is set disable timer interrupts and turn off the leds of portb
	TIMSK = (0<<TOIE1);
    TCCR1B = ((0<<CS12)|(0<<CS11)|(0<<CS10));
	PORTB = 0x00;
}



int main(void){
	//The following commands sets  the ports for input/output and
	//enables the interrupt_1
	MCUCR = (1<<ISC11)|(1<<ISC10);
	GICR  = (1<<INT1);
	sei();

	DDRB  = 0xFF;
	DDRC  = 0xFF;
	DDRA  = 0x00;
    cntr  = 0x00;

	while(1){
		//If pa7 was pushed then check the state of the leds of port_b
		//and act accordingly
		if((PINA & 0x80)==0x80){
			while((PINA & 0x80)== 0x80);//waits till button pa7 is released
			if((PORTB & 0x01)==0x00)    
			{   //if port_b led 0 was off then set timer interrupts
				//and turn on the leds
	            TIMSK = (1<<TOIE1);
	            TCCR1B =((1<<CS12)|(0<<CS11)|(1<<CS10));
				TCNT1=0x8526;
				PORTB=0x01;
			}
			else if((PORTB & 0x01) == 0x01)
			{  //if port_b led 0 was on then turn on all the leds of 
			  // port_b for 0.5 seconds,then keep only led_0 as 1  and enable timer interrupts 
				PORTB = 0xFF;
				_delay_ms(500);
				
	            TIMSK = (1<<TOIE1);
	            TCCR1B =((1<<CS12)|(0<<CS11)|(1<<CS10));
				TCNT1 = 0X8526;
				PORTB = 0X01;
			}
			
		}
	}
	return 0;
}
