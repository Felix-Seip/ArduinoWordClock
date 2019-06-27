#include "ClockElement.h"
#include "arduino.h"

ClockElement::ClockElement(){ }

ClockElement::ClockElement(int *numericValues, int from, int to, CLOCK_ELEMENT_TYPE type){
  _numericValues = numericValues;
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

int ClockElement::GetNumericValueAtIndex(int index) {
  return _numericValues[index];
}

int ClockElement::GetNumericValuesArrayLength() {
  return _to - _from;
}

CLOCK_ELEMENT_TYPE ClockElement::GetClockElementType(){
  return this->_type;  
}
