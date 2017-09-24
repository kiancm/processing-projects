import ddf.minim.*;
import ddf.minim.analysis.*;

int sampleSize = 1024;
float lerpRate;
float attack = .6;
float decay = .2;
float [] lastBand;
float [] lastWave;
float period = 2 * PI / sampleSize;
Minim minim;
BeatDetect detect;
AudioInput ain;
AudioPlayer song;
FFT fft;

void setup() {
  size(700, 500);
  lastBand = new float[sampleSize];
  lastWave = new float[sampleSize];
  minim = new Minim(this);
  detect = new BeatDetect();
  ain = minim.getLineIn(Minim.MONO, sampleSize);
  song = minim.loadFile("ifeelitcoming.mp3", sampleSize);
  fft = new FFT(ain.bufferSize(), ain.sampleRate());
  fft = new FFT(song.bufferSize(), song.sampleRate());
  song.loop();
}

void draw() {
  fill(50, 100);
  rect(0, 0, width, height);
  // fft.forward(ain.mix);
  fft.forward(song.mix);
  detect.detect(song.mix);
  fill(0);
  stroke(0);
  for (int i = 1; i < sampleSize; i++) {
      lerpRate = fft.getBand(i) > lastBand[i] ? attack : decay;
      lastBand[i] = lerp(lastBand[i], fft.getBand(i), lerpRate);
      // lastWave[i] = lerp(lastWave[i], ain.mix.get(i), .45);
      lastWave[i] = lerp(lastWave[i], song.mix.get(i), detect.isOnset() ? 1 : .35) + (detect.isOnset() ? 7 : 2);   
      line(i - 1, height/2 + lastWave[i - 1] * 100, i, height/2 + lastWave[i] * 100);
      float lr = lastWave[i - 1] * 25;
      float r = lastWave[i] * 25;
      if (i - 1 != 0)
        line(width / 2 + lr * cos((i - 1) * period), height / 2 + lr * sin((i - 1) * period), width / 2 + r * cos(i * period), height / 2 + r * sin(i * period));
      rect(i, height, 3, ((lastBand[i] + (detect.isOnset() ? -20 : 0)) * (detect.isOnset() ? -15 : -10)) % height / 3);
  }
}