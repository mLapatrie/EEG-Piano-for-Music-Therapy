#include <arduinoFFT.h>

// FFT variables
const uint8_t samples = 128;
const uint16_t sampling_freq = 500;
const uint8_t amplitude = 1;
unsigned int alpha_amplitude = 0;
double vReal[samples];
double vImag[samples];
arduinoFFT FFT = arduinoFFT(vReal, vImag, samples, sampling_freq);

// arduino board
const uint8_t eeg_pin = A0;
const uint8_t key_pin = 7;
bool pressed = false;
bool state = LOW;

// delay
unsigned int sampling_period_us;
unsigned long new_time;


void setup() {
  Serial.begin(9600);

  pinMode(key_pin, INPUT);

  sampling_period_us = round(1000000 * (1.0 / sampling_freq)); // calculates the wait time between each analog read
}


void loop() {
  state = 0;
  alpha_amplitude = 0;

  // populates the array vReal for the FFT over samples/sampling_frequency seconds
  for (int i = 0; i < samples; i++) {
    new_time = micros(); // gets current time in us
    vReal[i] = analogRead(eeg_pin);
    vImag[i] = 0;

    // listens for key press and sends a -1 over the serial port when pressed down
    state = digitalRead(key_pin);
    if (state == 1 && !pressed) {
      Serial.println(-1);
      pressed = true;
    } 
    else if (state == 0 && pressed) { pressed = false; }

    // waits until the difference between new_time and current time is sampling_period_us
    while ((micros() - new_time) < sampling_period_us) {  /*wait*/  }
  }

  // Processing the FFT
  FFT.DCRemoval();
  FFT.Windowing(FFT_WIN_TYP_HAMMING, FFT_FORWARD);
  FFT.Compute(FFT_FORWARD);
  FFT.ComplexToMagnitude();

  // isolating frequencies between 8-12 Hz
  for (int i = floor(8/(sampling_freq/samples)); i < ceil(12/(sampling_freq/samples)); i++) {
    alpha_amplitude += (int)vReal[i];
  }

  // sending the amplitude of the alpha waves over the serial port
  // the signal sent is between 0 and 255. If clipping, one must play with the amplitude variable.
  Serial.println((uint8_t)round(alpha_amplitude));
}
