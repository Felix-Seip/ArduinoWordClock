# ArduinoWordClock
A code repository for an arduino word clock

This project was inspired by the QlockTwo word clock, which is uses the same basic code logic.
Currently, the only language that is supported with this repository is German. 
This is due to the layout of the LED matrix and the hardcoded position of the LEDs in the code.

However, this code can be used a basis of any word clock with an 11 x 11 LED matrix.

The main file for this clock is the .ino file, which is the main file that runs on the Arduino.
The other files, define a class that represent a word on the clock. 
These words include the words for the hours and minutes. 
The other words such as "vor" and "nach" are hard coded.

#Part List
This project uses a few different components in order to show the time in the LED matrix.
The following list is the part list required to recreate this word clock:
- 121 LEDs. The LEDs that should be used are LED strips. Each strip contains 11 LEDs. Since there are 11 rows, 121 LEDs are required
- DS3231 RTC. The RTC is used to control the LEDs and show the words on the clock
- Arduino UNO or any other microcontroller with an ATMega328P chip

# LED Matrix Layout
The LED matrix that is used in this project is an 11 x 11 matrix. 
The LEDs are set up as follows:
11 LED strips. Each strip is one row for the matrix. 
Each LED strip contains 11 LEDs, thus the LED matrix is an 11 x 11.

The above described layout looks as follows:


#Setting Up the Wiring 
<img src="https://github.com/Felix-Seip/ArduinoWordClock/blob/master/images/wiring-layout.png" data-canonical-src="https://github.com/Felix-Seip/ArduinoWordClock/blob/master/images/wiring-layout.png" width="400" height="400" />
