# Hilbert Filter Coefficient Calculation

[MusicDSP](../README.md) / [Filters](README.md)

- **Author or source:** ed.luosfosruoivas@naitsirhC
- **Type:** Uncle Hilbert
- **Created:** 2005-04-17 19:05:37

## Notes

This is the delphi code to create the filter coefficients, which are needed to phaseshift
a signal by 90°
This may be useful for an evelope detector...

By windowing the filter coefficients you can trade phase response flatness with magnitude
response flatness.

I had problems checking its response by using a dirac impulse. White noise works fine.

Also this introduces a latency of N/2!

## Code

```cpp
type TSingleArray = Array of Single;

procedure UncleHilbert(var FilterCoefficients: TSingleArray; N : Integer);
var i,j : Integer;
begin
 SetLength(FilterCoefficients,N);
 for i:=0 to (N div 4) do
  begin
   FilterCoefficients[(N div 2)+(2*i-1)]:=+2/(PI*(2*i-1));
   FilterCoefficients[(N div 2)-(2*i-1)]:=-2/(PI*(2*i-1));
  end;
end;
```
