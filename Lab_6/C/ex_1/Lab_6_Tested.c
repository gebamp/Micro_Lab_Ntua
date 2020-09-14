/*
 * Lab_6.c
 *
 * Created: 12/10/2019 1:47:02 PM
 * Author : superminiala
 */ 

#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <string.h>
#include <stdlib.h>
char hun,dec,mon,sign;
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
void no_device(){
	lcd_command(0x02);
	lcd_data('N');
	lcd_data('O');
	lcd_data(' ');
	lcd_data('D');
	lcd_data('E');
	lcd_data('V');
	lcd_data('I');
	lcd_data('C');
	lcd_data('E');
	return;
}
void print_temp(unsigned char hun,unsigned char dec,unsigned char mon,unsigned char sign){
	lcd_command(0x02);
	lcd_data(sign);
	if(hun>0){
		lcd_data(hun+0x30);
	}
	lcd_data(dec+0x30);
	lcd_data(mon+0x30);
	lcd_data(0xb2);
	lcd_data('C');
	for(int i=0; i<4; i++){
		lcd_data(' ');
	}
	return;
}
void get_digits(char number){
	if(number>=100){
		hun++;
		number = number -100;
	}
	while(number >=10){
		dec++;
		number = number -10;
	}
	mon = number;
	return;
}
void usart_receive_string(char  *input_buffer){
	int i = 0;
	
	while(1){
	/*
	Mb check if first is S or F and then 
	determine how many bits you should read	*/	
		input_buffer[i] = usart_receive();
		// mb change '\n' to '\0'
		if(input_buffer[i] != '\n'){
			i++;
		}
		else{
			input_buffer[i] = '\0';
			break;
		}
	}
}

