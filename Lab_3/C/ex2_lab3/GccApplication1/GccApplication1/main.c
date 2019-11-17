#define  F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

unsigned char keypad[2];
unsigned int previous_state;
unsigned char scan_row(int line){
	unsigned char switch_state;
	unsigned char r25 = (1 << 3);
	r25 = (r25 << line);
	PORTC = r25;
	asm volatile(
	"nop" "\n"
	"nop" "\n");
	switch_state = PINC;
	return  (switch_state && 0x0F);
}
void  scan_keypad(){
	unsigned char first_line,second_line,third_line,fourth_line;
	unsigned char first_and_second, third_and_fourth;
	// Scan the first and second lines and store the output in keypad[1] global variable
	first_line  = scan_row(1);
	first_line  = (first_line  & 0x0F) << 4 ;
	second_line = scan_row(2);
	second_line = (second_line & 0x0F);
	first_and_second = first_line | second_line;
	keypad[1]  = first_and_second;
	// Scan the third and fourth lines and store the output in keypad[0] global variable
	third_line  = scan_row(3);
	third_line  = (third_line  & 0x0F) << 4;
	fourth_line = scan_row(4);
	fourth_line = (fourth_line & 0x0F);
	third_and_fourth = third_line | fourth_line ;
	keypad[0] = third_and_fourth;
}
int scan_keypad_rising_edge(){
	int final_output;
	unsigned int temp_2_output_1,temp_2_output_2;
	unsigned int temp_final_output_2,temp_final_output,temp_output_1,temp_output_2;
	unsigned char save_keyboard[2],save_keyboard_2[2];
	// Scan keyboard for the first time
	scan_keypad();
	save_keyboard[0] = keypad[0];
	save_keyboard[1] = keypad[1];
	temp_output_1 = save_keyboard[1] << 8;
	temp_output_2 = save_keyboard[0];
	// Join the output of the final in one integer(16 bit)
	temp_final_output =( temp_output_1 | temp_output_2 );

	// Delay for debouncing effect
	_delay_ms(0x0A);

	// Scan keypad again
	scan_keypad();
	save_keyboard_2[0] = keypad[0];
	save_keyboard_2[1] = keypad[1];
	temp_2_output_1 = save_keyboard_2[1] << 8;
	temp_2_output_2 = save_keyboard_2[0];
	// Join the output of the second scan  in one integer(16 bit)
	temp_final_output_2 =( temp_2_output_1 | temp_2_output_2 );

	// Decline  debouncing keys
	temp_final_output_2 = temp_final_output & temp_final_output;
	// Load previous state in registers
	temp_final_output = previous_state;
	// Refresh previous state with fresh pushed keys
	previous_state = temp_output_2;
	// Reverse previous state
	temp_final_output = ~temp_final_output;
	// Find just presed keys
	final_output = temp_final_output & temp_final_output_2;
return final_output;}

unsigned char keypad_to_ascii(){
	if((keypad[0] & 0x01) ==  0x01){
	return '*';}
	if((keypad[0] & 0x02) ==  0x02){
	return '0';}
	if((keypad[0] & 0x04) ==  0x04){
	return '#';}
	if((keypad[0] & 0x08) ==  0x08){
	return 'D';}
	if((keypad[0] & 0x10) ==  0x10){
	return '7';}
	if((keypad[0] & 0x20) ==  0x20){
	return '8';}
	if((keypad[0] & 0x40) ==  0x40){
	return '9';}
	if((keypad[0] & 0x80) ==  0x80){
	return 'C';}
	if((keypad[1] & 0x01) ==  0x01){
	return '4';}
	if((keypad[1] & 0x02) ==  0x02){
	return '5';}
	if((keypad[1] & 0x04) ==  0x04){
	return '6';}
	if((keypad[1] & 0x08) ==  0x08){
	return 'B';}
	if((keypad[1] & 0x10) ==  0x10){
	return '1';}
	if((keypad[1] & 0x20) ==  0x20){
	return '2';}
	if((keypad[1] & 0x40) ==  0x40){
	return '3';}
	if((keypad[1] & 0x80) ==  0x80){
	return 'A';}
return 0x00;}

