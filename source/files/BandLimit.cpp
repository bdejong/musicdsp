CAllPassFilter::CAllPassFilter(const double coefficient)
{
	a=coefficient;

	x0=0.0;
	x1=0.0;
	x2=0.0;
	
	y0=0.0;
	y1=0.0;
	y2=0.0;

};


CAllPassFilter::~CAllPassFilter()
{
};


double CAllPassFilter::process(const double input)
{
	//shuffle inputs
	x2=x1;
	x1=x0;
	x0=input;

	//shuffle outputs
	y2=y1;
	y1=y0;

	//allpass filter 1
	const double output=x2+((input-y2)*a);

	y0=output;

	return output;
};


CAllPassFilterCascade::CAllPassFilterCascade(const double* coefficient, const int N)
{
	allpassfilter=new CAllPassFilter*[N];

	for (int i=0;i<N;i++)
	{
		allpassfilter[i]=new CAllPassFilter(coefficient[i]);
	}

	numfilters=N;
};


CAllPassFilterCascade::~CAllPassFilterCascade()
{
	delete[] allpassfilter;
};


double CAllPassFilterCascade::process(const double input)
{
	double output=input;
	
	int i=0;

	do
	{
		output=allpassfilter[i]->process(output);
		i++;

	} while (i<numfilters);

	return output;
};


CHalfBandFilter::CHalfBandFilter(const int order, const bool steep)
{
	if (steep==true)
	{
		if (order==12)	//rejection=104dB, transition band=0.01
		{
			double a_coefficients[6]=
			{0.036681502163648017
			,0.2746317593794541
			,0.56109896978791948
			,0.769741833862266
			,0.8922608180038789
			,0.962094548378084
			};

			double b_coefficients[6]=
			{0.13654762463195771
			,0.42313861743656667
			,0.6775400499741616
			,0.839889624849638
			,0.9315419599631839
			,0.9878163707328971
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,6);
			filter_b=new CAllPassFilterCascade(b_coefficients,6);
		}
		else if (order==10)	//rejection=86dB, transition band=0.01
		{
			double a_coefficients[5]=
			{0.051457617441190984
			,0.35978656070567017
			,0.6725475931034693
			,0.8590884928249939
			,0.9540209867860787
			};

			double b_coefficients[5]=
			{0.18621906251989334
			,0.529951372847964
			,0.7810257527489514
			,0.9141815687605308
			,0.985475023014907
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,5);
			filter_b=new CAllPassFilterCascade(b_coefficients,5);
		}
		else if (order==8)	//rejection=69dB, transition band=0.01
		{
			double a_coefficients[4]=
			{0.07711507983241622
			,0.4820706250610472
			,0.7968204713315797
			,0.9412514277740471
			};

			double b_coefficients[4]=
			{0.2659685265210946
			,0.6651041532634957
			,0.8841015085506159
			,0.9820054141886075
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,4);
			filter_b=new CAllPassFilterCascade(b_coefficients,4);
		}
		else if (order==6)	//rejection=51dB, transition band=0.01
		{
			double a_coefficients[3]=
			{0.1271414136264853
			,0.6528245886369117
			,0.9176942834328115
			};

			double b_coefficients[3]=
			{0.40056789819445626
			,0.8204163891923343
			,0.9763114515836773
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,3);
			filter_b=new CAllPassFilterCascade(b_coefficients,3);
		}
		else if (order==4)	//rejection=53dB,transition band=0.05
		{
			double a_coefficients[2]=
			{0.12073211751675449
			,0.6632020224193995
			};

			double b_coefficients[2]=
			{0.3903621872345006
			,0.890786832653497
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,2);
			filter_b=new CAllPassFilterCascade(b_coefficients,2);
		}
	
		else	//order=2, rejection=36dB, transition band=0.1
		{
			double a_coefficients=0.23647102099689224;
			double b_coefficients=0.7145421497126001;

			filter_a=new CAllPassFilterCascade(&a_coefficients,1);
			filter_b=new CAllPassFilterCascade(&b_coefficients,1);
		}
	}
	else	//softer slopes, more attenuation and less stopband ripple
	{
		if (order==12)	//rejection=150dB, transition band=0.05
		{
			double a_coefficients[6]=
			{0.01677466677723562
			,0.13902148819717805
			,0.3325011117394731
			,0.53766105314488
			,0.7214184024215805
			,0.8821858402078155
			};

			double b_coefficients[6]=
			{0.06501319274445962
			,0.23094129990840923
			,0.4364942348420355
			,0.06329609551399348
			,0.80378086794111226
			,0.9599687404800694
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,6);
			filter_b=new CAllPassFilterCascade(b_coefficients,6);
		}
		else if (order==10)	//rejection=133dB, transition band=0.05
		{
			double a_coefficients[5]=
			{0.02366831419883467
			,0.18989476227180174
			,0.43157318062118555
			,0.6632020224193995
			,0.860015542499582
			};

			double b_coefficients[5]=
			{0.09056555904993387
			,0.3078575723749043
			,0.5516782402507934
			,0.7652146863779808
			,0.95247728378667541
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,5);
			filter_b=new CAllPassFilterCascade(b_coefficients,5);
		}
		else if (order==8)	//rejection=106dB, transition band=0.05
		{
			double a_coefficients[4]=
			{0.03583278843106211
			,0.2720401433964576
			,0.5720571972357003
			,0.827124761997324
			};

			double b_coefficients[4]=
			{0.1340901419430669
			,0.4243248712718685
			,0.7062921421386394
			,0.9415030941737551
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,4);
			filter_b=new CAllPassFilterCascade(b_coefficients,4);
		}
		else if (order==6)	//rejection=80dB, transition band=0.05
		{
			double a_coefficients[3]=
			{0.06029739095712437
			,0.4125907203610563
			,0.7727156537429234
			};

			double b_coefficients[3]=
			{0.21597144456092948
			,0.6043586264658363
			,0.9238861386532906
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,3);
			filter_b=new CAllPassFilterCascade(b_coefficients,3);
		}
		else if (order==4)	//rejection=70dB,transition band=0.1
		{
			double a_coefficients[2]=
			{0.07986642623635751
			,0.5453536510711322
			};

			double b_coefficients[2]=
			{0.28382934487410993
			,0.8344118914807379
			};
	
			filter_a=new CAllPassFilterCascade(a_coefficients,2);
			filter_b=new CAllPassFilterCascade(b_coefficients,2);
		}
	
		else	//order=2, rejection=36dB, transition band=0.1
		{
			double a_coefficients=0.23647102099689224;
			double b_coefficients=0.7145421497126001;

			filter_a=new CAllPassFilterCascade(&a_coefficients,1);
			filter_b=new CAllPassFilterCascade(&b_coefficients,1);
		}
	}

	oldout=0.0;
};


CHalfBandFilter::~CHalfBandFilter()
{
	delete filter_a;
	delete filter_b;
};


double CHalfBandFilter::process(const double input)
{
	const double output=(filter_a->process(input)+oldout)*0.5;
	oldout=filter_b->process(input);

	return output;
}
