# Lock free fifo

[MusicDSP](../README.md) / [Other](README.md)

- **Author or source:** Timo
- **Created:** 2002-09-13 16:21:59
- **Linked files:** [LockFreeFifo.h](../files/LockFreeFifo.h).

## Notes

Simple implementation of a lock free FIFO.

## Comments

**moc.oohay@SIHTEVOMER\_ralohcshsoj** · 2003-04-15 11:17:31

There is a good algorithm for a lock free (but multiprocessor safe) FIFO.  But the given implimentation is flawed in a number of ways.  This code is not reliable.  Two problems on the surface of it:
1\. I can easily see that it's possible for two threads/processors to return the same item from the head if the timing is right.
2\. there's no interlocked instructions to make sure that changes to the shared variables are globally visible
3\. there's not attempt in the code to make sure that data is read in an atomic way, let alone changed in one...

The code is VERY naive

I do have code that works, but it's not so short that will post it in a comment.  If anyone needs it they can email me

**Timo** · 2003-05-15 19:16:24

This is only supposed to work on uniprocessor machines with \_one\_ reading and \_one\_ writing thread
assuming that the assignments to read and write idx are simple mov instructions (i.e. atomic). To be sure you'd need to write the update parts in hand-coded asm; never know what the compiler comes up with. The context of this code was omitted (i.e. Bram posted my written in 1 min sketch in a discussion on IRC on a lock-free fifo, not production code).
