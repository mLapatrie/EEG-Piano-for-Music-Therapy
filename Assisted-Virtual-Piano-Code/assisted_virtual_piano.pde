import processing.sound.*;
import processing.serial.*;

// Music variables
public String[] arrayOfScales = {"A B C D E Gb G", "D E Gb G A B C", "G A B C D E Gb G",
                   "C D E Gb G A B", "Gb G A B Db Eb E", "B Db Eb E Gb G A", "E Gb G A B Db Eb",
                   "E Gb G A B Db Eb", "A B C D E Gb G", "D E Gb G A B C", "G A B C D E Gb G",
                   "C D E Gb G A B", "Gb G A B Db Eb E", "B Db Eb E Gb G A", "E Gb G A B Db Eb",
                   "E Gb G A B Db Eb", "Gb G A B Db Eb E", "B Db Eb E Gb G A", "E Gb G A B Db Eb",
                   "E Gb G A B Db Eb", "A B C D E Gb G", "D E Gb G A B C", "G A B C D E Gb G",
                   "G A B C D E Gb G", "Gb G A B Db Eb E", "B Db Eb E Gb G A", "E Gb G A B Db Eb",
                   "E Gb G A B Db Eb", "C D E Gb G A B", "B Db Eb E Gb G A", "E Gb G A B Db Eb",
                   "E Gb G A B Db Eb"};
SoundFile chordsMp3;
int currentBar = 0;
int barLength = 4;
int tempo = 110;
float timePerBar;
float startTime = 0;
boolean previousTrans = false;

// Serial variables
Serial serialPort;
String val;

// Sound variables
SoundFile notesSounds[] = new SoundFile[3];
int oldestSoundIndex = 0;

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
  
  chordsMp3 = new SoundFile(this, "chords.mp3"); // sets background tracks to chords.mp3
  chordsMp3.amp(0.25); // sets the volume to a quarter
  chordsMp3.play();
  
  startTime = millis(); // records the starting time
  timePerBar = (60000/tempo)*barLength; // how long the program should wait before going to the next bar (ms)
  print(timePerBar);
}


void draw() {
  image(keyboard, 601, 0);
  
  if (millis()-startTime >= timePerBar*(currentBar+1) && currentBar < arrayOfScales.length-1) { currentBar += 1; } // updates the currentBar variable at every timePerBar ms
  
  drawNote(playedNote, pressed); // draw a cursor above the note represented by the amplitude of the alpha waves
  
  if (serialPort.available() > 0) {
    val = serialPort.readStringUntil('\n'); // gets last string in the serial port
    
    if (val != null && val.length() > 2) { // if valid
      val = val.substring(0, val.length()-2); // remove '\n' from the end of the string
      
      if (int(val) == -1) { // the eeg_processing.ino program sends a -1 when the button is pressed
        pressed = true;
        
        if (notesSounds[oldestSoundIndex] != null) { notesSounds[oldestSoundIndex].removeFromCache(); } // stops oldest note

        playedNote = adjustNote(playedNote); // adjust note
        
        // plays the note
        notesSounds[oldestSoundIndex] = new SoundFile(this, "piano-mp3/"+chromaticScale[playedNote%12]+str(floor(playedNote/12) + baseOctave)+".mp3"); // "piano-mp3/NoteOctave.mp3"
        notesSounds[oldestSoundIndex].play();

        oldestSoundIndex += 1; // changes oldest index
        if (oldestSoundIndex >= notesSounds.length-1) { oldestSoundIndex = 0; }
        
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

// takes the mappedNote and looks if it is melodically align with the bars being played.
// If not, it slightly changes the played note.
int adjustNote(int note) {
  String[] scale = split(arrayOfScales[currentBar], " "); // creates array of notes contained in the chord being played
  
  if (!elementInArray(chromaticScale[note%12], scale)) { // if played note is not contained in scale
    if (note < (noteRange-1)) { note += 1; } 
    else { note -= 1; }
  }
  return note;
}

// returns true if targetElement is found in array, else returns false
boolean elementInArray(String targetElement, String[] array) {
  for (int i = 0; i < array.length; i++) { if (array[i] == targetElement) return true; }
  return false;
}
