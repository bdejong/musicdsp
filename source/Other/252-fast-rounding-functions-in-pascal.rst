Fast rounding functions in pascal
=================================

- **Author or source:** moc.liamtoh@abuob
- **Type:** round/ceil/floor/trunc
- **Created:** 2008-03-09 13:09:44


.. code-block:: text
    :caption: notes

    Original documentation with cpp samples:
    http://ldesoras.free.fr/prod.html#doc_rounding


.. code-block:: c++
    :linenos:
    :caption: code

    Pascal translation of the functions (accurates ones) :
    
    function ffloor(f:double):integer;
    var
      i:integer;
      t : double;
    begin
    t := -0.5 ;
      asm
        fld   f
        fadd  st,st(0)
        fadd  t
        fistp i
        sar   i, 1
    end;
    result:= i
    end;
    
    function fceil(f:double):integer;
    var
      i:integer;
      t : double;
    begin
    t := -0.5 ;
      asm
        fld   f
        fadd  st,st(0)
        fsubr t
        fistp i
        sar   i, 1
    end;
    result:= -i
    end;
    
    function ftrunc(f:double):integer;
    var
      i:integer;
      t : double;
    begin
    t := -0.5 ;
      asm
        fld   f
        fadd  st,st(0)
        fabs
        fadd t
        fistp i
        sar   i, 1
    end;
    if f<0 then i := -i;
    result:= i
    end;
    
    function fround(f:double):integer;
    var
      i:integer;
      t : double;
    begin
    t := 0.5 ;
      asm
        fld   f
        fadd  st,st(0)
        fadd t
        fistp i
        sar   i, 1
    end;
    result:= i
    end;

Comments
--------

- **Date**: 2008-04-23 11:46:58
- **By**: eb.mapstenykson@didid

.. code-block:: text

    the fround doesn't make much sense in Pascal, as in Pascal (well, Delphi & I'm pretty sure FreePascal too), the default rounding is already a fast rounding. The default being FPU rounding to nearest mode, the compiler doesn't change it back & forth. & since it's inlined (well, compiler magic), it's very fast. 

