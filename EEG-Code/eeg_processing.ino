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

  sampling_period_us = round(1000000 * (1.0 / sampling_freq));
}

void loop() {
  state = 0;
  
  alpha_amplitude = 0;

  for (int i = 0; i < samples; i++) {
    new_time = micros();
    vReal[i] = analogRead(eeg_pin);
    vImag[i] = 0;

    if (digitalRead(key_pin) == 1) { state = 1; }
    
    while ((micros() - new_time) < sampling_period_us) {  /*wait*/  }
  }

  // FFT
  FFT.DCRemoval();
  FFT.Windowing(FFT_WIN_TYP_HAMMING, FFT_FORWARD);
  FFT.Compute(FFT_FORWARD);
  FFT.ComplexToMagnitude();

  // only getting 8-12 Hz amplitudes
  for (int i = floor(8/(sampling_freq/samples)); i < ceil(12/(sampling_freq/samples)); i++) {
    alpha_amplitude += (int)vReal[i];
  }
  
  // on key press
  if (state == 1 && !pressed) {
    Serial.println((uint8_t)round(alpha_amplitude));
    pressed = true;
  }
  else if (state == 0 && pressed) {
    pressed = false;
  }
}
