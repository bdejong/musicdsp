Perfect LP4 filter
==================

- **Author or source:** rf.eerf@aipotreza
- **Type:** LP
- **Created:** 2008-03-13 10:40:46


.. code-block:: text
    :caption: notes

    hacked from the exemple of user script in FL Edison


.. code-block:: c++
    :linenos:
    :caption: code

    TLP24DB = class
    constructor create;
    procedure process(inp,Frq,Res:single;SR:integer);
    private
    t, t2, x, f, k, p, r, y1, y2, y3, y4, oldx, oldy1, oldy2, oldy3: Single;
    public outlp:single;
    end;
    ----------------------------------------
    implementation
    
    constructor TLP24DB.create;
    begin
      y1:=0;
      y2:=0;
      y3:=0;
      y4:=0;
      oldx:=0;
      oldy1:=0;
      oldy2:=0;
      oldy3:=0;
    end;
    procedure TLP24DB.process(inp: Single; Frq: Single; Res: Single; SR: Integer);
    begin
      f := (Frq+Frq) / SR;
      p:=f*(1.8-0.8*f);
      k:=p+p-1.0;
      t:=(1.0-p)*1.386249;
      t2:=12.0+t*t;
      r := res*(t2+6.0*t)/(t2-6.0*t);
      x := inp - r*y4;
      y1:=x*p + oldx*p - k*y1;
      y2:=y1*p+oldy1*p - k*y2;
      y3:=y2*p+oldy2*p - k*y3;
      y4:=y3*p+oldy3*p - k*y4;
      y4 := y4 - ((y4*y4*y4)/6.0);
      oldx := x;
      oldy1 := y1+_kd;
      oldy2 := y2+_kd;;
      oldy3 := y3+_kd;;
      outlp := y4;
    end;
    
    // the result is in outlp
    // 1/ call MyTLP24DB.Process
    // 2/then get the result from outlp.
    // this filter have a fantastic sound w/a very special res
    // _kd is the denormal killer value.

Comments
--------

- **Date**: 2008-10-20 07:44:35
- **By**: moc.liamg@321tiloen

.. code-block:: text

    This is basically a Moog filter.
    
    

- **Date**: 2010-09-16 23:07:30
- **By**: moc.liamG@0356orbratiug

.. code-block:: text

    Same as http://www.musicdsp.org/showArchiveComment.php?ArchiveID=24
    but seems to be in pascal.              

