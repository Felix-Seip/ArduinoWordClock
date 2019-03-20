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

## Part List
This project uses a few different components in order to show the time in the LED matrix.
The following list is the part list required to recreate this word clock:
- 121 LEDs. The LEDs that should be used are LED strips. Each strip contains 11 LEDs. Since there are 11 rows, 121 LEDs are required
- DS1307 RTC. The RTC is used to control the LEDs and show the words on the clock
- DS18B20 Temperature Sensor. The sensor is used to display the temperature of the room that the clock is in
- GL5528 Photoresistor. The photoresistor is used to set the brightness of the LEDs depending on how bright it is in the room
- 1 x 10k Ohm Resistor
- 1 x 4.7k Ohm Resistor
- Arduino UNO or any other microcontroller with an ATMega328P chip
- HM-10 Bluetooth 4.0 Chip, available from DSD Tech on amazon.de

## LED Matrix Layout
The LED matrix that is used in this project is an 11 x 11 matrix. 
The LEDs are set up as follows:
11 LED strips. Each strip is one row for the matrix. 
Each LED strip contains 11 LEDs, thus the LED matrix is an 11 x 11.

The main entry point for the data and the power must be at the bottom left of the LED matrix. The data and power then travel from left to right, until reaching the last LED on the first strip. The next row is connected to the end of the first rows power, ground, and data pin, meaning that the second rows flow is from right to left. This continues all the way to the top where the last LED is at the top right of the LED matrix.

The layout looks like follows:
<br/>
<br/>
<img src="https://github.com/Felix-Seip/ArduinoWordClock/blob/master/images/matrix-layout.jpg" data-canonical-src="https://github.com/Felix-Seip/ArduinoWordClock/blob/master/images/matrix-layout.jpg" width="400" height="400" />

## Setting Up the Wiring 
<img src="https://github.com/Felix-Seip/ArduinoWordClock/blob/master/images/wiring-layout.png" data-canonical-src="https://github.com/Felix-Seip/ArduinoWordClock/blob/master/images/wiring-layout.png" width="400" height="400" />

The above image shows the way to set up the wiring for the electronic components of this clock. The DS1307 is connected to the Arduinos SDA and SCL pins, while also being powered through the 5v and ground pin on the Arduino. The LEDs are controlled using the Arduinos pin 5 and also connect to the 5v and ground pins.

## ClockElement class
The ClockElement class describes a numerical word on the clock. It contains the definition for the range of LEDs that need to be lit up to display the full word, the element type, either HOUR or MINUTE, and the numerical values that it represents it. The class is very minimal and covers the necessary words to describe the time. 

## How do I Get This Code Up and Running on My Own Word Clock?
After setting up the electronics for your word clock, as described above, all you have to do is clone this repository and open it in the Arduino IDE. Choose the board that you are using through the tools menu and select the correct USB port. After doing this, you can upload the code, like uploading every other code, by simply pressing the upload button. 

## Required Additional Libraries
This code uses a few etxernal libraries that made interfacing with the hardware easier. The following libraries need to be downloaded and placed into the Arduino IDEs library folder:
- https://github.com/PaulStoffregen/Time
- https://www.arduinolibraries.info/libraries/vector
- https://www.arduinolibraries.info/libraries/ds1307-rtc
- https://www.arduinolibraries.info/libraries/dallas-temperature
- https://www.arduinolibraries.info/libraries/one-wire
