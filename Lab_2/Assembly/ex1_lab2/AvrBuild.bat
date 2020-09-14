@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "F:\Microlab\Lab2\Tested\ex1_lab2\labels.tmp" -fI -W+ie -C V2E -o "F:\Microlab\Lab2\Tested\ex1_lab2\ex1_lab2.hex" -d "F:\Microlab\Lab2\Tested\ex1_lab2\ex1_lab2.obj" -e "F:\Microlab\Lab2\Tested\ex1_lab2\ex1_lab2.eep" -m "F:\Microlab\Lab2\Tested\ex1_lab2\ex1_lab2.map" "F:\Microlab\Lab2\Tested\ex1_lab2\ex1_lab2.asm"
