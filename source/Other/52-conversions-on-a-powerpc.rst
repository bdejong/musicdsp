Conversions on a PowerPC
========================

- **Author or source:** James McCartney
- **Type:** motorola ASM conversions
- **Created:** 2002-01-17 03:07:18



.. code-block:: c++
    :linenos:
    :caption: code

    double ftod(float x) { return (double)x;
    00000000: 4E800020  blr
        // blr == return from subroutine, i.e. this function is a noop
    
    float dtof(double x) { return (float)x;
    00000000: FC200818  frsp       fp1,fp1
    00000004: 4E800020  blr
    
    int ftoi(float x) { return (int)x;
    00000000: FC00081E  fctiwz     fp0,fp1
    00000004: D801FFF0  stfd       fp0,-16(SP)
    00000008: 8061FFF4  lwz        r3,-12(SP)
    0000000C: 4E800020  blr
    
    int dtoi(double x) { return (int)x;
    00000000: FC00081E  fctiwz     fp0,fp1
    00000004: D801FFF0  stfd       fp0,-16(SP)
    00000008: 8061FFF4  lwz        r3,-12(SP)
    0000000C: 4E800020  blr
    
    double itod(int x) { return (double)x;
    00000000: C8220000  lfd        fp1,@1558(RTOC)
    00000004: 6C608000  xoris      r0,r3,$8000
    00000008: 9001FFF4  stw        r0,-12(SP)
    0000000C: 3C004330  lis        r0,17200
    00000010: 9001FFF0  stw        r0,-16(SP)
    00000014: C801FFF0  lfd        fp0,-16(SP)
    00000018: FC200828  fsub       fp1,fp0,fp1
    0000001C: 4E800020  blr
    
    float itof(int x) { return (float)x;
    00000000: C8220000  lfd        fp1,@1558(RTOC)
    00000004: 6C608000  xoris      r0,r3,$8000
    00000008: 9001FFF4  stw        r0,-12(SP)
    0000000C: 3C004330  lis        r0,17200
    00000010: 9001FFF0  stw        r0,-16(SP)
    00000014: C801FFF0  lfd        fp0,-16(SP)
    00000018: EC200828  fsubs      fp1,fp0,fp1
    0000001C: 4E800020  blr

