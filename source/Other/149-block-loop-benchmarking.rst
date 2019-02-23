Block/Loop Benchmarking
=======================

- **Author or source:** moc.xinortceletrams@urugra
- **Type:** Benchmarking Tool
- **Created:** 2003-06-24 07:30:43


.. code-block:: text
    :caption: notes

    Requires CPU with RDTSC support


.. code-block:: c++
    :linenos:
    :caption: code

    // Block-Process Benchmarking Code using rdtsc
    // useful for measure DSP block stuff
    // (based on Intel papers)
    // 64-bit precission
    // VeryUglyCode(tm) by Arguru
    
    // globals
    UINT time,time_low,time_high;
    
    // call this just before enter your loop or whatever
    void bpb_start()
    {
    	// read time stamp to EAX
    	__asm rdtsc;
    	__asm mov time_low,eax;
    	__asm mov time_high,edx;
    }
    
    // call the following function just after your loop
    // returns average cycles wasted per sample
    UINT bpb_finish(UINT const num_samples)
    {
    	__asm rdtsc 
    	__asm sub eax,time_low;
    	__asm sub edx,time_high;
    	__asm div num_samples;
    	__asm mov time,eax;
    	return time;
    }

Comments
--------

- **Date**: 2004-05-16 18:20:13
- **By**: moc.sulp.52retsinnab@etep

.. code-block:: text

    If running windows on a mutliprocessor system, apparently it is worth calling:
    
    SetThreadAffinityMask(GetCurrentThread(), 1);   
    
    to reduce artefacts.
    
    (see http://msdn.microsoft.com/visualc/vctoolkit2003/default.aspx?pull=/library/en-us/dv_vstechart/html/optimization.asp)

- **Date**: 2004-08-26 00:33:18
- **By**: rf.eerf@uerum.emualliug

.. code-block:: text

    __asm sub eax,time_low;
    __asm sub edx,time_high;
    
    should be
    
    __asm sub eax,time_low
    __asm SBB edx,time_high // substract with borrow

