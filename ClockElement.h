enum CLOCK_ELEMENT_TYPE{
  HOUR,
  MINUTE,
  WORD
};

class ClockElement {
  public:
    ClockElement();
    ClockElement(int *numericValues, int from, int to, CLOCK_ELEMENT_TYPE type);
    int GetRangeFrom();
    int GetRangeTo();
    int GetNumericValueAtIndex(int index);
    CLOCK_ELEMENT_TYPE GetClockElementType();
    int GetNumericValuesArrayLength();
    
  private:
    CLOCK_ELEMENT_TYPE _type;
    int *_numericValues;
    int _from;
    int _to;
}; 
