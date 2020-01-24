enum CLOCK_ELEMENT_TYPE{
  HOUR,
  MINUTE,
  WORD
};

class ClockElement {
  public:
    ClockElement();
    ClockElement(int numericValueAM, int numericValuePM, int from, int rangeTo, CLOCK_ELEMENT_TYPE type);
    int GetRangeFrom();
    int GetRangeTo();
    int GetNumericValueAM();
    int GetNumericValuePM();
    CLOCK_ELEMENT_TYPE GetClockElementType();
    int GetNumericValuesArrayLength();
    
  private:
    CLOCK_ELEMENT_TYPE _type;
    int _numericValueAM;
    int _numericValuePM;
    int _from;
    int _to;
    int _range;
}; 
