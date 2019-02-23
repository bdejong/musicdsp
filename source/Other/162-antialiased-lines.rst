Antialiased Lines
=================

- **Author or source:** moc.xinortceletrams@urugra
- **Type:** A slow, ugly, and unoptimized but short method to perform antialiased lines in a framebuffer
- **Created:** 2004-04-07 09:38:53


.. code-block:: text
    :caption: notes

    Simple code to perform antialiased lines in a 32-bit RGBA (1 byte/component) framebuffer.
    
    pframebuffer <- unsigned char* to framebuffer bytes (important: Y flipped line order!
    [like in the way Win32 CreateDIBSection works...])
    
    client_height=framebuffer height in lines
    client_width=framebuffer width in pixels (not in bytes)
    
    This doesnt perform any clip checl so it fails if coordinates are set out of bounds.
    
    sorry for the engrish
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    //
    // By Arguru
    //
    void PutTransPixel(int const x,int const y,UCHAR const r,UCHAR const g,UCHAR const b,UCHAR const a)
    {
    	unsigned char* ppix=pframebuffer+(x+(client_height-(y+1))*client_width)*4;
    	ppix[0]=((a*b)+(255-a)*ppix[0])/256;
    	ppix[1]=((a*g)+(255-a)*ppix[1])/256;
    	ppix[2]=((a*r)+(255-a)*ppix[2])/256;
    }
    
    void LineAntialiased(int const x1,int const y1,int const x2,int const y2,UCHAR const r,UCHAR const g,UCHAR const b)
    {
    	// some useful constants first
    	double const dw=x2-x1;
    	double const dh=y2-y1;
    	double const slx=dh/dw;
    	double const sly=dw/dh;
    
    	// determine wichever raster scanning behaviour to use
    	if(fabs(slx)<1.0)
    	{
    		// x scan
    		int tx1=x1;
    		int tx2=x2;
    		double raster=y1;
    
    		if(x1>x2)
    		{
    			tx1=x2;
    			tx2=x1;
    			raster=y2;
    		}
    
    		for(int x=tx1;x<=tx2;x++)
    		{
    			int const ri=int(raster);
    
    			double const in_y0=1.0-(raster-ri);
    			double const in_y1=1.0-(ri+1-raster);
    
    			PutTransPixel(x,ri+0,r,g,b,in_y0*255.0);
    			PutTransPixel(x,ri+1,r,g,b,in_y1*255.0);
    
    			raster+=slx;
    		}
    	}
    	else
    	{
    		// y scan
    		int ty1=y1;
    		int ty2=y2;
    		double raster=x1;
    
    		if(y1>y2)
    		{
    			ty1=y2;
    			ty2=y1;
    			raster=x2;
    		}
    
    		for(int y=ty1;y<=ty2;y++)
    		{
    			int const ri=int(raster);
    
    			double const in_x0=1.0-(raster-ri);
    			double const in_x1=1.0-(ri+1-raster);
    
    			PutTransPixel(ri+0,y,r,g,b,in_x0*255.0);
    			PutTransPixel(ri+1,y,r,g,b,in_x1*255.0);
    
    			raster+=sly;
    		}
    	}
    }
    

Comments
--------

- **Date**: 2004-02-11 12:53:12
- **By**: Gog

.. code-block:: text

    Sorry, but what does this have to do with music DSP ??
                  

- **Date**: 2004-02-14 17:39:38
- **By**: moc.liamtoh@101_vap

.. code-block:: text

    well, for drawing envelopes, waveforms, etc on screen in your DSP app....
    
                 

- **Date**: 2004-02-15 11:59:04
- **By**: Gog

.. code-block:: text

    But... there are TONS of graphic toolkits to do just that. No reason to "roll your own". One f.i. is GDI+ (works darn well to be honest), or if you want non-M$ (and better!) go with AGG at (http://www.antigrain.com). And there are even open-source cross-platform toolkits (if you want to do Unix and Mac without coding).
    Graphics and GUIs is a very time-consuming task to do from scratch, therefore I think using libraries such as the above is the way to go, liberating energy to do the DSP stuff... ;-)
    
    

- **Date**: 2004-03-11 02:56:19
- **By**: Rich

.. code-block:: text

    I don't want a toolkit, I want antialiased line drawing and nothing more. Everything else is fine.

- **Date**: 2004-03-11 17:32:09
- **By**: Justin

.. code-block:: text

    Anyone know how to get the pointer to the framebuffer?  Perhaps there is a different answer for different platforms?

- **Date**: 2004-09-12 07:39:28
- **By**: ed.stratnemesab@kcaahcs.leinad

.. code-block:: text

    you can also draw everything in a 2x (vertically and horizontally) higher resolution and then reduce the size again by always taking the average of 4 pixels. that works well.

- **Date**: 2008-11-20 18:07:21
- **By**: moc.liamg@okolila

.. code-block:: text

    I think it can be useful to those designing graphical synths.
    
    But the Wu line algorithm is considerably more fast and works only with integers.
    
    http://en.wikipedia.org/wiki/Xiaolin_Wu's_line_algorith

