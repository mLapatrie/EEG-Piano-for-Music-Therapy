# EEG Piano for Music Therapy: Empowering Musical Expression for All

## Overview:<br/>
EEG Piano for Music Therapy offers a distinctive perspective on music therapy, catering to individuals facing physical challenges. This project stands out from conventional electroencephalogram (EEG) music initiatives by enabling users to actively partake in group sessions, fostering collective musical interaction. By using brainwave patterns captured through a homemade EEG device, this tool allows users to control the pitch of musical notes, providing an unique and accessible way to play a musical instrument without requiring extensive physical dexterity. Removing this barrier allows participants to easily join fellow musicians, creating a shared musical journey that's both therapeutic and enjoyable. 

<p align="center"><img src="https://github.com/mLapatrie/Music-Therapy-with-EEG-Piano/assets/48076370/fc47bf51-b3b5-4aa8-8ef8-ba6b18f33d32" width="1000"></p>

## This repository contains:<br/>
The repository contains the schematic for the EEG device, 3D models for the piano key parts, code for EEG data processing and two different modes of piano playing that are explained in more detail below.

## How to use the device:<br/>
### Electrode placement: 
Following the 10-20 system, the three electrodes should be placed as follow: the positive electrode on O2, the negative electrode on A2 and the ground electrode on A1. See the image below. <br/>
<p align="center"><img src="https://github.com/mLapatrie/Music-Therapy-with-EEG-Piano/assets/48076370/a74677cd-b4fc-4e85-8730-517c0483152a" width="300"></p>

### Adjusting the EEG
The output of the EEG should go into the A0 pin of the Arduino UNO board. <br/>
After placing the electrodes, one should play with the gain to get the best possible resolution with the eeg_test.ino program without experiencing clipping. Then, looking at the time-frequency domain, one needs to play with the amplitude variable to make sure that the alpha amplitude is between 0 and 255 since it is then parsed as an unsigned byte.

### 3D models
Three models that can be printed to transfrom a limit switch into a piano key, making the experience more interactive. The limit switch must then be placed between the GND and 7th pins of the Arduino UNO board. <br/>
<p align="center"><img src="https://github.com/mLapatrie/Music-Therapy-with-EEG-Piano/assets/48076370/228370ce-31d1-4e93-90fb-3885e621cd3c" width="400"></p>

### Virtual piano
Two modes can be used with this program. The first one is a simple virtual piano that maps the amplitude of the alpha waves on two octaves of the piano. Then, when a button is pressed, the mapped note is played. This allows users to familiarize themselves with the environment. However, it is to note that controlling your alpha waves to this degree of precision is almost impossible. And although it can be fun for a while, the second mode makes the experience much better.

<p align="center"><img src="https://github.com/mLapatrie/Music-Therapy-with-EEG-Piano/assets/48076370/6698c0e4-4f29-4e08-8f45-00ee18edeb5f"></p>

### Accompanied virtual piano
The second mode allows the user to play over a series of preprogrammed chords. It tracks the inputs of the user and slightly corrects them if necessary to make the music sound harmonic, as an Auto-Tune program would. This tool is especially good with jazz but works with any type of music the user prefers. <br/>
Note: By default, the program comes with a series of jazz chords playing in the background that can easily be muted. One can change the preprogrammed chords by changing the arrayOfScales variable in the assisted_virtual_piano.pde file.

## Troubleshooting
**The signal read by the Arduino is 0.0**: If you've tried adjusting the gain of the EEG and the signal is stuck at zero, the signal may be negative. You can test this by interchanging the positive and the negative electrodes. If this doesn't work, try changing to a higher value the resistor going from the inverting input to the output of the OP Amp. This should drastically augment the gain and you should get a signal that clips at 1023.0. You can then play with the value of the gain to get a good signal. While doing all of this, make sure the impedance of your electrodes is at the lowest possible value.

**The signal read by the Arduino is 1023.0**: If your signal is stuck at 1023.0, it means that your signal is too high for the Arduino to read. Try changing the gain by playing with the potentiometer.

**The eeg_test.ino file does not show anything on the serial**: Make sure that the baud rate of your serial matches the file baud rate.

If none of this works or your problem is not shown in the troubleshooting section, consider contacting me and I will be more than happy to help.

## License
This project is licensed under the [MIT License](https://github.com/mLapatrie/Music-Therapy-with-EEG-Piano/blob/main/LICENSE)
