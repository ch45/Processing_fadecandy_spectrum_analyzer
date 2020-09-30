/**
 * Processing_fadecandy_spectrum_analyzer.pde
 */

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer sound; // mp3 input
// AudioInput sound; // microphone input
FFT fftLog;
final int maxAmplitude = 255;

OPC opc;

final int boxesAcross = 2;
final int boxesDown = 2;
final int ledsAcross = 8;
final int ledsDown = 8;
// initialized in setup()
float spacing;
int x0;
int y0;

final color setColour = color(200, 150, 100);
final color unsetColour = color(0, 0, 50);

// for exit, fade in and fade out
int exitTimer = 0;

public void setup() {

  apply_cmdline_args();

  size(720, 480, P2D);

  // Connect to the local instance of fcserver
  opc = new OPC(this, "127.0.0.1", 7890);

  spacing = (float)min(height / (boxesDown * ledsDown + 1), width / (boxesAcross * ledsAcross + 1));
  x0 = (int)(width - spacing * (boxesAcross * ledsAcross - 1)) / 2;
  y0 = (int)(height - spacing * (boxesDown * ledsDown - 1)) / 2;

  final int boxCentre = (int)((ledsAcross - 1) / 2.0 * spacing); // probably using the centre in the ledGrid8x8 method
  int ledCount = 0;
  for (int y = 0; y < boxesDown; y++) {
    for (int x = 0; x < boxesAcross; x++) {
      opc.ledGrid8x8(ledCount, x0 + spacing * x * ledsAcross + boxCentre, y0 + spacing * y * ledsDown + boxCentre, spacing, 0, false, false);
      ledCount += ledsAcross * ledsDown;
    }
  }

  minim = new Minim(this);

  sound = minim.loadFile("083_trippy-ringysnarebeat-3bars.mp3", 1024);  // mp3 input
  // sound = minim.getLineIn(Minim.MONO, 1024); // microphone input

  // loop the file
  sound.loop(); // mp3 input

  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT(sound.bufferSize(), sound.sampleRate()); // may fail if the microphone device is already in use!

  fftLog.logAverages(22, 3);
  // fftLog.logAverages(11, 1);
}

// draw the display like it is the descrete LEDs
public void draw() {

  fftLog.forward(sound.mix);
  int numSpectrumBars = fftLog.avgSize();

  float horizRatio = (float)numSpectrumBars / (boxesAcross * ledsAcross);

  if (horizRatio > 1.0) { // map every one, 2nd or 3rd etc. to the display
    horizRatio = floor(horizRatio);
  }

  int startBar = (int)(numSpectrumBars - horizRatio * boxesAcross * ledsAcross);
  if (startBar >= 2) { // use the middle of the spectrum in the display
    startBar /= 2;
  }

  float vertLogarithm = pow(maxAmplitude, (1.0 / (boxesDown * ledsDown)));

  background(0);
  noStroke();

  for (int x = 0; x < boxesAcross * ledsAcross; x++) {
    float vertMax = maxAmplitude; // pow(vertLogarithm, boxesDown * ledsDown);
    int curSpectrumBar = (int)(startBar + horizRatio * x);
    // float freq = fftLog.getAverageCenterFrequency(curSpectrumBar);
    float amplitude = fftLog.getBand(curSpectrumBar);

    for (int y = 0; y < boxesDown * ledsDown; y++) {
      vertMax /= vertLogarithm;
      int c = (amplitude > vertMax) ? setColour : unsetColour; 
      fill(c);
      square(x0 + spacing * x - spacing / 2, y0 + spacing * y - spacing / 2, spacing - 1);
    }
  }

  check_exit();
}

void apply_cmdline_args() {

  if (args == null) {
    return;
  }

  for (String exp: args) {
    String[] comp = exp.split("=");
    switch (comp[0]) {
    case "exit":
      exitTimer = parseInt(comp[1], 10);
      println("exit after " + exitTimer + "s");
      break;
    }
  }
}

void check_exit() {

  if (exitTimer == 0) { // skip if not run from cmd line
    return;
  }

  int m = millis();
  if (m / 1000 >= exitTimer) {
    exit();
  }
}
