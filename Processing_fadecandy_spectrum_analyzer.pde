/**
 * Processing_fadecandy_spectrum_analyzer.pde
 */

OPC opc;

final int boxesAcross = 2;
final int boxesDown = 2;
final int ledsAcross = 8;
final int ledsDown = 8;
// initialized in setup()
float spacing;
int x0;
int y0;

// for exit, fade in and fade out
int exitTimer = 0;
int start_ms = 0;
int fadeLevel = 100;
boolean fadeInDone = false;

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
}

public void draw() {
  noStroke();
  color c = 0;
  for (int y = 0; y < boxesDown * ledsDown; y++) {
    for (int x = 0; x < boxesAcross * ledsAcross; x++) {
      c = color((int)random(256), (int)random(256), (int)random(256));  // Define color 'c'
      fill(c);
      square(x0 + spacing * x, y0 + spacing * y, spacing);
    }
  }

  // debug only - dump the last colour used
  dumpColour(c);

  // get a random colour part (r, g or b)
  int testColour = getRandomColourPart(c);
  println(" " + String.format("%02x", testColour));

  check_exit();
}

// nod to https://processing.org/reference/rightshift.html
void dumpColour(int c) {
  int r = (c >> 16) & 0xFF;  // Faster way of getting red(argb)
  int g = (c >> 8) & 0xFF;   // Faster way of getting green(argb)
  int b = c & 0xFF;
  print(String.format("%02x", r) + " " + String.format("%02x", g) + " " + String.format("%02x", b));
}

int getRandomColourPart(int c) {
  int partIndex = (int)random(3.0);

  // debug only
  String[] tmpColourNames = {"blue", "green", "red"};
  String tmpColourName = tmpColourNames[partIndex];
  print(" extracted " + String.format("%5s", tmpColourName));

  while (partIndex-- > 0) { c = c >> 8; }
  return c & 0xFF;
}

void apply_cmdline_args()
{
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
