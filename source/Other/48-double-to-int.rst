Double to Int
=============

- **Author or source:** many people, implementation by Andy M00cho
- **Type:** pointer cast (round to zero, or 'trunctate')
- **Created:** 2002-01-17 03:04:41


.. code-block:: text
    :caption: notes

    -Platform independant, literally. You have IEEE FP numbers, this will work, as long as
    your not expecting a signed integer back larger than 16bits :)
    -Will only work correctly for FP numbers within the range of [-32768.0,32767.0]
    -The FPU must be in Double-Precision mode


.. code-block:: c++
    :linenos:
    :caption: code

    typedef double lreal;
    typedef float  real;
    typedef unsigned long uint32;
    typedef long int32;
    
       //2^36 * 1.5, (52-_shiftamt=36) uses limited precision to floor
       //16.16 fixed point representation
    
    const lreal _double2fixmagic = 68719476736.0*1.5;
    const int32 _shiftamt        = 16;
    
    #if BigEndian_
            #define iexp_                           0
            #define iman_                           1
    #else
            #define iexp_                           1
            #define iman_                           0
    #endif //BigEndian_
    
    // Real2Int
    inline int32 Real2Int(lreal val)
    {
       val= val + _double2fixmagic;
       return ((int32*)&val)[iman_] >> _shiftamt;
    }
    
    // Real2Int
    inline int32 Real2Int(real val)
    {
       return Real2Int ((lreal)val);
    }
    
    For the x86 assembler freaks here's the assembler equivalent:
    
    __double2fixmagic    dd 000000000h,042380000h
    
    fld    AFloatingPoint Number
    fadd   QWORD PTR __double2fixmagic
    fstp   TEMP
    movsx  eax,TEMP+2

Comments
--------

- **Date**: 2007-01-28 20:13:49
- **By**: ude.odu@grebnesie.nitram

.. code-block:: text

    www.stereopsis.com/FPU.html credits one Sree Kotay for this code.

- **Date**: 2007-07-11 06:17:12
- **By**: kd.sgnik3@sumsar

.. code-block:: text

    On PC this may be faster/easier:
    
    int ftoi(float x)
    {
      int res;
      __asm
      {
        fld x
        fistp res
      }
      return res;
    }
    
    int dtoi(double x)
    {
      return ftoi((float)x);
    }
    

