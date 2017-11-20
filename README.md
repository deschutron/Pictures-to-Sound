# Pictures-to-Sound
A reversible spectrograms maker - so you can turn your sound into pictures, edit it, and convert it back into sound.

The .m files contain the logic.

The .cmd files are to let you use it without running Octave or Matlab first.
I originally wrote them for a friend so that could play around with my program for musical purposes.

The file test.wav is a sound file to test the program on.

The "process" function, in process.m, will create a file called test.wav.png when applied to it.
Then, running "unprocess" on that will create test.wav.png.wav.
