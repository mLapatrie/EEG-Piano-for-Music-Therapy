
import processing.sound.*;
import processing.serial.*;

SoundFile file;
Serial serialPort;

public String val;

public int noteRange = 24; // 2*12 -> 3 octaves

public int playedNote = 0;

public int baseOctave = 3;

public String[] chromatic_scale = {"C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"};

public SoundFile previousSound;

void setup() {
  size(640,360);
  background(255);
  
  serialPort = new Serial(this, Serial.list()[0], 9600);
}

void draw() {
  if (serialPort.available() > 0) {
    
    if (previousSound != null) {
       previousSound.stop(); 
    }
    
    val = serialPort.readStringUntil('\n');
    
    if (val != null) {
      val = val.substring(0, val.length()-2);
      
      playedNote = round((int(val)*noteRange)/255);
    
      SoundFile noteSound = new SoundFile(this, "piano-mp3/"+chromatic_scale[playedNote%12]+str(floor(playedNote/12) + baseOctave)+".mp3");
    
      noteSound.amp(1);
      noteSound.play();
      
      previousSound = noteSound;
    }
  }
}
