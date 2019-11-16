@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "E:\Lab_3\avr_lab_3_dec\labels.tmp" -fI -W+ie -C V2E -o "E:\Lab_3\avr_lab_3_dec\avr_lab_3_dec.hex" -d "E:\Lab_3\avr_lab_3_dec\avr_lab_3_dec.obj" -e "E:\Lab_3\avr_lab_3_dec\avr_lab_3_dec.eep" -m "E:\Lab_3\avr_lab_3_dec\avr_lab_3_dec.map" "E:\Lab_3\avr_lab_3_dec\avr_lab_3_dec.asm"
