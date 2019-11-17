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
unsigned int scan_keypad_rising_edge(){
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


int main(void){
	unsigned int  first_key , second_key;
	unsigned char first_number=0x00,second_number=0x00;
	DDRB = 0xFF;
	DDRC = 0xF0;
	while(1){
		previous_state = 0x0000;
		do{
			first_key = scan_keypad_rising_edge();
			keypad[0] = first_key & 0x00FF;
			keypad[1] = first_key & 0xFF00;
			first_number = keypad_to_ascii();
		}while(first_number==0x00);
		do{
			//isos thelei ena temp save
			second_key = scan_keypad_rising_edge();
			keypad[0] = second_key & 0x00FF;
			keypad[1] = second_key & 0xFF00;
			second_number = keypad_to_ascii();
		}while(second_number==0x00);
		if(first_number == '0' && second_number=='9'){
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
