
Processing fadecandy spectrum analyzer
--------------------------------------

But it's not yet, is a WIP...

Cmd Line
--------

rem Windows

    path %PATH%;D:\Apps\processing-3.5.4
    processing-java.exe --sketch=%cd%\Processing_fadecandy_spectrum_analyzer --run exit=60

\# raspi (vnc)

    processing-java --sketch=./Processing_fadecandy_spectrum_analyzer --run exit=60

\# raspi (ssh i.e. headless)

    xvfb-run processing-java --sketch=./Processing_fadecandy_spectrum_analyzer --run exit=60

Code sample, return a random colour part
----------------------------------------

    int getRandomColourPart(int c) {
      int partIndex = (int)random(3.0);
      while (partIndex-- > 0) { c >>>= 8; }
      return c & 0xFF;
    }
