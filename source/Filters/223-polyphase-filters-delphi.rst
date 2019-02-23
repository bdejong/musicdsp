Polyphase Filters (Delphi)
==========================

- **Author or source:** moc.liamtoh@retsbomyrgnayrev
- **Type:** polyphase filters, used for up and down-sampling
- **Created:** 2006-07-05 20:13:50


.. code-block:: text
    :caption: notes

    Pascal conversion of C++ code by Dave from Muon Software. Conversion by Shannon Faulkner.
    


.. code-block:: c++
    :linenos:
    :caption: code

    {
    
    polyphase filters, used for up and down-sampling
    original c++ code by Dave from Muon Software found
    at MusicDSP.
    rewritten in pascal by Shannon Faulkner, 4/7/06.
    
    }
    
    unit uPolyphase;
    
    interface
    
    type
      TAllPass=class
      private
        a,x0,x1,x2,y0,y1,y2:single;
      public
        constructor create(coefficient:single);
        function Process(input:single):single;
      end;
    
      TAllPassFilterCascade=class
      private
        AllPassFilters:array of TAllPass;
        fOrder:integer;
      public
        constructor create(coefficients:psingle;Order:integer);
        function Process(input:single):single;
      end;
    
      THalfBandFilter=class
      private
        fOrder:integer;
        OldOut:single;
        aCoeffs,bCoeffs:array of single;
        FilterA,FilterB:TAllPassFilterCascade;
      public
        constructor create(order:integer;Steep:boolean);
        function process(input:single):single;
      end;
    
    
    implementation
    //-----------     AllPass Filter        -------------------
    //-----------     AllPass Filter        ----------------------------------------------
    //-----------     AllPass Filter        ----------------------------------------------
    constructor TAllPass.create(coefficient:single);
    begin
      a:=coefficient;
    
      x0:=0;
      x1:=0;
      x2:=0;
    
      y0:=0;
      y1:=0;
      y2:=0;
    end;
    
    function TAllPass.Process(input:single):single;
    var output:single;
    begin
      //shuffle inputs
      x2:=x1;
      x1:=x0;
      x0:=input;
    
      //shuffle outputs
      y2:=y1;
      y1:=y0;
    
      //allpass filter 1
      output:=x2+((input-y2)*a);
    
      y0:=output;
    
      result:=output;
    end;
    //------------     AllPass Filter Cascade     -------------
    //------------     AllPass Filter Cascade     -------------
    //------------     AllPass Filter Cascade     -------------
    constructor TAllPassFilterCascade.create(coefficients:psingle;Order:integer);
    var i:integer;
    begin
      fOrder:=Order;
      setlength(AllPassFilters,fOrder);
      for i:=0 to fOrder-1 do
      begin
        AllPassFilters[i]:=TAllPass.create(coefficients^);
        inc(coefficients);
      end;
    end;
    
    function TAllPassFilterCascade.Process(input:single):single;
    var
      output:single;
      i:integer;
    begin
      output:=input;
      for i:=0 to fOrder-1 do
      begin
        output:=allpassfilters[i].Process(output);
      end;
      result:=output;
    end;
    //--------------   Halfband Filter    -------------------------------------------
    //--------------   Halfband Filter    ---------------------
    //--------------   Halfband Filter    -------------------------------------------
    constructor THalfBandFilter.create(order:integer;Steep:boolean);
    begin
      fOrder:=order;
      setlength(aCoeffs,Order div 2);
      setlength(bCoeffs,Order div 2);
    
      if steep=true then
      begin
        if (order=12) then //rejection=104dB, transition band=0.01
        begin
          aCoeffs[0]:=0.036681502163648017;
          aCoeffs[1]:=0.2746317593794541;
          aCoeffs[2]:=0.56109896978791948;
          aCoeffs[3]:=0.769741833862266;
          aCoeffs[4]:=0.8922608180038789;
          aCoeffs[5]:=0.962094548378084;
    
          bCoeffs[0]:=0.13654762463195771;
          bCoeffs[1]:=0.42313861743656667;
          bCoeffs[2]:=0.6775400499741616;
          bCoeffs[3]:=0.839889624849638;
          bCoeffs[4]:=0.9315419599631839;
          bCoeffs[5]:=0.9878163707328971;
        end
        else if (order=10) then	//rejection=86dB, transition band=0.01
        begin
          aCoeffs[0]:=0.051457617441190984;
          aCoeffs[1]:=0.35978656070567017;
          aCoeffs[2]:=0.6725475931034693;
          aCoeffs[3]:=0.8590884928249939;
          aCoeffs[4]:=0.9540209867860787;
    
          bCoeffs[0]:=0.18621906251989334;
          bCoeffs[1]:=0.529951372847964;
          bCoeffs[2]:=0.7810257527489514;
          bCoeffs[3]:=0.9141815687605308;
          bCoeffs[4]:=0.985475023014907;
        end
        else if (order=8) then	//rejection=69dB, transition band=0.01
        begin
          aCoeffs[0]:=0.07711507983241622;
          aCoeffs[1]:=0.4820706250610472;
          aCoeffs[2]:=0.7968204713315797;
          aCoeffs[3]:=0.9412514277740471;
    
          bCoeffs[0]:=0.2659685265210946;
          bCoeffs[1]:=0.6651041532634957;
          bCoeffs[2]:=0.8841015085506159;
          bCoeffs[3]:=0.9820054141886075;
        end
        else if (order=6) then	//rejection=51dB, transition band=0.01
        begin
          aCoeffs[0]:=0.1271414136264853;
          aCoeffs[1]:=0.6528245886369117;
          aCoeffs[2]:=0.9176942834328115;
    
          bCoeffs[0]:=0.40056789819445626;
          bCoeffs[1]:=0.8204163891923343;
          bCoeffs[2]:=0.9763114515836773;
        end
        else if (order=4) then	//rejection=53dB,transition band=0.05
        begin
          aCoeffs[0]:=0.12073211751675449;
          aCoeffs[1]:=0.6632020224193995;
    
          bCoeffs[0]:=0.3903621872345006;
          bCoeffs[1]:=0.890786832653497;
        end
        else	//order=2, rejection=36dB, transition band=0.1
        begin
          aCoeffs[0]:=0.23647102099689224;
          bCoeffs[0]:=0.7145421497126001;
        end;
      end else	//softer slopes, more attenuation and less stopband ripple
      begin
        if (order=12) then //rejection=104dB, transition band=0.01
        begin
          aCoeffs[0]:=0.01677466677723562;
          aCoeffs[1]:=0.13902148819717805;
          aCoeffs[2]:=0.3325011117394731;
          aCoeffs[3]:=0.53766105314488;
          aCoeffs[4]:=0.7214184024215805;
          aCoeffs[5]:=0.8821858402078155;
    
          bCoeffs[0]:=0.06501319274445962;
          bCoeffs[1]:=0.23094129990840923;
          bCoeffs[2]:=0.4364942348420355;
    
          //bug fix - coefficient changed,
          //rob[DOT]belcham[AT]zen[DOT]co[DOT]uk
          //bCoeffs[3]:=0.06329609551399348;  //original coefficient
          bCoeffs[3]:=0.6329609551399348;     //correct coefficient
    
          bCoeffs[4]:=0.80378086794111226;
          bCoeffs[5]:=0.9599687404800694;
        end
        else if (order=10) then	//rejection=86dB, transition band=0.01
        begin
          aCoeffs[0]:=0.02366831419883467;
          aCoeffs[1]:=0.18989476227180174;
          aCoeffs[2]:=0.43157318062118555;
          aCoeffs[3]:=0.6632020224193995;
          aCoeffs[4]:=0.860015542499582;
    
          bCoeffs[0]:=0.09056555904993387;
          bCoeffs[1]:=0.3078575723749043;
          bCoeffs[2]:=0.5516782402507934;
          bCoeffs[3]:=0.7652146863779808;
          bCoeffs[4]:=0.95247728378667541;
        end
        else if (order=8) then	//rejection=69dB, transition band=0.01
        begin
          aCoeffs[0]:=0.03583278843106211;
          aCoeffs[1]:=0.2720401433964576;
          aCoeffs[2]:=0.5720571972357003;
          aCoeffs[3]:=0.827124761997324;
    
          bCoeffs[0]:=0.1340901419430669;
          bCoeffs[1]:=0.4243248712718685;
          bCoeffs[2]:=0.7062921421386394;
          bCoeffs[3]:=0.9415030941737551;
        end
        else if (order=6) then	//rejection=51dB, transition band=0.01
        begin
          aCoeffs[0]:=0.06029739095712437;
          aCoeffs[1]:=0.4125907203610563;
          aCoeffs[2]:=0.7727156537429234;
    
          bCoeffs[0]:=0.21597144456092948;
          bCoeffs[1]:=0.6043586264658363;
          bCoeffs[2]:=0.9238861386532906;
        end
        else if (order=4) then	//rejection=53dB,transition band=0.05
        begin
          aCoeffs[0]:=0.07986642623635751;
          aCoeffs[1]:=0.5453536510711322;
    
          bCoeffs[0]:=0.28382934487410993;
          bCoeffs[1]:=0.8344118914807379;
        end
        else	//order=2, rejection=36dB, transition band=0.1
        begin
          aCoeffs[0]:=0.23647102099689224;
          bCoeffs[0]:=0.7145421497126001;
        end;
      end;
    
      FilterA:=TAllPassFilterCascade.create(@aCoeffs[0],fOrder div 2);
      FilterB:=TAllPassFilterCascade.create(@bCoeffs[0],fOrder div 2);
    
      oldout:=0;
    end;
    
    function THalfBandFilter.process(input:single):single;
    begin
      result:=(FilterA.Process(input)+oldout)*0.5;
      oldout:=FilterB.Process(input);
    end;
    
    end.

