@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "Z:\Micro_Lab\Lab_3\Assembly\ex3_lab3\labels.tmp" -fI -W+ie -C V2E -o "Z:\Micro_Lab\Lab_3\Assembly\ex3_lab3\ex3_lab3.hex" -d "Z:\Micro_Lab\Lab_3\Assembly\ex3_lab3\ex3_lab3.obj" -e "Z:\Micro_Lab\Lab_3\Assembly\ex3_lab3\ex3_lab3.eep" -m "Z:\Micro_Lab\Lab_3\Assembly\ex3_lab3\ex3_lab3.map" "Z:\Micro_Lab\Lab_3\Assembly\ex3_lab3\ex3_lab3.asm"
