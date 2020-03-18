#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>


void lcd_data(char data);
void lcd_init();
void lcd_command(char command);
void write_2_nibbles(char data);
int scan_row(char row_nr);
int scan_keypad();
int scan_keypad_rising_edge();
char keypad_to_hex(int keypad);
void hex_to_decimal(char number);
char keypad_to_ascii(int keypad);

int _tmp_=0;
char sign,first_decimal=0x30,second_decimal=0x30,third_decimal=0x30;

int main(void)
{
	DDRC = 0xf0;
	DDRD = 0xff;
	DDRA = 0xff;
	lcd_init();
	char first_hex_digit,second_hex_digit;
	int  first_num_t,sec_num_t;
	char number,first_num,second_num;
	 
    while(1)
	{
		while( (second_hex_digit =keypad_to_hex(first_num_t=scan_keypad_rising_edge()) ) == 0xff );
		
		while( (first_hex_digit =keypad_to_hex(sec_num_t=scan_keypad_rising_edge()) ) == 0xff );	
        first_num = keypad_to_ascii(first_num_t);
		second_num = keypad_to_ascii(sec_num_t);
		number = (second_hex_digit << 4) | first_hex_digit ;
		
		
		if( (number&0x80)==0x80 )
		{
			number=-number;
			sign = '-';
		}
		else sign = '+';
		
		hex_to_decimal(number);

		first_decimal=first_decimal + 0x30;
		second_decimal=second_decimal + 0x30;
		third_decimal=third_decimal + 0x30;

		
		lcd_command(0x02);
		lcd_data(first_num);
		lcd_data(second_num);
		lcd_data('=');
		lcd_data(sign);
		lcd_data(third_decimal);
		lcd_data(second_decimal);
		lcd_data(first_decimal);
		
	}
	
	
}

void hex_to_decimal(char number)
{
	first_decimal=0x00;
	second_decimal=0x00;
	third_decimal=0x00;
	
	if( number>=100 )
	{
		third_decimal++;
		number-=100;
	} 
	
	while(number>=10)
	{
		second_decimal++;
		number-=10;
	}
	first_decimal=number;
	
	return;
	
}



int scan_row(char row_nr)
{
	char row = 0x08 << row_nr;
	PORTC = row;
	asm volatile ("nop");
	asm volatile ("nop");
	return (PINC & 0x0f);
}

int scan_keypad()
{
	int temp = scan_row(4) | (scan_row(3)<<4) | (scan_row(2)<<8) | (scan_row(1)<<12);
	return temp; 
}

int scan_keypad_rising_edge()
{
	int first_scan = scan_keypad();
	_delay_ms(50);
	
	int second_scan = scan_keypad();
	
	int next_tmp_state = first_scan & second_scan;
	
	int final_result = next_tmp_state & ~(_tmp_);
	
	_tmp_=next_tmp_state;

	
	
	return final_result;
	
}

char keypad_to_ascii(int keypad)
{
	if((keypad&0x0001)==0x0001) return 'E';
	if((keypad&0x0002)==0x0002) return '0';
	if((keypad&0x0004)==0x0004) return 'F';
	if((keypad&0x0008)==0x0008) return 'D';
	if((keypad&0x0010)==0x0010) return '7';
	if((keypad&0x0020)==0x0020) return '8';
	if((keypad&0x0040)==0x0040) return '9';
	if((keypad&0x0080)==0x0080) return 'C';
	if((keypad&0x0100)==0x0100) return '4';
	if((keypad&0x0200)==0x0200) return '5';
	if((keypad&0x0400)==0x0400) return '6';
	if((keypad&0x0800)==0x0800) return 'B';
	if((keypad&0x1000)==0x1000) return '1';
	if((keypad&0x2000)==0x2000) return '2';
	if((keypad&0x4000)==0x4000) return '3';
	if((keypad&0x8000)==0x8000) return 'A';
	return 0x00;
	
}

char keypad_to_hex(int keypad)
{
	if((keypad&0x0001)==0x0001) return 0x0E;
	if((keypad&0x0002)==0x0002) return 0x00;
	if((keypad&0x0004)==0x0004) return 0x0F;
	if((keypad&0x0008)==0x0008) return 0x0D;
	if((keypad&0x0010)==0x0010) return 0x07;
	if((keypad&0x0020)==0x0020) return 0x08;
	if((keypad&0x0040)==0x0040) return 0x09;
	if((keypad&0x0080)==0x0080) return 0x0C;
	if((keypad&0x0100)==0x0100) return 0x04;
	if((keypad&0x0200)==0x0200) return 0x05;
	if((keypad&0x0400)==0x0400) return 0x06;
	if((keypad&0x0800)==0x0800) return 0x0B;
	if((keypad&0x1000)==0x1000) return 0x01;
	if((keypad&0x2000)==0x2000) return 0x02;
	if((keypad&0x4000)==0x4000) return 0x03;
	if((keypad&0x8000)==0x8000) return 0x0A;
	return 0xFF;
	
}

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
