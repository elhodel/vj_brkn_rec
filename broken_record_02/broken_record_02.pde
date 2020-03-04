import ddf.minim.*;   
import ddf.minim.analysis.*;  
Minim minim;   
FFT fft;  
AudioInput in;  
BeatDetect beat;
BeatListener bl;

float amp = 15; // from testing, 15 seems to be good...
float ampWave; // used to strengthen signal   
float avgAudio; // store avg volume  
float maxAudio = 10; // store loudest volume
float easeAudio; 
float easing = 0.25; // easing amount
float normalizedAudio;
int beatSensitivity = 10;

import processing.pdf.*;
boolean savePDF = false;
boolean saveCollection = false;
color bg = #000000; //#edd400;
color strk =#ffffff;// #a33600;
float opacity = 255;

int numPoint = 4;
float angleStep;

float rad =400;
float maxOffset = 200;
float edgeRate;
float x, y, a;
float strkW;
PVector[] points;

float bgFade = 10;


int rings =1;
float ringsSpacing;
float ringsStrkRandomMin;
float ringsStrkRandomMax;
int seed;
float rotation = 0;
float rotationRate = 0.1;//radians(1);


float rotationOffsetNum = 6;
float rotationOffsetAngle = radians(1);

float scaleNum = 40;
float scaleFactor= 1.01;

PVector translation = new PVector(20, -10);
float gaussianFactor = .2;

int dnaMin = 0;
int dnaMax = 1023;


boolean[][] audioDependant = new boolean[5][16];
boolean[] mixerRandom = new boolean[16]; 

boolean clear;
String timestampCollection;
char[] dnaProteins = {'a', 't', 'c', 'g'};
void setup() {
  size(1000, 1000);

  //AUDIO
  minim = new Minim(this); // initalize in setup   
  in = minim.getLineIn(Minim.STEREO, 512); // audio in + bufferSize 512 or 1024 
  fft = new FFT(in.bufferSize(), in.sampleRate());  
  fft.logAverages(22, 3); // 3 = 30, 4 = 40, etc..
  ampWave = amp*10;
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());

  beat.setSensitivity(beatSensitivity);  

  bl = new BeatListener(beat, in);  

  midiInit();
  seed =floor(random(100000));

  //type_3_länglich
  //2017_11_28_18153300761_12800_0.69_0.48_0.07_0.00_0.84_0.27_0.00_
  //1.00_0.19_0.42_1.00_0.45_0.00_0.53_0.00_0.18
  mixer2d[0][0] = .69;
  mixer2d[0][1] = .48;
  mixer2d[0][2] = 0.07;
  mixer2d[0][3] = 0.00;
  mixer2d[0][4] = 0.84;
  mixer2d[0][5] = 0.27;
  mixer2d[0][6] = .1;
  mixer2d[0][7] = 1;
  mixer2d[0][8] = 0.19;
  mixer2d[0][9] = 0.42;
  mixer2d[0][10] = 1;
  mixer2d[0][11] = 0.45;
  mixer2d[0][12] = 0;
  mixer2d[0][13] = 0.53;
  mixer2d[0][14] = 0;
  mixer2d[0][15] = 0.18;


  mixer2d[1][0] = .1;
  mixer2d[1][1] = 0;
  mixer2d[1][2] = 0;
  mixer2d[1][3] = 0.00;
  mixer2d[1][4] = 0.84;
  mixer2d[1][5] = 0.27;
  mixer2d[1][6] = 0;
  mixer2d[1][7] = .5;

  mixer2d[1][8] = 0.19;
  mixer2d[1][9] = 0.42;
  mixer2d[1][10] = 1;
  mixer2d[1][11] = 0.45;
  mixer2d[1][12] = 0;
  mixer2d[1][13] = 0.53;
  mixer2d[1][14] = 0;
  mixer2d[1][15] = 0.18;

  resetMixer();

  //noLoop();
  background(bg);
}

