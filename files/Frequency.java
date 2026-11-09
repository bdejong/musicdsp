public class Frequency extends Number
{

    private static final double PITCH_OF_A4 = 57D;
    private static final double FACTOR = 12D / Math.log(2D);
    private static final String NOTE_SYMBOL[] = {
        "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A",
        "A#", "B"
    };
    public static float frequencyOfA4 = 440F;
    private float frequency;

    public static final double getPitch(float f)
    {
        return getPitch(f);
    }

    public static final double getPitch(double d)
    {
        return 57D + FACTOR * Math.log(d / (double)frequencyOfA4);
    }

    public static final float getFrequency(double d)
    {
        return (float)(Math.exp((d - 57D) / FACTOR) * (double)frequencyOfA4);
    }

    public static final String makeNoteSymbol(double d)
    {
        int i = (int)(d + 120.5D);
        StringBuffer stringbuffer = new StringBuffer(NOTE_SYMBOL[i % 12]);
        stringbuffer.append(Integer.toString(i / 12 - 10));
        return new String(stringbuffer);
    }

    public static float valueOf(String s)
        throws IllegalArgumentException
    {
        try
        {
            return (new Float(s)).floatValue();
        }
        catch(NumberFormatException _ex) { }
        try
        {
            return getFrequency(parseNoteSymbol(s));
        }
        catch(IllegalArgumentException _ex)
        {
            throw new IllegalArgumentException("Neither a floating point number nor a valid note symbol.");
        }
    }

    public static final int parseNoteSymbol(String s)
        throws IllegalArgumentException
    {
        s = s.trim().toUpperCase();
        for(int i = NOTE_SYMBOL.length - 1; i >= 0; i--)
        {
            if(!s.startsWith(NOTE_SYMBOL[i]))
                continue;
            try
            {
                return i + 12 * Integer.parseInt(s.substring(NOTE_SYMBOL[i].length()).trim());
            }
            catch(NumberFormatException _ex) { }
            break;
        }

        throw new IllegalArgumentException("not valid note symbol.");
    }

    public static void transformPitch(TextComponent textcomponent, boolean flag)
    {
        boolean flag1 = false;
        String s = textcomponent.getText();
        if(flag)
        {
            try
            {
                textcomponent.setText(Integer.toString((int)(getFrequency(parseNoteSymbol(s)) + 0.5F)));
                return;
            }
            catch(IllegalArgumentException _ex)
            {
                flag1 = true;
            }
            return;
        }
        try
        {
            textcomponent.setText(makeNoteSymbol(getPitch((new Float(s)).floatValue())));
            return;
        }
        catch(NumberFormatException _ex)
        {
            flag1 = true;
        }
    }

    public Frequency(float f)
    {
        frequency = 1.0F;
        frequency = f;
    }

    public Frequency(String s)
        throws IllegalArgumentException
    {
        frequency = 1.0F;
        frequency = valueOf(s);
    }

    public byte byteValue()
    {
        return (byte)(int)(frequency + 0.5F);
    }

    public short shortValue()
    {
        return (short)(int)(frequency + 0.5F);
    }

    public long longValue()
    {
        return (long)(frequency + 0.5F);
    }

    public int intValue()
    {
        return (int)(frequency + 0.5F);
    }

    public float floatValue()
    {
        return frequency;
    }

    public double doubleValue()
    {
        return (double)frequency;
    }

    public String toString()
    {
        return Integer.toString(intValue());
    }

    public String toNoteSymbol()
    {
        return makeNoteSymbol(getPitch(frequency));
    }

    public static void main(String[] args)
    {
        System.out.println(Frequency.parseNoteSymbol("C2"));
	System.out.println(Frequency.getFrequency(24));
    }
}
