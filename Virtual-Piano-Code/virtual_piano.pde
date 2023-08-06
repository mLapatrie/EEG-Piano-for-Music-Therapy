import processing.sound.*;
import processing.serial.*;

// Serial variables
Serial serialPort;
String val;

// Sound variables
SoundFile noteSound;
SoundFile previousSound;

int noteRange = 24; // 2*12 -> 2 octaves
int playedNote = 0;
int baseOctave = 3;

// Keyboard variables
PImage keyboard;

String[] chromaticScale = {"C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"};
int[] whites = {1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1};
int spacing = 101;
int spacingMultiplier;

boolean pressed = false; // changes the color of the note highlight

// Graph variables
int[] amplitudes = new int[100]; // stores the last 100 amplitudes of the time-frequency domain
int oldestIndex = 0; // points to the oldest variable in amplitudes


void setup() {
  size(2116, 601); // the size of the png is 1515x601. Howevers, a 601x601 square is drawn at the left of the image
  keyboard = loadImage("keyboard.png");
  
  background(0);

  rect(0, 0, 601, 601); // represents the left region where the time-frequency graph is drawn.
  
  textSize(150);
  
  for (int i = 0; i < 100; i++) { amplitudes[i] = 0; } // populates the array with zeros
  
  serialPort = new Serial(this, Serial.list()[0], 9600);
}


void draw() {
  image(keyboard, 601, 0);
  
  drawNote(playedNote, pressed); // draw a cursor above the note represented by the amplitude of the alpha waves
  
  if (serialPort.available() > 0) {
    val = serialPort.readStringUntil('\n'); // gets last string in the serial port
    
    if (val != null && val.length() > 2) { // if valid
      val = val.substring(0, val.length()-2); // remove '\n' from the end of the string
      
      if (int(val) == -1) { // the eeg_processing.ino program sends a -1 when the button is pressed
        pressed = true;
        
        if (previousSound != null) { previousSound.stop(); } // stops previous note

        // plays the note
        noteSound = new SoundFile(this, "piano-mp3/"+chromaticScale[playedNote%12]+str(floor(playedNote/12) + baseOctave)+".mp3");
        noteSound.play();

        previousSound = noteSound; // archives the note so it can be stopped only when a new one is played
        
        // changes note text
        fill(255);
        rect(0, 300, 600, 300);
        fill(0);
        text(chromaticScale[playedNote%12], 250, 500); 
      } 
      else if (val != null) { // when the button is not pressed, the eeg_processing program send the amplitude of the alpha waves
        pressed = false;
        
        amplitudes[oldestIndex] = int(val); // changed oldest value in the array to newest value
        oldestIndex += 1; // updates pointer
        if (oldestIndex >= 100) { oldestIndex = 0; } // set the pointer inbounds
        
        drawGraph();
        
        playedNote = round((int(val)*noteRange)/255); // maps the amplitude to its corresponding note
      }
    }
  }
}

// draws a cursor above the note. Blue if press, yellow and slightly transparent if !press.
void drawNote(int note, boolean press) {
  spacingMultiplier = -1;
  if (playedNote > 12) { spacingMultiplier = 6; } // sets cursor one octave further

  // finds how far the cursor should be moved based on the number of notes between the first note and the one being drawn
  for (int i = 0; i < playedNote%12; i++) { spacingMultiplier += whites[i]; }
    
  if (whites[note%12] == 1) { // uses the whites array to determine if key is white
    // draws a blue cursor over the note that is being played
    fill(255, 255, 0, 80);
    if (press) { fill(0, 0, 255); }
    rect(756 + spacing * spacingMultiplier, 84, 101, 438);
  }
  else {  // key is black
    // draws a yellow and transparent cursor over the note that is being played
    fill(255, 255, 0, 80);
    if (press) { fill(0, 0, 255); }
    rect(730 + spacing * spacingMultiplier, 84, 54, 250);
  }
}

// draws the time-frequency graph based on the amplitudes array.
// draws a line between every neighbours from the oldest to the newest point.
void drawGraph() {
  fill(255);
  rect(0, 0, 600, 300);
  for (int i = 0; i < 100; i++) {
    int y1 = (oldestIndex+i)%100;
    int y2 = (oldestIndex+i+1)%100;
    line(0 + 6*i, 280-amplitudes[y1], 6 + 6*i, 280-amplitudes[y2]);
  }
}
