@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "E:\Lab_3\ex2_lab3\labels.tmp" -fI -W+ie -C V2E -o "E:\Lab_3\ex2_lab3\ex2_lab3.hex" -d "E:\Lab_3\ex2_lab3\ex2_lab3.obj" -e "E:\Lab_3\ex2_lab3\ex2_lab3.eep" -m "E:\Lab_3\ex2_lab3\ex2_lab3.map" "E:\Lab_3\ex2_lab3\ex2_lab3.asm"