void  setup_teamname(){
	usart_transmit('t');
	usart_transmit('e');
	usart_transmit('a');
	usart_transmit('m');
	usart_transmit('n');
	usart_transmit('a');
	usart_transmit('m');
	usart_transmit('e');
	usart_transmit(':');
	usart_transmit('"');
	usart_transmit('G');
	usart_transmit('9');
	usart_transmit('"');
	usart_transmit('\n');
}
void setup_connection(){
	usart_transmit('c');
	usart_transmit('o');
	usart_transmit('n');
	usart_transmit('n');
	usart_transmit('e');
	usart_transmit('c');
	usart_transmit('t');
	usart_transmit('\n');	
}
void lcd_success(char number){
	lcd_command(0x02);
	lcd_data(number);
	lcd_data('.');
	lcd_data('S');
	lcd_data('u');
	lcd_data('c');
	lcd_data('c');
	lcd_data('e');
	lcd_data('s');
	lcd_data('s');
}
void lcd_fail(char number){
	lcd_command(0x02);
	lcd_data(number);
	lcd_data('.');
	lcd_data('F');
	lcd_data('a');
	lcd_data('i');
	lcd_data('l');
	lcd_data(' ');
	lcd_data(' ');
	lcd_data(' ');
}
void trasmit_temp_usart(char first_digit,char second_digit){
	usart_transmit('p');
	usart_transmit('a');
	usart_transmit('y');
	usart_transmit('l');
	usart_transmit('o');
	usart_transmit('a');
	usart_transmit('d');
	usart_transmit('[');
	usart_transmit('{');
	usart_transmit('"');
	usart_transmit('n');
	usart_transmit('a');
	usart_transmit('m');
	usart_transmit('e');
	usart_transmit('"');
	usart_transmit(':');
	usart_transmit('"');
	usart_transmit('T');
	usart_transmit('e');
	usart_transmit('m');
	usart_transmit('p');
	usart_transmit('e');
	usart_transmit('r');
	usart_transmit('a');
	usart_transmit('t');
	usart_transmit('u');
	usart_transmit('r');
	usart_transmit('e');
	usart_transmit('"');
	usart_transmit(',');
	usart_transmit('"');
	usart_transmit('v');
	usart_transmit('a');
	usart_transmit('l');
	usart_transmit('u');
	usart_transmit('e');
	usart_transmit('"');
	usart_transmit(':');
	usart_transmit(first_digit);
	usart_transmit(second_digit);
	usart_transmit('}');
	usart_transmit(']');
	usart_transmit('\n');
}
void setup_team_status(char flag){
	usart_transmit('r');
	usart_transmit('e');
	usart_transmit('a');
	usart_transmit('d');
	usart_transmit('y');
	usart_transmit(':');
	if(flag == 'T'){
	usart_transmit('t');
	usart_transmit('r');
	usart_transmit('u');
	usart_transmit('e');
	}
	else{
	usart_transmit('f');
	usart_transmit('a');
	usart_transmit('l');
	usart_transmit('s');
	usart_transmit('e');
	}
	usart_transmit('\n');
	return;
}
ISR(TIMER1_OVF_vect)
{   //Timer ISR when timer interrupts is set disable timer interrupts and turn off the leds of portb
	cli();
	char input_buffer[100];
	char team_number = keypad_to_ascii(scan_keypad_rising_edge());
	if(team_number=='9'){
		setup_team_status('T');
	}
	else{
		setup_team_status('F');
	}
	memset(input_buffer,0,sizeof(input_buffer));
	usart_receive_string(input_buffer);
	if(strcmp(input_buffer,"Success")!= 0){
		lcd_success('4');
	}
	else if(strcmp(input_buffer,"Fail")!= 0){
		lcd_fail('4');
	}
	TIMSK = (1<<TOIE1);
	TCCR1B = ((0<<CS12)|(1<<CS11)|(0<<CS10));
	TCNT1H = 0XFF;
	TCNT1L = 0XFB;
	sei();
}
int main(void)
{   unsigned char sign,magnitude,sign_ext;
	char input_buffer[100];
	char team_number;
	int temp;
	//input_buffer = temp_buffer;
	//char temp_buffer[100];	
	DDRD=0XFF;
	DDRC = 0xF0;
	usart_init();
	lcd_init();
	setup_teamname();
	memset(input_buffer,0,sizeof(input_buffer));
	usart_receive_string(input_buffer);
	if(strcmp(input_buffer,"Success") == 0){
		lcd_success('1');
	}
	else if(strcmp(input_buffer,"Fail") == 0){
		lcd_fail('1');
	}
	_delay_ms(1000);
	memset(input_buffer,0,sizeof(input_buffer));
	setup_connection();
	usart_receive_string(input_buffer);
	if(strcmp(input_buffer,"Success")== 0){
		lcd_success('2');
	}
	else if(strcmp(input_buffer,"Fail")== 0){
		lcd_fail('2');
	}
	_delay_ms(1000);
	memset(input_buffer,0,sizeof(input_buffer));
	/*
	TIMSK = (1<<TOIE1);
	TCCR1B = ((0<<CS12)|(1<<CS11)|(0<<CS10));
	TCNT1H = 0XFF;
	TCNT1L = 0XFB;
	sei();
	insert this after execution of volatile insturcions
	*/
     while (1) {
		_tmp_=0x0000;
	//Comment this out if you use interrupts
		cli();
		hun=0;
		mon=0;
		dec=0;
		sign = '+';
		temp = return_temp();
		if(temp == 0x8000){
			no_device();
		}
		else{
			sign_ext  = (temp >> 8) & 0x00FF;
			if(sign_ext ==  0xff){
				sign = '-';
			}
			magnitude = temp & 0x00FF;
			if(sign == '-'){
				magnitude = ~(magnitude);
				magnitude = magnitude + 1;
			}
			get_digits(magnitude); 
			trasmit_temp_usart(dec+0x30,mon+0x30);
			memset(input_buffer,0,sizeof(input_buffer));
			usart_receive_string(input_buffer);
			if(strcmp(input_buffer,"Success")== 0){
				lcd_success('3');
			}
			else if(strcmp(input_buffer,"Fail")== 0){
				lcd_fail('3');
			}	 	 
		} 
		_delay_ms(1000);
		//Comment the following lines out if you use interrupts
		sei();
		 
		team_number = keypad_to_ascii(scan_keypad_rising_edge());
		if(team_number=='9'){
			setup_team_status('T');
		}
		else{
			setup_team_status('F');
		}
		memset(input_buffer,0,sizeof(input_buffer));
		usart_receive_string(input_buffer);
		if(strcmp(input_buffer,"Success")== 0){
			lcd_success('4');
		}
		else if(strcmp(input_buffer,"Fail")== 0){
			lcd_fail('4');
		}
	}

}
