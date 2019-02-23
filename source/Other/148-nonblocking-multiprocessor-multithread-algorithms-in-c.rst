Nonblocking multiprocessor/multithread algorithms in C++
========================================================

- **Author or source:** moc.oohay@ralohcshsoj
- **Type:** queue, stack, garbage collection, memory allocation, templates for atomic algorithms and types
- **Created:** 2004-04-07 09:38:12

- **Linked files:** :download:`ATOMIC.H <../files/ATOMIC.H>`.

.. code-block:: text
    :caption: notes

    see linked file...



Comments
--------

- **Date**: 2008-01-10 17:01:39
- **By**: ten.xliamnahx@xmagie

.. code-block:: text

    This code has a problem with operation exceeding 4G times.  If you do more then 4G of Put and Get with the MPQueue, "AtomicUInt & Index(int i) { return data[i & (len-1)];} will cause BUG.
    Modular operation with length of 2^n is OK, but not for other numbers.
    My email does not have any "x" letters.
    

- **Date**: 2011-05-23 22:22:21
- **By**: ude.fcu.sc@awajuk

.. code-block:: text

    In MPCountStack::PopElement, what's to prevent another thread from deleting was.Value().ptr between assigning was and reading was.Value().ptr->next?

