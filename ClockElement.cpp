#include "ClockElement.h"

ClockElement::ClockElement(){ }

ClockElement::ClockElement(int *numericValues, int from, int to, CLOCK_ELEMENT_TYPE type){
  this->_numericValues = numericValues;
  this->_from = from;
  this->_to = to;
  this->_type = type;
}

int ClockElement::GetRangeFrom(){
  return this->_from;  
}

int ClockElement::GetRangeTo(){
  return this->_to;  
}

int ClockElement::GetNumericValueAtIndex(int index) {
  return this->_numericValues[index];
}

int ClockElement::GetNumericValuesArrayLength() {
  return (sizeof(this->_numericValues) / sizeof(*(this->_numericValues)));
}

CLOCK_ELEMENT_TYPE ClockElement::GetClockElementType(){
  return this->_type;  
}
