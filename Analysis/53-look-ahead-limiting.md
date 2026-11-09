# Look ahead limiting

[MusicDSP](../README.md) / [Analysis](README.md)

- **Author or source:** Wilfried Welti
- **Created:** 2002-01-17 03:08:11

## Notes

use add\_value with all values which enter the look-ahead area,
and remove\_value with all value which leave this area. to get
the maximum value in the look-ahead area, use get\_max\_value.
in the very beginning initialize the table with zeroes.

If you always want to know the maximum amplitude in
your look-ahead area, the thing becomes a sorting
problem. very primitive approach using a look-up table

## Code

```cpp
void lookup_add(unsigned section, unsigned size, unsigned value)
{
  if (section==value)
    lookup[section]++;
  else
  {
    size >>= 1;
    if (value>section)
    {
      lookup[section]++;
      lookup_add(section+size,size,value);
    }
    else
      lookup_add(section-size,size,value);
  }
}

void lookup_remove(unsigned section, unsigned size, unsigned value)
{
  if (section==value)
    lookup[section]--;
  else
  {
    size >>= 1;
    if (value>section)
    {
      lookup[section]--;
      lookup_remove(section+size,size,value);
    }
    else
      lookup_remove(section-size,size,value);
  }
}

unsigned lookup_getmax(unsigned section, unsigned size)
{
  unsigned max = lookup[section] ? section : 0;
  size >>= 1;
  if (size)
    if (max)
    {
      max = lookup_getmax((section+size),size);
      if (!max) max=section;
    }
    else
      max = lookup_getmax((section-size),size);
  return max;
}

void add_value(unsigned value)
{
  lookup_add(LOOKUP_VALUES>>1, LOOKUP_VALUES>>1, value);
}

void remove_value(unsigned value)
{
  lookup_remove(LOOKUP_VALUES>>1, LOOKUP_VALUES>>1, value);
}

unsigned get_max_value()
{
  return lookup_getmax(LOOKUP_VALUES>>1, LOOKUP_VALUES>>1);
}
```