void draw() {
  //savePDF = true;
  //println(frameCount, frameRate);
  //randomSeed(seed);

  updateAvgAudio();
  remapMidiButton();
  gaussianFactor = mixer[6];

  println(midiMode);

  /*for (int i = 0; i<mixer.length; i++) {
   if (mixerRandom[i]) {
   //mixer2d[0][i] = constrain(mixer[i]+randomGaussian()*gaussianFactor, 0, 1);
   mixer2d[0][i] = constrain(mixer[i]+random(-gaussianFactor, gaussianFactor), 0, 1);
   } else {
   mixer2d[0][i] = mixer[i];
   }
   }*/

  //printArray(button);

  float minInfluence = setValueFromMixer(0, 1, 1, 6, false, false);//lerp(0, 1, mixer2d[1][6]);
  float maxInfluence = setValueFromMixer(minInfluence, 4, 1, 7, false, false); //lerp(minInfluence, 4, mixer2d[1][7]);


  normalizedAudio = map(easeAudio, 0, maxAudio, minInfluence, maxInfluence);

  easing = setValueFromMixer(0, 1, 0, 6, false, false);//mixer2d[0][6];


  rad = lerp(10, width/2, mixer2d[0][0]);
  if (valueIsInActiveArea(0, 0)) {
    rad *= lerp(1, 2, normalizedAudio);
  } 
  //if (valueIsInActiveArea(0)) {
  //rad = lerp(10, width/2, normalizedAudio);
  //}
  maxOffset = setValueFromMixer(0,1,0,1,true,false); //lerp(0, 1, mixer2d[0][1]);
  if (valueIsInActiveArea(0, 1)) {
    maxOffset = lerp(0, 1, normalizedAudio);
  }
  numPoint = floor(lerp(3, 60, mixer2d[0][2]));
  if (valueIsInActiveArea(0, 2)) {
    numPoint = floor(lerp(3, 60, constrain01(normalizedAudio)));
  }
  edgeRate = mixer2d[0][3];
  if (valueIsInActiveArea(0, 3)) {
    edgeRate = normalizedAudio;
  }
  float skewX;

  skewX = mixer2d[0][4];
  if (valueIsInActiveArea(0, 4)) {
    skewX = normalizedAudio;
  }
  float skewY;
  skewY = mixer2d[0][5];
  if (valueIsInActiveArea(0, 5)) {
    skewY = normalizedAudio;
  }


  //strkW = .1;

  //strkW = .1;
  rings = floor(lerp(1, 10, mixer2d[0][8]));
  if (valueIsInActiveArea(0, 8)) {
    rings = floor(lerp(1, 10, constrain01(normalizedAudio)));
  }


  ringsSpacing = lerp(1, 200, mixer2d[0][9]);
  if (valueIsInActiveArea(0, 9)) {
    ringsSpacing = lerp(1, 200, normalizedAudio);
  }


  ringsStrkRandomMin = 1;
  ringsStrkRandomMax = 1;
  //ringsStrkRandomMin = lerp(.1, 10, mixer2d[0][10]);
  //ringsStrkRandomMax = lerp(ringsStrkRandomMin, 10, mixer2d[0][11]);
  //rotation = lerp(0,TWO_PI,mixer2d[0][6]);
  scaleNum = lerp(1, 10, mixer2d[0][10]);
  if (valueIsInActiveArea(0, 10)) {
    scaleNum = lerp(1, 10, constrain01(normalizedAudio));
  }

  scaleFactor= lerp(.8, 1.2, mixer2d[0][11]); 
  if (valueIsInActiveArea(0, 11)) {
    scaleFactor= lerp(.8, 1.2, normalizedAudio);
  }


  rotationOffsetNum = lerp(1, 10, mixer2d[0][12]);
  if (valueIsInActiveArea(0, 12)) {
    rotationOffsetNum = lerp(1, 10, constrain01(normalizedAudio));
  }


  rotationOffsetAngle = lerp(0, HALF_PI/8, mixer2d[0][13]);
  if (valueIsInActiveArea(0, 13)) {
    rotationOffsetAngle = lerp(0, HALF_PI/8, normalizedAudio);
  }

  float translationAngle;
  translationAngle  = lerp(0, TWO_PI, mixer2d[0][14]);
  if (valueIsInActiveArea(0, 14)) {
    translationAngle  = lerp(0, TWO_PI, normalizedAudio);
  }



  float translationMag;
  translationMag  = lerp(0, 100, mixer2d[0][15]);
  if (valueIsInActiveArea(0, 15)) {
    translationMag  = lerp(0, 100, normalizedAudio);
  }

  bgFade =  lerp(0, 255, mixer2d[1][0]);
  if (valueIsInActiveArea(1, 0)) {
    bgFade =  lerp(0, 255, normalizedAudio);
  }

  bg = lerpColor(#000000, #ffffff, mixer2d[1][1]);
  if (valueIsInActiveArea(1, 1)) {
    bg = lerpColor(#000000, #ffffff, normalizedAudio);
  }
  strk = lerpColor(#ffffff, #ff0000, mixer2d[1][2]);
  if (valueIsInActiveArea(1, 2)) {
    strk = lerpColor(#ffffff, #ff0000, normalizedAudio);
  }


  rotationRate = lerp(0, 0.4, mixer2d[1][8]);
  if (valueIsInActiveArea(1, 8)) {
    rotationRate = lerp(0, 0.4, normalizedAudio);
  }

  seed = floor(lerp(10, 10000, mixer2d[1][9]));

  float strobeFreq = lerp(0, 127, mixer2d[1][10]);
  if (valueIsInActiveArea(1, 10)) {
    strobeFreq = lerp(127, 1, normalizedAudio);
  }

  strkW = lerp(.1, 10, mixer2d[1][15]);
  if (valueIsInActiveArea(1, 15)) {
    strkW = lerp(.1, 10, normalizedAudio);
  }


  if (strobeFreq > 0) {
    if (frameCount%strobeFreq == 0) {
      color temp = strk;
      bg = lerpColor(#000000, #ffffff, 1-mixer2d[1][1]);
      strk = lerpColor(#ffffff, #ff0000, 1-mixer2d[1][2]);
    }
  }

  float translationX = cos(translationAngle);
  float translationY = sin(translationAngle);

  translation.set(translationX, translationY);
  translation.setMag(translationMag);
  //rotationRate = lerp(0, .01, mixer2d[0][13]);
  rotation += rotationRate;
  //bgFade = lerp(0, 255, mixer2d[0][14]);

  /*
  if (!saveCollection) {
   seed = floor(lerp(10, 10000, mixer2d[1][9]));
   } else {
   seed += floor(random(20, 180));
   rotation += 69*rotationRate;
   }*/

  points = new PVector[numPoint+3];

  angleStep = 360.0/(numPoint);



  String outputName = "" + convertToBase(seed, 4);
  String timeStamp = timestamp();

  for (int i = 0; i<mixer2d[0].length; i++) {
    int v = round(map(mixer2d[0][i], 0, 1, 0, 1023));
    String dna = convertToBase(v, 4);
    char[] prot = dna.toCharArray();
    outputName+="_";
    for (int c = 0; c<prot.length; c++) {
      int protInt = Integer.parseInt(str(prot[c])); 
      outputName += dnaProteins[protInt];
    }
  }
  //println(outputName);
  if (saveCollection) beginRecord(PDF, "pdf/"+timestampCollection+"/" + timeStamp+"#####_" + outputName + ".pdf");
  if (savePDF) beginRecord(PDF, "pdf/" + timeStamp+"#####_" + outputName + ".pdf");
  //background(255);
  //blendMode(MULTIPLY  );




  if (clear) {
    background(bg);
    clear = false;
  }
  backgroundFade(round(bgFade));
  translate(width/2, height/2);
  rotate(rotation);


  //center bacteria again
  PVector offset = new PVector();
  offset = translation.copy();
  offset.mult(-rotationOffsetNum/2);
  translate(offset.x, offset.y);
  //circle based



  for (int k = 0; k<rotationOffsetNum; k++) {
    pushMatrix();
    translate(k*translation.x, k*translation.y);
    rotate(k*rotationOffsetAngle);
    for (int l = 0; l<scaleNum; l++) {
      scale(scaleFactor);

      randomSeed(seed);
      for (int j = 0; j<rings; j++) {
        //rotate(random(0,HALF_PI));
        strokeWeight(strkW*random(ringsStrkRandomMin, ringsStrkRandomMax));
        //randomSeed(seed);
        //println(j, rings, ringsSpacing);
        for (int i = 0; i<points.length; i++) {
          float radOffset = random(1-maxOffset, 1+maxOffset);
          float tempRad = rad+radOffset;
          a = (i)*angleStep;
          x = cos(radians(a))*(rad+j*ringsSpacing);
          y = sin(radians(a))*(rad+j*ringsSpacing);    
          //skew:
          x*=skewX;
          y*=skewY;

          x= lerp(0, x, radOffset);
          y= lerp(0, y, radOffset);
          points[i] = new PVector(x, y);
        }
        points[points.length-3] = points[0];
        points[points.length-2] = points[1];
        points[points.length-1] = points[2];
        stroke(strk, opacity);
        noFill();

        beginShape();

        for (int i = 0; i<points.length; i++) {

          PVector p = points[i]; 
          /*pushStyle();
           stroke(0);
           fill(0, 150);
           strokeWeight(1);
           // ellipse(p.x,p.y,10,10);
           popStyle();
           
           */
          if (random(1)>edgeRate || i==0 || i>=points.length-3) {
            curveVertex(p.x, p.y);
          } else {
            vertex(p.x, p.y);
          }
        }

        /* println(a);
         a+= angleStep;
         println(a);
         x = cos(radians(a))*rad;
         y = sin(radians(a))*rad;
         curveVertex(x, y);*/
        endShape();
      }
    }
    popMatrix();
  }

  if (savePDF ) {
    savePDF = false;
    saveFrame("png/"+timeStamp+"_######"+outputName+".png");
    endRecord();
  }

  if (saveCollection) {
    saveFrame("png/" +timestampCollection+"/" + timeStamp+"#####_"+outputName+".png");
    endRecord();
  }
}

void resetMixer() {

  mixer2d[0][0] = .69;
  mixer2d[0][1] = 0;
  mixer2d[0][2] = 1;
  mixer2d[0][3] = 0.00;
  mixer2d[0][4] = .5;
  mixer2d[0][5] = .5;
  mixer2d[0][6] = .1;
  mixer2d[0][7] = 1;

  mixer2d[0][8] = 0;
  mixer2d[0][9] = 0.42;
  mixer2d[0][10] = 0;
  mixer2d[0][11] = 0.65;
  mixer2d[0][12] = 0;
  mixer2d[0][13] = 0.53;
  mixer2d[0][14] = 0;
  mixer2d[0][15] = 0;


  mixer2d[1][0] = .1;
  mixer2d[1][1] = 0;
  mixer2d[1][2] = 0;
  mixer2d[1][3] = 0.00;
  mixer2d[1][4] = 0.84;
  mixer2d[1][5] = 0.27;
  mixer2d[1][6] = 0;
  mixer2d[1][7] = .5;

  mixer2d[1][8] = 0.9;
  mixer2d[1][9] = 0.42;
  mixer2d[1][10] = 0;
  mixer2d[1][11] = 0.45;
  mixer2d[1][12] = 0;
  mixer2d[1][13] = 0.53;
  mixer2d[1][14] = 0;
  mixer2d[1][15] = 0.18;


  for (int i = 0; i<audioDependant.length; i++) {
    for (int j = 0; j<audioDependant[i].length; j++) {
      audioDependant[i][j] = false;
    }
  }
}

float constrain01(float value) {
  return constrain(value, 0.0, 1.0);
}

float setValueFromMixer(float min, float max, int midiMode, int midiIndex, boolean canBeAudioReactive, boolean constain) {
  if (canBeAudioReactive) {
    if (valueIsInActiveArea(midiMode, midiIndex)) {
      if (constain) {
        return lerp(.1, 10, constrain01(normalizedAudio));
      } else {
        return lerp(.1, 10, normalizedAudio);
      }
    }
  } 

  return lerp(.1, 10, mixer2d[midiMode][midiIndex]);
}

boolean valueIsInActiveArea(int mode, int index) {


  return audioDependant[mode][index];
  //return (mixer2d[0][7] >= index / 15.0 && mixer2d[0][7] < (index + 1) / 15.0);
}


String convertToBase(int num, int base) {
  String s = "";
  int n = num;

  while (n>0) {
    //print("n: " + n);
    int r = n%base;
    //print("  r: " + r);
    n = n/base;
    //print("  n_new: " + n);  
    s+=r;
    //println();
  }
  s = new String(reverse(s.toCharArray()));
  return s;
}


int convertToDec(int num, int base) {
  int  n = num;
  int c = 0;
  int r = 0;
  while (n>0) {
    //print("n: " + n);
    int l = floor(n%(floor(pow(10, c+1))));
    //print("  l: " + l);
    r += (l/pow(10, c))*pow(base, c);

    n -= l;
    c++;
    //println();
  }

  return r;
}











void mousePressed() {
  seed+=100;
  redraw();
}




void keyPressed() {
  if (key == 32) {
    //saveFrame("png/output_"+timestamp()+".png");
    savePDF = true;
  } 
  if (key=='s') {
    saveCollection = !saveCollection;
    timestampCollection = timestamp();
  }
  if (key=='c') {
    clear = true;
  }

  if (key=='r') {
    resetMixer();
  }
  redraw();
}



String timestamp() {
  return new java.text.SimpleDateFormat("yyyy_MM_dd_kkmmss").format(new java.util.Date ());
}


void remapMidiButton() {
  for (int i = 0; i<8; i++) {
    mixerRandom[i] = button[64+i];
  }
  for (int i = 8; i<16; i++) {
    mixerRandom[i] = button[32+i-8];
  }
}

// UPDATE AUDIO INPUTS
void updateAvgAudio() {
  fft.forward(in.mix); // update FFT anaylsis 
  for (int i = 0; i < fft.avgSize (); i++) { 
    avgAudio+= abs(fft.getAvg(i)*amp); // duplicate everything for stereo w/ right too!
  }     
  avgAudio /= fft.avgSize();

  // update easeAudio
  float targetX = avgAudio; // grabs latest avgAudio 
  float dx = targetX - easeAudio; // calculates difference to current easeAudio 
  easeAudio += dx * easing;

  // update maxAudio
  if (frameCount%120 == 0) {
    maxAudio = 10;
  } else if (avgAudio > maxAudio) {
    maxAudio = avgAudio;
  }
}

// poor mans faded BG
void backgroundFade(int alpha) { 
  pushMatrix();
  pushStyle();
  noStroke(); 
  fill(bg, alpha); // fill(color, alpha) 
  rectMode(CORNER);
  rect(0, 0, width, height); // background-like, but with alpha = poor mans fade!
  popStyle();
  popMatrix();
} 

class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioInput source;

  BeatListener(BeatDetect beat, AudioInput source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }

  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }

  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}


/**************************** 
 MINIBUS SETUP
 =============================
 *****************************/

import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;
MidiBus myBus; // The MidiBus
float[] mixer = new float[16]; //Array with Mixer
float[][] mixer2d = new float[5][16];
boolean[] button = new boolean[72]; //Arrray with Buttons
int midiMode = 0;

void midiInit() { //Put into setup() function
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 0, 0); // Create a new MidiBus object
  for (int i = 0; i<mixer.length; i++) {
    mixer[i] = .5;
  }
  for ( int i = 0; i<button.length; i++) {
    button[i]=false;
  }
}

void buttonPressed(int index) {
  println("buttonPressed: " + index + " state: " + button[index]);
  if (index >=40 && index<=45) {
    if (button[index]) {
      midiMode = index - 40;
    } else {
      midiMode = 0;
    }
    //DO SOMETHING
  }

  if (index >= 32 && index<=39) {
    if (button[index]) {
      audioDependant[midiMode][index-24] = !audioDependant[midiMode][index-24];
    }
  }
  if (index >= 64 && index<=71) {
    if (button[index]) {
      audioDependant[midiMode][index-64] = !audioDependant[midiMode][index-64];
    }
  }
}

float mixerLerp(int index, float min, float max) {
  return lerp(min, max, mixer[index]);
}

void midiMessage(MidiMessage message) { // You can also use midiMessage(MidiMessage message, long timestamp, String bus_name)

  if (getIndex(message) >= 0 && getIndex(message) < 8) {
    mixer[getIndex(message)] = map(getValue(message), 0, 127, 0, 1);
    mixer2d[midiMode][getIndex(message)] = map(getValue(message), 0, 127, 0, 1);

    println("button Index: " + getIndex(message) + "    value: " + mixer[getIndex(message)] +"   midiMode: " + midiMode);
    printArray(mixer2d[0]);
    printArray(mixer2d[1]);
  } else if (getIndex(message) >=16 && getIndex(message) < 25) {
    mixer[getIndex(message) - 8] = map(getValue(message), 0, 127, 0, 1);
    mixer2d[midiMode][getIndex(message) - 8] = map(getValue(message), 0, 127, 0, 1);
    println("button Index: " + getIndex(message) + "    value: " + mixer[getIndex(message) - 8]+"   midiMode: " + midiMode);
    printArray(mixer2d[0]);
    printArray(mixer2d[1]);
  } else {
    if (getValue(message) == 127) {
      button[getIndex(message)] = true;
    } else if (getValue(message) == 0) {
      button[getIndex(message)] = false;
    }
    buttonPressed(getIndex(message));
    println("button Index: " + getIndex(message));
  }
  redraw();
}

void delay(int time) {
  int current = millis(); 
  while (millis () < current+time) Thread.yield();
}

int getIndex(MidiMessage m_) {
  return (int)(m_.getMessage()[1]& 0xFF);
}
int getValue(MidiMessage m_) {
  return (int)(m_.getMessage()[2]& 0xFF);
}
