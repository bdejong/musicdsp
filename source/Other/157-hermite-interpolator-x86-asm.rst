Hermite Interpolator (x86 ASM)
==============================

- **Author or source:** moc.oiduacbr@kileib.trebor
- **Type:** Hermite interpolator in x86 assembly (for MS VC++)
- **Created:** 2004-04-07 09:38:32


.. code-block:: text
    :caption: notes

    An "assemblified" variant of Laurent de Soras hermite interpolator. I tried to do
    calculations as parallell as I could muster, but there is almost certainly room for
    improvements. Right now, it works about 5.3 times (!) faster, not bad to start with...
    
    Parameter explanation:
    frac_pos: fractional value [0.0f - 1.0f] to interpolator
    pntr: pointer to float array where:
        pntr[0] = previous sample (idx = -1)
        pntr[1] = current sample (idx = 0)
        pntr[2] = next sample (idx = +1)
        pntr[3] = after next sample (idx = +2)
    
    The interpolation takes place between pntr[1] and pntr[2].
    
    Regards,
    /Robert Bielik
    RBC Audio
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    const float c_half = 0.5f;
    
    __declspec(naked) float __hermite(float frac_pos, const float* pntr)
    {
    	__asm
    	{
    		push	ecx;		
    		mov		ecx, dword ptr[esp + 12]; //////////////////////////////////////////////////////////////////////////////////////////////////
    		add		ecx, 0x04;			//	ST(0)		ST(1)		ST(2)		ST(3)		ST(4)		ST(5)		ST(6)		ST(7)		
    		fld		dword ptr [ecx+4];	//	x1
    		fsub	dword ptr [ecx-4];	//	x1-xm1
    		fld		dword ptr [ecx];	//	x0			x1-xm1
    		fsub	dword ptr [ecx+4];	//	v			x1-xm1
    		fld		dword ptr [ecx+8];	//	x2			v			x1-xm1
    		fsub	dword ptr [ecx];	//	x2-x0		v			x1-xm1
    		fxch	st(2);				//	x1-m1		v			x2-x0
    		fmul	c_half;				//	c			v			x2-x0
    		fxch	st(2);				//	x2-x0		v			c
    		fmul	c_half;				//	0.5*(x2-x0)	v			c
    		fxch	st(2);				//	c			v			0.5*(x2-x0)
    		fst		st(3);				//	c			v			0.5*(x2-x0)	c
    		fadd	st(0), st(1);		//	w			v			0.5*(x2-x0)	c
    		fxch	st(2);				//	0.5*(x2-x0)	v			w			c	
    		faddp	st(1), st(0);		//  v+.5(x2-x0)	w			c	
    		fadd	st(0), st(1);		//	a			w			c
    		fadd	st(1), st(0);		//	a			b_neg		c
    		fmul	dword ptr [esp+8];	//	a*frac		b_neg		c
    		fsubp	st(1), st(0);		//	a*f-b		c
    		fmul	dword ptr [esp+8];	//	(a*f-b)*f	c
    		faddp	st(1), st(0);		//	res-x0/f
    		fmul	dword ptr [esp+8];	//	res-x0
    		fadd	dword ptr [ecx];	//	res
    		pop		ecx;
    		ret;
    	}
    }
    

Comments
--------

- **Date**: 2003-11-27 04:53:16
- **By**: dmi@smartelectronix

.. code-block:: text

    This code produces a nasty buzzing sound.  I think there might be a bug somwhere but I haven't found it yet.            

- **Date**: 2003-11-29 16:41:41
- **By**: gro.lortnocdnim@psdcisum-sulph

.. code-block:: text

    I agree; the output, when plotted, looks like it has overlaid rectangular shapes on it.

- **Date**: 2003-12-02 21:18:57
- **By**: moc.oiduacbr@kileib.trebor

.. code-block:: text

    AHH! True! A bug has sneaked in! Change the row that says:
    fsubp st(1), st(0); // a*f-b c
    to:
    fsubrp st(1), st(0); // a*f-b c
    
    and it should be much better. Although I noticed that a good optimization by the compiler generates nearly as fast a code, but only nearly. This is still about 10% faster. 

- **Date**: 2004-09-07 02:24:34
- **By**: moc.enecslatnemirepxe@renrewd

.. code-block:: text

    I have tested the four hermite interpolation algorithms posted to musicdsp.org plus the assemblified version of 
    
    Laurent de Soras' code by Robert Bielik and found that on a Pentium 4 with full optimization (targeting the 
    
    Pentium 4 and above, but not using code that won't work on older processors) with MS VC++ 7 that the second 
    
    function is the fastest.
    
    
    Function    Percent Total    Time    Return Value
    
    hermite1:   18.90%,          375ms,  0.52500004f
    hermite2:   16.53%,          328ms,  0.52500004f
    hermite3:   17.34%,          344ms,  0.52500004f
    hermite4:   19.66%,          390ms,  0.52500004f
    hermite5:   27.57%,          547ms,  0.52500004f
    
    - Daniel Werner
    http://experimentalscene.com/

