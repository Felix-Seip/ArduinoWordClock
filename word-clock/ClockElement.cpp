#include "ClockElement.h"
#include "arduino.h"

ClockElement::ClockElement(){ }

ClockElement::ClockElement(int numericValueAM, int numericValuePM, int from, int to, CLOCK_ELEMENT_TYPE type){
  _numericValueAM = numericValueAM;
    _numericValuePM = numericValuePM;
  _from = from;
  _to = to;
  _type = type;
}

int ClockElement::GetRangeFrom(){
  return _from;  
}

int ClockElement::GetRangeTo(){
  return _to;  
}

int ClockElement::GetNumericValueAM() {
  return _numericValueAM;
}

int ClockElement::GetNumericValuePM() {
  return _numericValuePM;
}

int ClockElement::GetNumericValuesArrayLength() {
  return _to - _from;
}

CLOCK_ELEMENT_TYPE ClockElement::GetClockElementType(){
  return this->_type;  
}
