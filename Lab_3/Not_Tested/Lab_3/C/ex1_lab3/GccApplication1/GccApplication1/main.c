#define  F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

int _tmp_=0x0000;
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
	if((keypad&0x0001)==0x0001) return '*';
	if((keypad&0x0002)==0x0002) return '0';
	if((keypad&0x0004)==0x0004) return '#';
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

int main(void){
	unsigned int  first_key , second_key;

	DDRB = 0xFF;
	DDRC = 0xF0;
	while(1){
		_tmp_=0x0000;
		while((first_key = keypad_to_ascii(scan_keypad_rising_edge())) == 0x00);
		while((second_key = keypad_to_ascii(scan_keypad_rising_edge())) == 0x00);
		if(first_key == '0' && second_key=='9'){
			PORTB = 0XFF;
			_delay_ms(4000);
			PORTB = 0X00;
		}
		else{
			for(int i=0;i<8;i++){
				PORTB =0XFF;
				_delay_ms(250);
				PORTB = 0X00;
				_delay_ms(250);
			}
		}
	}
}
