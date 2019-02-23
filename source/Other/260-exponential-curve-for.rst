Exponential curve for
=====================

- **Author or source:** moc.liamg@321tiloen
- **Type:** Exponential curve
- **Created:** 2008-10-29 17:29:03


.. code-block:: text
    :caption: notes

    When you design a frequency control for your filters you may need an exponential curve to
    give the lower frequencies more resolution.
    
    F=20-20000hz
    x=0-100%
    
    Case (control middle point):
    x=50%
    F=1135hz
    
    Ploted diagram with 5 points:
    http://img151.imageshack.us/img151/9938/expplotur3.jpg
    


.. code-block:: c++
    :linenos:
    :caption: code

    //tweak - 14.15005 to change middle point and F(max)
    F = 19+floor(pow(4,x/14.15005))+x*20;
    
    

Comments
--------

- **Date**: 2008-10-30 13:47:16
- **By**: moc.liamg@321tiloen

.. code-block:: text

    same function with the more friendly exp(x)
    
    y = 19+floor(exp(x/10.2071))+x*20;
    
    middle point (x=50) is still at 1135hz

- **Date**: 2008-10-31 01:14:13
- **By**: moc.liamg@321tiloen

.. code-block:: text

    Here is another function:
    This one is much more expensive but should sound more linear.
    
    //t - offset
    //x - 0-100%
    //y - 20-20000hz
    
    t = 64.925;
    y = floor(exp(x*log(1.059))*t - t/1.45);
    
    Comparison between the two:
    [IMG]http://img528.imageshack.us/img528/641/plot1nu1.jpg[/IMG]
    

- **Date**: 2008-11-01 14:58:20
- **By**: moc.liamg@321tiloen

.. code-block:: text

    Yet another one! :)
    This is one should be the most linear one out of the 3. The 50% appears to be exactly the same as Voxengo span midpoint.
    
    //x - 0-100%
    //y - 20-20k
    
    y = floor(exp((16+x*1.20103)*log(1.059))*8.17742);
    
    //x=0, y=20
    //x=50, y=639
    //x=100, y=20000

