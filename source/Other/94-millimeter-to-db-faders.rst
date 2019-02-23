Millimeter to DB (faders...)
============================

- **Author or source:** James McCartney
- **Created:** 2002-04-09 16:55:26


.. code-block:: text
    :caption: notes

    These two functions reproduce a traditional professional
    mixer fader taper.
    
    MMtoDB converts millimeters of fader travel from the
    bottom of the fader for a 100 millimeter fader into
    decibels. DBtoMM is the inverse.
    
    The taper is as follows from the top:
    The top of the fader is +10 dB
    100 mm to 52 mm : -5 dB per 12 mm
    52 mm to 16 mm : -10 dB per 12 mm
    16 mm to 4 mm : -20 dB per 12 mm
    4 mm to 0 mm : fade to zero. (in these functions I go to -200dB
    which is effectively zero for up to 32 bit audio.)


.. code-block:: c++
    :linenos:
    :caption: code

    float MMtoDB(float mm)
    {
            float db;
    
            mm = 100. - mm;
    
            if (mm <= 0.) {
                    db = 10.;
            } else if (mm < 48.) {
                    db = 10. - 5./12. * mm;
            } else if (mm < 84.) {
                    db = -10. - 10./12. * (mm - 48.);
            } else if (mm < 96.) {
                    db = -40. - 20./12. * (mm - 84.);
            } else if (mm < 100.) {
                    db = -60. - 35. * (mm - 96.);
            } else db = -200.;
            return db;
    }
    
    float DBtoMM(float db)
    {
            float mm;
            if (db >= 10.) {
                    mm = 0.;
            } else if (db > -10.) {
                    mm = -12./5. * (db - 10.);
            } else if (db > -40.) {
                    mm = 48. - 12./10. * (db + 10.);
            } else if (db > -60.) {
                    mm = 84. - 12./20. * (db + 40.);
            } else if (db > -200.) {
                    mm = 96. - 1./35. * (db + 60.);
            } else mm = 100.;
    
            mm = 100. - mm;
    
            return mm;
    }

Comments
--------

- **Date**: 2004-01-29 21:31:18
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    Pascal Translation...
    
    function MMtoDB(Milimeter:Single):Single;
    var mm: Single;
    begin
      mm:=100-Milimeter;
      if mm = 0 then Result:=10
      else if mm < 48 then Result:=10-5/12*mm;
      else if mm < 84 then Result:=-10-10/12*(mm-48);
      else if mm < 96 then Result:=-40-20./12*(mm-84);
      else if mm < 100 then Result:=-60-35*(mm-96);
      else Result:=-200.;
    end;
    
    function DBtoMM(db:Single):Single;
    begin
      if db>=10 then result:=0;
      else if db>-10 then result:=-12/5*(db-10);
      else if db>-40 then result:=48-12/10(db+10);
      else if db>-60 then result:=84-12/20(db+40);
      else if db>-200 then result:=96-1/35(db+60);
      else result:=100.;
      Result:=100-Result;
    end;             

- **Date**: 2010-03-11 22:31:06
- **By**: moc.liamg@rellomehcssih.retuow

.. code-block:: text

    Flash ActionScript translation:
    
    /**
     * Maps normalized value between 0 and 1 to decibel from -200 to 10.
     * @param normalizedValue: Value between 0 and 1.
     * @return Number: Value in decibel from -200 to 10.
     */
    public function normalizedToDecibel(value : Number) : Number
    {
    	value = (1 - value) * 100;
    
    	if(value <= 0.0) var db : Number = 10.0;
    	else if(value < 48.0) db = 10.0 - 5.0 / 12.0 * value;
    	else if(value < 84.0) db = -10.0 - 10.0 / 12.0 * (value - 48.0);
    	else if(value < 96.0) db = -40.0 - 20.0 / 12.0 * (value - 84.0);
    	else if(value < 100.0) db = -60.0 - 35.0 * (value - 96.0);
    	else db = -200.0;
    	
    	return db;
    }
    
    /**
     * Maps decibel from -200 to 10 to normalized value between 0 and 1.
     * @param decibel: Value in decibel from -200 to 10.
     * @return Number: 
     */
    public function decibelToNormalized(decibel : Number) : Number
    {
    	if(decibel >= 10.0) var normalizedValue : Number = 0.0;
    	else if (decibel > -10.0) normalizedValue = -12.0 / 5.0 * (decibel - 10.0);
    	else if (decibel > -40.0) normalizedValue = 48.0 - 12.0 / 10.0 * (decibel + 10.0);
    	else if (decibel > -60.0) normalizedValue = 84.0 - 12.0 / 20.0 * (decibel + 40.0);
    	else if (decibel > -200.0) normalizedValue = 96.0 - 1.0 / 35.0 * (decibel + 60.0);
    	else normalizedValue = 100.0;
    	
    	return (100.0 - normalizedValue) / 100.0;
    }

