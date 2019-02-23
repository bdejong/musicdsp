Motorola 56300 Disassembler
===========================

- **Author or source:** moc.ngisedigid@dnesnwot_sirhc
- **Type:** disassembler
- **Created:** 2005-05-24 07:08:07

- **Linked files:** :download:`Disassemble56k.zip <../files/Disassemble56k.zip>`.

.. code-block:: text
    :caption: notes

    This code contains functions to disassemble Motorola 56k opcodes.  The code was originally
    created by Stephen Davis at Stanford.  I made minor modifications to support many 56300
    opcodes, although it would nice to add them all at some point.  Specifically, I added
    support for CLB, NORMF, immediate AND, immediate OR, multi-bit ASR/ASL, multi-bit LSL/LSR,
    MAX, MAXM, BRA, Bcc, BSR, BScc, DMAC, MACsu, MACuu, and conditional ALU instructions.



Comments
--------

- **Date**: 2005-05-24 20:33:25
- **By**: jawoll

.. code-block:: text

    nice! let's disassemble virus c, nord lead 3, ...      

- **Date**: 2005-09-29 19:51:55
- **By**: moc.liamg@rhajile

.. code-block:: text

    Very nice.  How would one get ahold of the OS for one of these synths, to disassemble it?  I've got a Nord Micro, with a single 56303... question is.... how to get the OS from the flash?

- **Date**: 2011-07-11 08:58:10
- **By**: ach nö

.. code-block:: text

    After a first look inside the c file i found out that the header file "Utility56k.h" is missing which is included in the code file...

