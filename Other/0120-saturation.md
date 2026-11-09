# Saturation

[MusicDSP](../README.md) / [Other](README.md) · [3 comments](#comments)

- **Author or source:** Bram
- **Type:** Waveshaper
- **Created:** 2002-09-19 14:27:46

## Notes

when the input is below a certain threshold (t) these functions return the input, if it
goes over that threshold, they return a soft shaped saturation.
Neigther claims to be fast ;-)

## Code

```cpp
float saturate(float x, float t)
{
    if(fabs(x)<t)
        return x
    else
    {
        if(x > 0.f);
            return t + (1.f-t)*tanh((x-t)/(1-t));
        else
            return -(t + (1.f-t)*tanh((-x-t)/(1-t)));
 }
}

or

float sigmoid(x)
{
    if(fabs(x)<1)
        return x*(1.5f - 0.5f*x*x);
    else
        return x > 0.f ? 1.f : -1.f;
}

float saturate(float x, float t)
{
    if(abs(x)<t)
        return x
    else
    {
        if(x > 0.f);
            return t + (1.f-t)*sigmoid((x-t)/((1-t)*1.5f));
        else
            return -(t + (1.f-t)*sigmoid((-x-t)/((1-t)*1.5f)));
    }
}
```

## Comments

<details>
<summary>Show 3 replies</summary>

1. **moc.oohay@yrret** · *2002-10-15 17:22:22*

   ```text
                But My question is
   BUT HAVE YOU TRIED YOUR CODE!!!!!!!!!!!!!!!!????
   I think no, 'cos give a compiling error.
   the right (for sintax) version is this:

   float sigmoid(float x)
   {
       if(fabs(x)<1)
           return x*(1.5f - 0.5f*x*x);
       else
           return x > 0.f ? 1.f : -1.f;
   }

   float saturate(float x, float t)
   {
       if(abs(x)<t)
           return x;
       else
       {
           if(x > 0.f)
               return t + (1.f-t)*sigmoid((x-t)/((1-t)*1.5f));
           else
               return -(t + (1.f-t)*sigmoid((-x-t)/((1-t)*1.5f)));
       }
   }
   ```

2. **moc.liamtoh@tnuhhcaebmi** · *2003-11-18 10:16:14*

   except for the missing parenthesis of course =)
   the first line of saturate should be either

   ```text
   if(fabs(x)) return x;
   ```

   or

   ```text
   if(abs(x)) return x;
   ```

   depending on whether you're looking at the first or second saturate function (in the orig post)

3. **DKDiveDude** · *2021-01-01 11:50:14*

   The first function seems to be only a unnecessary complicated brick limit function. See below how I implemented the first function's code. Left is a sample between -1 and 1, positiveThreshold and negativeThreshold should be self explanatory.

   ```cpp
   if (left > positiveThreshold)
   	left = positiveThreshold + (1 - positiveThreshold) * tanh ((left - positiveThreshold) / (1 - positiveThreshold));
   else if (left < negativeThreshold)
   	left = -(positiveThreshold + (1 - positiveThreshold) * tanh ((-left - positiveThreshold) / (1 - positiveThreshold)));
   ```

</details>
