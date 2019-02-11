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

# LED Matrix Layout
![alt text](https://github.com/Felix-Seip/ArduinoWordClock/blob/master/images/wiring-layout.png)
