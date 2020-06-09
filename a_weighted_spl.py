import pyaudio # import Python pyaudio library for managing the microphone data stream
import time # import Python time library to manage time data
import numpy # import Python numpy library for working with numbers
from numpy import pi, polymul, convolve # import python numpy functions for calculating filter values
from scipy.signal.filter_design import bilinear # import python scipy functions for calculating filter values 
from scipy.signal import lfilter # import python scipy functions for calculating filter values

CHANNELS = 1 # 1 channel for mono when there is a single microphone
RATE = 44100 # Sample rate of the microphone data stream
INPUT_DEVICE = 2 # Device address of the microphone
FORMAT = pyaudio.paInt32 # Format of the microphone data stream 32 bit integer

p = pyaudio.PyAudio() # Create an instance of pyaudio


# Define a function for setting up the A Weighting filter
# ADAPTED FROM THE SPECTRAL WEIGHTING FILTERS IN SIGGIGUE / PYFILTERBANK (https://github.com/SiggiGue/pyfilterbank)
def a_weight_filter(sample_rate):
	# Definition of analog A-weighting filter according to IEC/CD 1672.
    f1 = 20.598997
    f2 = 107.65265
    f3 = 737.86223
    f4 = 12194.217
    A1000 = 1.9997
    numerators = [(2*pi*f4)**2 * (10**(A1000 / 20.0)), 0., 0., 0., 0.];
    denominators = convolve(
        [1., +4*pi * f4, (2*pi * f4)**2],
        [1., +4*pi * f1, (2*pi * f1)**2]
    )
    denominators = convolve(
        convolve(denominators, [1., 2*pi * f3]),
        [1., 2*pi * f2]
    )
    return bilinear(numerators, denominators, sample_rate)

# Create an instance of the A Weighting filter based on the sample rate    
b, a = a_weight_filter(RATE)


# Define a function to calculate root mean square for SPL
def rms_flat(a):  
    # Return the root mean square of all the elements of *a*, flattened out.
    return numpy.sqrt(numpy.mean(numpy.absolute(a)**2))

# Define a function that deals with the microphone data stream 
def callback(in_data, frame_count, time_info, status):
	# Array of amplitude values from the microphone - decoded 32bit value
    decoded = numpy.fromstring(in_data,'Int32') / float(2**18)
 	# Calculate the mean of the amplitude array and minus it from each value - in order to remove microphone offset (force to int for efficiency and divide by 2**32 to get range between 1 and -1)
    offset = decoded - int(numpy.mean(decoded))
    # Calculate and then print the un-weighted SPL value for the 
    flatSPL = 10*numpy.log10(rms_flat(offset))
    print('Original:   {:+.2f} dB'.format(flatSPL))
    # Apply the A Weighting filter to the offset microphone input
    filtered = lfilter(b, a, offset)
    # Calculate and then print the A Weighted SPL value
    aweightSPL = 10*numpy.log10(rms_flat(filtered))
    print('A-weighted: {:+.2f} dB'.format(aweightSPL))
    return (in_data, pyaudio.paContinue)

# Open a pyaudio data stream with the settings for the microphone as defined above
stream = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,
                output=True,
                stream_callback=callback)
                
# Start the microphone data stream which is passed into the callback function                
stream.start_stream()

# Keep the stream running until you tell it to stop
while stream.is_active():
    time.sleep(0.1)

# Tell the use how to end the program and stop monitoring    
print("type CTRL C to end monitoring")

# Stop and close the microphone data stream
stream.stop_stream()
stream.close()

# End the instance of Python pyaudio
p.terminate()