unsigned char keypad_to_hex(){
	if((keypad[0] & 0x01) ==  0x01){
	return 0x0E;}
	if((keypad[0] & 0x02) ==  0x02){
	return 0x00;}
	if((keypad[0] & 0x04) ==  0x04){
	return 0x0F;}
	if((keypad[0] & 0x08) ==  0x08){
	return 0x0D;}
	if((keypad[0] & 0x10) ==  0x10){
	return 0x07;}
	if((keypad[0] & 0x20) ==  0x20){
	return 0x08;}
	if((keypad[0] & 0x40) ==  0x40){
	return 0x09;}
	if((keypad[0] & 0x80) ==  0x80){
	return 0x0C;}
	if((keypad[1] & 0x01) ==  0x01){
	return 0x04;}
	if((keypad[1] & 0x02) ==  0x02){
	return 0x05;}
	if((keypad[1] & 0x04) ==  0x04){
	return 0x06;}
	if((keypad[1] & 0x08) ==  0x08){
	return 0x0B;}
	if((keypad[1] & 0x10) ==  0x10){
	return 0x01;}
	if((keypad[1] & 0x20) ==  0x20){
	return 0x02;}
	if((keypad[1] & 0x40) ==  0x40){
	return 0x03;}
	if((keypad[1] & 0x80) ==  0x80){
	return 0x0A;}
return 0x00;}

void write_2_nibbles(unsigned char input)
{   unsigned char r25,low_nibble;
	unsigned char first_input,second_input,low_to_high_nibble;
	r25 = (PIND & 0X0F);
	// Get the 4 msb of input and send to Port_D
	first_input = (input & 0xF0) + r25;
	PORTD = first_input;
	PORTD = (1 << PD3);
	PORTD = (0 << PD3);
	//Get the 4 lsb and send them to portd as msb
	low_nibble =  input & 0x0F;
	low_to_high_nibble = (low_nibble <<4);
	second_input = low_to_high_nibble + r25;
	PORTD = second_input;
	PORTD = (1 << PD3);
	PORTD = (0 << PD3);
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
	PORTD = (1 << PD3);
	PORTD = (0 << PD3);
	_delay_us(39);

	PORTD = 0x30;
	PORTD = (1 << PD3);
	PORTD = (0 << PD3);
	_delay_us(39);


	PORTD = 0x20;
	PORTD = (1 << PD3);
	PORTD = (0 << PD3);
	_delay_us(39);

	lcd_command(0x28);
	lcd_command(0x0c);
	lcd_command(0x01);
	_delay_us(1530);
	
	lcd_command(0x06);
	return ;
}
int main(void){
	unsigned int  first_key, second_key;
	unsigned char first_number,second_number;
	unsigned char first_number_in_hex,second_number_in_hex,final_number_in_hex;
	unsigned char ekatondades=0,dekades=0,monades=0,sign;
	DDRB = 0xFF;
	DDRC = 0xF0;
	lcd_init();
	while(1){
		previous_state = 0x0000;
		do{
			first_key = scan_keypad_rising_edge();
			keypad[0] = first_key & 0x00FF;
			keypad[1] = ( (first_key & 0xFF00 >> 8) & 0x00FF);
			first_number = keypad_to_ascii();
			first_number_in_hex = keypad_to_hex();
		}while(first_number==0x00);
		do{
			//isos thelei ena temp save
			second_key = scan_keypad_rising_edge();
			keypad[0] = second_key & 0x00FF;
			keypad[1] = ( (second_key & 0xFF00 >> 8) & 0x00FF);
			second_number = keypad_to_ascii();
			second_number_in_hex = keypad_to_hex();
		}while(second_number==0x00);
		lcd_command(0x01);
		// lcd_init();
		lcd_data(first_number);
		lcd_data(second_number);
		lcd_data('=');
		first_number_in_hex = ( first_number_in_hex << 4);
		final_number_in_hex = first_number_in_hex | second_number_in_hex;
		if((final_number_in_hex & 0x80) == 0x80){
			sign = '-' ;
		}
		else{
			sign = '+' ;
		}
		while(final_number_in_hex>=10){
			if(final_number_in_hex >=100){
				ekatondades = 1;
				final_number_in_hex = final_number_in_hex -100;
			}
			else{
				dekades++;
				final_number_in_hex = final_number_in_hex -10;

			}
		}
		ekatondades = ekatondades + 48;
		dekades = dekades + 48;
		monades = final_number_in_hex + 48;
		lcd_data(sign);
		lcd_data(ekatondades);
		lcd_data(dekades);
		lcd_data(monades);

	}
}