Float to int (more intel asm)
=============================

- **Author or source:** Laurent de Soras (via flipcode)
- **Created:** 2004-06-14 14:51:47


.. code-block:: text
    :caption: notes

    [Found this on flipcode, seemed worth posting here too, hopefully Laurent will approve :)
    -- Ross]
    
    Here is the code I often use. It is not a _ftol replacement, but it provides useful
    functions. The current processor rounding mode should be "to nearest" ; it is the default
    setting for most of the compilers.
    
    The [fadd st, st (0) / sar i,1] trick fixes the "round to nearest even number" behaviour.
    Thus, round_int (N+0.5) always returns N+1 and floor_int function is appropriate to
    convert floating point numbers into fixed point numbers.
    
    ---------------------
    
    Laurent de Soras
    Audio DSP engineer & software designer
    Ohm Force - Digital audio software
    http://www.ohmforce.com
    


.. code-block:: c++
    :linenos:
    :caption: code

    inline int round_int (double x)
    {
       int      i;
       static const float round_to_nearest = 0.5f;
       __asm
       {
          fld      x
          fadd     st, st (0)
          fadd     round_to_nearest
          fistp    i
          sar      i, 1
       }
    
       return (i);
    }
    
    inline int floor_int (double x)
    {
       int      i;
       static const float round_toward_m_i = -0.5f;
       __asm
    	{
          fld      x
          fadd     st, st (0)
          fadd     round_toward_m_i
          fistp    i
          sar      i, 1
       }
    
       return (i);
    }
    
    inline int ceil_int (double x)
    {
       int      i;
       static const float round_toward_p_i = -0.5f;
       __asm
       {
          fld      x
          fadd     st, st (0)
          fsubr    round_toward_p_i
          fistp    i
          sar      i, 1
       }
    
       return (-i);
    }
    

Comments
--------

- **Date**: 2004-06-15 07:29:25
- **By**: daniel.schaack[-dot-]basementarts.de

.. code-block:: text

    cool trick, but using round to zero FPU mode is still the best methode (2 lines):
    
    __asm
    {
     fld x
     fistp y 
    }       

- **Date**: 2004-06-18 01:28:41
- **By**: moc.krod@dje

.. code-block:: text

    If anyone is using NASM, here is how I implemented the first function, if anyone is interested.  I did this after sitting down for a while with the intel manuals.  I've not done any x86-FPU stuff before, so this may not be the *best* code.  The other functions are easily implemented by modifying this one.
    
    bits 32
    global dsp_round
    
    HALF dq 0.5
    
    align 4
    dsp_round:
    	fld qword[HALF]		
    	fld qword[esp+4]
    	
    	fadd st0
    	fadd st1
    	
    	fistp qword[eax]
    	mov eax, [eax]
    	sar eax, 1
    	ret

- **Date**: 2004-06-18 13:48:09
- **By**: moc.krod@dje

.. code-block:: text

    Whoops.  I've really gone and embarassed myself this time.  The code I posted is actually broken -- I don't know what I was thinking.  I'll post the fixed version a bit later today.  My appologies.

- **Date**: 2004-08-10 10:29:44
- **By**: pj.krowtenctu@remmah

.. code-block:: text

    Will this method also work for other processor types like AMD and CELERON?
    

- **Date**: 2007-02-19 11:13:19
- **By**: uh.etle.fni@yfoocs

.. code-block:: text

    It works with AMD and Celeron too (and as I know, probably with all x87 FPUs)            

