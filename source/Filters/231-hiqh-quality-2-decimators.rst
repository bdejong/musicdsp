Hiqh quality /2 decimators
==========================

- **Author or source:** Paul Sernine
- **Type:** Decimators
- **Created:** 2006-07-28 17:59:03


.. code-block:: text
    :caption: notes

    These are /2 decimators,
    Just instanciate one of them and use the Calc method to obtain one sample while inputing
    two. There is 5,7 and 9 tap versions.
    They are extracted/adapted from a tutorial code by Thierry Rochebois. The optimal
    coefficients are excerpts of Traitement numérique du signal, 5eme edition, M Bellanger,
    Masson pp. 339-346.
    


.. code-block:: c++
    :linenos:
    :caption: code

    //Filtres décimateurs
    // T.Rochebois
    // Based on
    //Traitement numérique du signal, 5eme edition, M Bellanger, Masson pp. 339-346
    class Decimateur5
    {
      private:
      float R1,R2,R3,R4,R5;
      const float h0;
      const float h1;
      const float h3;
      const float h5;
      public:
      Decimateur5::Decimateur5():h0(346/692.0f),h1(208/692.0f),h3(-44/692.0f),h5(9/692.0f)
      {
        R1=R2=R3=R4=R5=0.0f;
      }
      float Calc(const float x0,const float x1)
      {
        float h5x0=h5*x0;
        float h3x0=h3*x0;
        float h1x0=h1*x0;
        float R6=R5+h5x0;
        R5=R4+h3x0;
        R4=R3+h1x0;
        R3=R2+h1x0+h0*x1;
        R2=R1+h3x0;
        R1=h5x0;
        return R6;
      }
    };
    class Decimateur7
    {
      private:
      float R1,R2,R3,R4,R5,R6,R7;
      const float h0,h1,h3,h5,h7;
      public:
      Decimateur7::Decimateur7():h0(802/1604.0f),h1(490/1604.0f),h3(-116/1604.0f),h5(33/1604.0f),h7(-6/1604.0f)
      {
        R1=R2=R3=R4=R5=R6=R7=0.0f;
      }
      float Calc(const float x0,const float x1)
      {
        float h7x0=h7*x0;
        float h5x0=h5*x0;
        float h3x0=h3*x0;
        float h1x0=h1*x0;
        float R8=R7+h7x0;
        R7=R6+h5x0;
        R6=R5+h3x0;
        R5=R4+h1x0;
        R4=R3+h1x0+h0*x1;
        R3=R2+h3x0;
        R2=R1+h5x0;
        R1=h7x0;
        return R8;
      }
    };
    class Decimateur9
    {
      private:
      float R1,R2,R3,R4,R5,R6,R7,R8,R9;
      const float h0,h1,h3,h5,h7,h9;
      public:
      Decimateur9::Decimateur9():h0(8192/16384.0f),h1(5042/16384.0f),h3(-1277/16384.0f),h5(429/16384.0f),h7(-116/16384.0f),h9(18/16384.0f)
      {
        R1=R2=R3=R4=R5=R6=R7=R8=R9=0.0f;
      }
      float Calc(const float x0,const float x1)
      {
        float h9x0=h9*x0;
        float h7x0=h7*x0;
        float h5x0=h5*x0;
        float h3x0=h3*x0;
        float h1x0=h1*x0;
        float R10=R9+h9x0;
        R9=R8+h7x0;
        R8=R7+h5x0;
        R7=R6+h3x0;
        R6=R5+h1x0;
        R5=R4+h1x0+h0*x1;
        R4=R3+h3x0;
        R3=R2+h5x0;
        R2=R1+h7x0;
        R1=h9x0;
        return R10;
      }
    };
    

