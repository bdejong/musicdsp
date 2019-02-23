#include <vector>
#include <exception>

using std::vector;
using std::exception;

template<class T> class LockFreeFifo
{
public:
	LockFreeFifo (unsigned bufsz) : readidx(0), writeidx(0), buffer(bufsz)
	{}

	T get (void)
	{
		if (readidx == writeidx)
			throw runtime_error ("underrun");
		
		T result = buffer[readidx];
		
		if ((readidx + 1) >= buffer.size())
			readidx = 0;
		else
			readidx = readidx + 1;

		return result;
	}

	void put (T datum)
	{
		unsigned newidx;
		
		if ((writeidx + 1) >= buffer.size())
			newidx = 0;
		else
			newidx = writeidx + 1;

		if (newidx == readidx)
			throw runtime_error ("overrun");
		
		buffer[writeidx] = datum;
		
		writeidx = newidx;
	}
	
private:

	volatile unsigned  readidx, writeidx;
	vector<T> buffer;
};