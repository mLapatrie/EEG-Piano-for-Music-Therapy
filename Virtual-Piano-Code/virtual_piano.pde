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

String[] chromatic_scale = {"C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"};
int[] whites = {1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1};
int spacing = 101;
int spacingMultiplier;

boolean pressed = false; // changes the color of the note highlight

// Graph variables
int[] amplitudes = new int[100]; // stores the last 100 amplitudes of the time-frequency domain
int oldest_index = 0; // points to the oldest variable in amplitudes


void setup() {
  size(2116, 601);
  keyboard = loadImage("keyboard.png");
  
  background(0);
  rect(0, 0, 601, 601);
  
  textSize(150);
  
  for (int i = 0; i < 100; i++) { amplitudes[i] = 0; }
  
  serialPort = new Serial(this, Serial.list()[0], 9600);
}


void draw() {
  image(keyboard, 601, 0);
  
  drawNote(playedNote, pressed);
  
  if (serialPort.available() > 0) {
    val = serialPort.readStringUntil('\n');
    
    if (val != null && val.length() > 2) {
      val = val.substring(0, val.length()-2);
      
      if (int(val) == -1) {
        pressed = true;
        
        // sound
        if (previousSound != null) {
         previousSound.stop(); 
        }
        noteSound = new SoundFile(this, "piano-mp3/"+chromatic_scale[playedNote%12]+str(floor(playedNote/12) + baseOctave)+".mp3");
        noteSound.amp(1);
        noteSound.play();
        previousSound = noteSound;
        
        // change note text
        fill(255);
        rect(0, 300, 600, 300);
        fill(0);
        text(chromatic_scale[playedNote%12], 250, 500); 
      } 
      else if (val != null) {
        pressed = false;
        
        amplitudes[oldest_index] = int(val);
        oldest_index += 1;
        if (oldest_index >= 100) { oldest_index = 0; }
        
        drawGraph();
        
        playedNote = round((int(val)*noteRange)/255);
      }
    }
  }
}


void drawNote(int note, boolean press) {
  spacingMultiplier = -1;
  if (playedNote > 12) { spacingMultiplier = 6; }
  
  if (whites[note%12] == 1) {
    for (int i = 0; i < playedNote%12; i++) {
      spacingMultiplier += whites[i];
    }
    
    fill(255, 255, 0, 80);
    if (press) { fill(0, 0, 255); }
    rect(756 + spacing * spacingMultiplier, 84, 101, 438);
  }
  else {
    for (int i = 0; i < playedNote%12; i++) {
      spacingMultiplier += whites[i];
    }
          
    fill(255, 255, 0, 80);
    if (press) { fill(0, 0, 255); }
    rect(730 + spacing * spacingMultiplier, 84, 54, 250);
  }
}


void drawGraph() {
  fill(255);
  rect(0, 0, 600, 300);
  for (int i = 0; i < 100; i++) {
    int y1 = (oldest_index+i)%100;
    int y2 = (oldest_index+i+1)%100;
    line(0 + 6*i, 280-amplitudes[y1], 6 + 6*i, 280-amplitudes[y2]);
  }
}
