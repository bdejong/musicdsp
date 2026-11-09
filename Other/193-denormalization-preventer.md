# Denormalization preventer

[MusicDSP](../README.md) / [Other](README.md)

- **Author or source:** gol
- **Created:** 2005-03-31 16:57:07

## Notes

A fast tiny numbers sweeper using integer math. Only for 32bit floats. Den\_Thres is your
32bit (normalized) float threshold, something small enough but big enough to prevent
future denormalizations.

```text
EAX=input buffer
EDX=length
(adapt to your compiler)
```

## Code

```cpp
    MOV   ECX,EDX
    LEA   EDI,[EAX+4*ECX]
    NEG   ECX
    MOV   EDX,Den_Thres
    SHL   EDX,1
    XOR   ESI,ESI

    @Loop:
    MOV   EAX,[EDI+4*ECX]
    LEA   EBX,[EAX*2]
    CMP   EBX,EDX
    CMOVB EAX,ESI
    MOV   [EDI+4*ECX],EAX

    INC   ECX
    JNZ   @Loop
```
