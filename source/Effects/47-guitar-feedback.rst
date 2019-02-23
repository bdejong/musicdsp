Guitar feedback
===============

- **Author or source:** Sean Costello
- **Created:** 2002-02-10 20:01:07


.. code-block:: text
    :caption: notes

    It is fairly simple to simulate guitar feedback with a simple Karplus-Strong algorithm
    (this was described in a CMJ article in the early 90's):
    
    


.. code-block:: c++
    :linenos:
    :caption: code

    Run the output of the Karplus-Strong delay lines into a nonlinear shaping function for distortion (i.e. 6 parallel delay lines for 6 strings, going into 1 nonlinear shaping function that simulates an overdriven amplifier, fuzzbox, etc.);
    
    Run part of the output into a delay line, to simulate the distance from the amplifier to the "strings";
    
    The delay line feeds back into the Karplus-Strong delay lines. By controlling the amount of the output fed into the delay line, and the length of the delay line, you can control the intensity and pitch of the feedback note.

Comments
--------

- **Date**: 2002-11-23 19:27:09
- **By**: az.oc.liambew@ztangi

.. code-block:: text

    any C snippet code ???
    
    thx

- **Date**: 2004-06-09 22:54:43
- **By**: moc.loa@12asorival

.. code-block:: text

                  Are you Sean Costello the Blues Musician/Guitarist?
    
    Lenora
    lavirosa21@aol.com

- **Date**: 2004-08-22 18:31:41
- **By**: ed.xmg@resiaknegah

.. code-block:: text

                  what is a Karplus-Strong-Delay??

- **Date**: 2004-10-25 10:23:00
- **By**: gro.lortnocniarb@reyalsniarb

.. code-block:: text

    a physical modelling algorithm

- **Date**: 2016-06-10 19:58:07
- **By**: moc.liamg@1a7102egroj

.. code-block:: text

                  formula.......... y (n) =  x(n) + c * [ y (n-N) + y (n - (N+1))]
    '''A simple model (based on Karplus-Strong algorithm) may be used to model a plucked string instrument like a guitar.
    '''The input-output relationship of the causal LTI system is given by:
    '''    y (n) =  x(n) + ? * [ y (n-N) + y (n - (N+1))]
    '''
    '''Where
    '''    x(n) is a zero mean random variable, uniformly distributed between -1 and 1
    '''    y(n) is the output
    '''c is a real-valued constant, whose typical value is 0.5 (experiment with other values and comment)
    '''N controls the pitch of the note; N = floor ( Fs / Fp), where Fs is the sampling frequency in Hz, and Fp
    '''is the pitch of the note in Hz.  For example, at 8 kHz sampling frequency, N = 20 implies a pitch frequency of 400 Hz.
    

- **Date**: 2016-06-10 19:59:36
- **By**: moc.liamg@1a7102egroj

.. code-block:: text

    'NO esta completo falta algo, no se, si es el filtro biquad
    
    Public Function karplustrong_b1(PNumSamples As Long) As Integer()
    Dim x() As Single
    Dim y() As Single
    Dim n As Long
    Dim Num As Long
    Dim ArrResp() As Integer
    Dim C As Single
    Dim Fs As Long
    Dim fP As Single
    Dim amplitud As Long
    Dim i As Long
    Dim valor As Single
    Dim Ind1 As Long
    Dim Ind2 As Long
    Dim suma As Single
    Dim media As Single
    Dim valorsigno As Single
    
        
        Fs = 44100
        fP = 400 '400hz pitch frequency
        
        'Num = (Fs / Fp)
        
    
        ReDim x(PNumSamples)
        ReDim y(PNumSamples)
        
        
        
        
        'generar numeros aleatorios rango 0 a 1
        'iniciar numeros aleatorios
        Randomize
        suma = 0
        For i = 0 To PNumSamples
            valor = Rnd * 1 - 0.5
            
            'valorsigno = Rnd * 1
            'If valorsigno > 0.5 Then valor = -valor
                    
            x(i) = valor
            suma = suma + valor
        Next
        
        media = suma / PNumSamples
        'media = 1
        
        'calcular la media y dividir
        For i = 0 To PNumSamples
            valor = x(i)
            x(i) = valor / media
        Next
        
        
        
        Num = PNumSamples - 1
        C = 0.5
        
        For n = 0 To PNumSamples - 1
            'Ind1 = Abs(n - Num)
            'Ind2 = Abs(n - (Num + 1))
            Ind2 = Abs((n))
            Ind2 = Abs((n + 1) Mod Num) / 2
            y(n) = x(n) + C * (y(Ind1) + y(Ind2))
        Next
    
    
        ReDim ArrResp(PNumSamples)
        amplitud = 1000
        For i = 0 To Num
            ArrResp(i) = RangoInteger(y(i) * amplitud)
        Next
        
        karplustrong_b1 = ArrResp
    End Function

