Fold back distortion
====================

- **Author or source:** ed.bpu@eriflleh
- **Type:** distortion
- **Created:** 2005-05-28 19:11:06


.. code-block:: text
    :caption: notes

    a simple fold-back distortion filter.
    if the signal exceeds the given threshold-level, it mirrors at the positive/negative
    threshold-border as long as the singal lies in the legal range (-threshold..+threshold).
    there is no range limit, so inputs doesn't need to be in -1..+1 scale.
    threshold should be >0
    depending on use (low thresholds) it makes sense to rescale the input to full amplitude
    
    performs approximately the following code
    (just without the loop)
    
    while (in>threshold || in<-threshold)
    {
      // mirror at positive threshold
      if (in>threshold) in= threshold - (in-threshold);
      // mirror at negative threshold
      if (in<-threshold) in= -threshold + (-threshold-in);
    }
    


.. code-block:: c++
    :linenos:
    :caption: code

    float foldback(float in, float threshold)
    {
      if (in>threshold || in<-threshold)
      {
        in= fabs(fabs(fmod(in - threshold, threshold*4)) - threshold*2) - threshold;
      }
      return in;
    }
    

