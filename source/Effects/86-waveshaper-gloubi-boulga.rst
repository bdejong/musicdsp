Waveshaper :: Gloubi-boulga
===========================

- **Author or source:** Laurent de Soras on IRC
- **Created:** 2002-03-17 15:40:13


.. code-block:: text
    :caption: notes

    Multiply input by gain before processing


.. code-block:: c++
    :linenos:
    :caption: code

    const double x = input * 0.686306;
    const double a = 1 + exp (sqrt (fabs (x)) * -0.75);
    output = (exp (x) - exp (-x * a)) / (exp (x) + exp (-x));

Comments
--------

- **Date**: 2004-09-25 21:42:39
- **By**: ten.etelirt@gnihtliam

.. code-block:: text

    you can use a taylor series approximation for the exp , save time by realizing that
    exp(-x) = 1/exp(x), use newton's method to calculate the sqrt with less precision...
    and if you use SIMD instructions, you can calculate several values in parallel. dunno
    what the savings would be like, but it would surely be faster.

- **Date**: 2005-05-25 22:32:21
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: delphi

    // Maybe something like this:
    
    function GloubiBoulga(x:Single):Single;
    var a,b:Single;
    begin
     x:=x*0.686306;
     a:=1+exp(sqrt(f_abs(x))*-0.75);
     b:=exp(x);
     Result:=(b-exp(-x*a))*b/(b*b+1);
    end;
    
    still expensive, but...

- **Date**: 2005-05-28 00:49:48
- **By**: ed.luosfosruoivas@naitsirhC

.. code-block:: text

    A Taylor series doesn't work very well, because the approximation effects the result very early due to
    a) numerical critical additions & subtractions of approximations
    b) approximating approximated "a" makes the result evene more worse.
    
    The above version has already been improved, by removing 2 of 5 exp() functions.
    
    You can also try to express the exp(x)+exp(-x) as cosh(x) with its approximation. So:
    
    b:=exp(x);
    Result:=(b-exp(-x*a))*b/(b*b+1);
    
    would be:
    
    Result:=(exp(x)-exp(-x*a))*20160/40320+x*x*(20160+ x*x*(1680+x*x*(56+x*x)));
    
    but this is again more worse. Anyone else?

- **Date**: 2005-09-13 09:55:55
- **By**: llun.ved@regguHwodahS

.. code-block:: text

    Use table lookup with interpolation. 

- **Date**: 2005-09-22 01:07:58
- **By**: ten.baltg@liced

.. code-block:: text

    IMHO, you can use
    x - 0.15 * x^2 - 0.15 * x^3
    instead of this scary formula.
    
    I try to explain my position with this small graph:
    http://liteprint.com/download/replacment.png
    
    This is only first step, if you want to get more correct result you can use interpolation
    method called method of minimal squares (this is translation from russian, maybe in england
    it has another name)

- **Date**: 2005-09-22 07:19:07
- **By**: ku.oc.snosrapsd@psdcisum

.. code-block:: text

    That's much better decil - thx for that!
    
    DSP

- **Date**: 2005-09-22 11:05:07
- **By**: ten.baltg@liced

.. code-block:: text

    You are welcome :)
    
    Now I've working under plugin with wapeshapping processing like this. I've put a link to it
    here, when I've done it.

- **Date**: 2005-09-24 01:15:38
- **By**: ten.baltg@liced

.. code-block:: text

    You can check my version:
    http://liteprint.com/download/SweetyVST.zip 
    
    Please, send comments and suggestions to my email.
    
    Dmitry.
    

- **Date**: 2005-10-27 09:57:44
- **By**: moc.liamtoh@12_namyaj

.. code-block:: text

    Which formula exactly did you use decil, for your plugin? How do you get different harmonics
    from this algo. thanx
    
    jay      

- **Date**: 2005-11-15 09:09:48
- **By**: ten.etelirt@liam

.. code-block:: text

    wow, blast from the past seeing this turn up on kvraudio.
    
    christian - i'd have thought that an advantage of using a taylor series approximation would be
    that it limits the order of the polynomial (and the resulting bandwidth) somewhat.  it's been ages
    since i tested, but i thought i got some reasonable sounding results using the taylor series
    approximation.  maybe not.  
    
    decil - isn't that a completely unrelated polynomial (similar to the common and cheap x - a x^3 ?).
    i'd think you'd have to do something about the dc from the x^2 term, too (or do a sign(x)*x^2).
    anyway, your plugin sounds to be popular so i look forward to checking it out later at home.

