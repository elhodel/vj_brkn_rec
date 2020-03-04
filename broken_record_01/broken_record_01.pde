import ddf.minim.*;   
import ddf.minim.analysis.*;  
Minim minim;   
FFT fft;  
AudioInput in;  
float amp = 15; // from testing, 15 seems to be good...
float ampWave; // used to strengthen signal   
float avgAudio; // store avg volume  
float maxAudio = 10; // store loudest volume
float easeAudio; 
float easing = 0.25; // easing amount



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
float rotationRate = 0;//radians(1);


float rotationOffsetNum = 6;
float rotationOffsetAngle = radians(1);

float scaleNum = 40;
float scaleFactor= 1.01;

PVector translation = new PVector(20, -10);
float gaussianFactor = .2;

int dnaMin = 0;
int dnaMax = 1023;

float[] value = new float[16];
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

  midiInit();
  seed =floor(random(100000));
  /*mixer[0] = .8;
   mixer[1] = .1;
   mixer[2] = .15;
   mixer[3] = 0;
   mixer[4] = .5;
   mixer[5] = .5;
   mixer[6] = 0;
   mixer[7] = .5;
   mixer[8] = 0;
   mixer[9] = .8;
   mixer[10] = 0;
   mixer[11] = 0;
   mixer[12] = 0;
   mixer[13] = 0;
   mixer[14] = 0;
   mixer[15] = 0;
   */
  /*
  mixer[0] = 0.25;
   mixer[1] = 0.02;
   mixer[2] = 0.21;
   mixer[3] = 0;
   mixer[4] = 0.51;
   mixer[5] = 0.66;
   mixer[6] = 0;
   mixer[7] = 0.28;
   mixer[8] = 0.40;
   mixer[9] = 0.53;
   mixer[10] = 0;
   mixer[11] = 0;
   mixer[12] = 0.24;
   mixer[13] = 0.53;
   mixer[14] = 0.00;
   mixer[15] = 0.18;
   */
  /*
  //2017_11_25_21444804516_1.00_0.50_0.20_0.00_0.69_0.23_0.00_0.83_0.00_
   //0.00_0.00_0.00_1.00_0.03_0.00_0.00
   mixer[0] = 1;
   mixer[1] = .5;
   mixer[2] = 0.2;
   mixer[3] = 0;
   mixer[4] = 0.69;
   mixer[5] = 0.23;
   mixer[6] = 0;
   mixer[7] = 0.83;
   mixer[8] = 0.0;
   mixer[9] = 0.0;
   mixer[10] = 0;
   mixer[11] = 0;
   mixer[12] = 1;
   mixer[13] = 0.03;
   mixer[14] = 0.00;
   mixer[15] = 0.0;
   */
  //type_3_länglich
  //2017_11_28_18153300761_12800_0.69_0.48_0.07_0.00_0.84_0.27_0.00_
  //1.00_0.19_0.42_1.00_0.45_0.00_0.53_0.00_0.18
  mixer[0] = .69;
  mixer[1] = .48;
  mixer[2] = 0.07;
  mixer[3] = 0.00;
  mixer[4] = 0.84;
  mixer[5] = 0.27;
  mixer[6] = 0;
  mixer[7] = 1;
  mixer[8] = 0.19;
  mixer[9] = 0.42;
  mixer[10] = 1;
  mixer[11] = 0.45;
  mixer[12] = 0;
  mixer[13] = 0.53;
  mixer[14] = 0;
  mixer[15] = 0.18;

  //type_2_gewickelt
  //2017_11_25_21445104531_1.00_0.50_0.20_0.00_0.69_0.23_0.00_
  //0.83_0.00_0.00_0.00_0.00_1.00_0.03_0.00_0.00
  /*
   mixer[0] = 1;
   mixer[1] = .5;
   mixer[2] = 0.2;
   mixer[3] = 0.00;
   mixer[4] = 0.69;
   mixer[5] = 0.23;
   mixer[6] = 0;
   mixer[7] = .83;
   mixer[8] = 0.0;
   mixer[9] = 0.0;
   mixer[10] = 0;
   mixer[11] = 0.;
   mixer[12] = 1;
   mixer[13] = 0.03;
   mixer[14] = 0;
   mixer[15] = 0;
   */

  //Type 3 rund
  //2017_11_27_23465003749_0.43_0.06_0.21_0.00_0.51_0.66_0.00_
  //0.40_0.13_0.26_0.24_0.60_0.06_0.29_0.16_0.08
  /* mixer[0] = .43;
   mixer[1] = .06;
   mixer[2] = 0.21;
   mixer[3] = 0.00;
   mixer[4] = 0.51;
   mixer[5] = 0.66;
   mixer[6] = 0;
   mixer[7] = .40;
   mixer[8] = 0.13;
   mixer[9] = 0.26;
   mixer[10] = .24;
   mixer[11] = 0.6;
   mixer[12] = .06;
   mixer[13] = 0.29;
   mixer[14] = 0.16;
   mixer[15] = 0.08;
   */



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

  for (int i = 0; i<mixer.length; i++) {
    if (mixerRandom[i]) {
      //value[i] = constrain(mixer[i]+randomGaussian()*gaussianFactor, 0, 1);
      value[i] = constrain(mixer[i]+random(-gaussianFactor, gaussianFactor), 0, 1);
    } else {
      value[i] = mixer[i];
    }
  }

  //printArray(button);

  float normalizedAudio = map(easeAudio, 0, maxAudio, 0, 1.5);

  easing = mixer[6];

  rad = lerp(10, width/2, value[0]) * normalizedAudio;
  //if (valueIsInActiveArea(0)) {
    rad = lerp(10, width/2, normalizedAudio);
  //}
  maxOffset = lerp(0, 1, value[1]);
  if (valueIsInActiveArea(1)) {
    maxOffset = lerp(0, 1, normalizedAudio);
  }
  numPoint = floor(lerp(3, 60, value[2]));
  if (valueIsInActiveArea(2)) {
    numPoint = floor(lerp(3, 60, normalizedAudio));
  }
  edgeRate = value[3];
  if (valueIsInActiveArea(3)) {
    edgeRate = normalizedAudio;
  }
  float skewX;

  skewX = value[4];
  if (valueIsInActiveArea(4)) {
    skewX = normalizedAudio;
  }
  float skewY;
  skewY = value[5];
  if (valueIsInActiveArea(5)) {
    skewY = normalizedAudio;
  }

  
  //strkW = .1;

  //strkW = .1;
  rings = floor(lerp(1, 10, value[8]));
  if (valueIsInActiveArea(6)) {
    rings = floor(lerp(1, 10, normalizedAudio));
  }


  ringsSpacing = lerp(1, 200, value[9]);
  if (valueIsInActiveArea(7)) {
    ringsSpacing = lerp(1, 200, normalizedAudio);
  }


  ringsStrkRandomMin = 1;
  ringsStrkRandomMax = 1;
  //ringsStrkRandomMin = lerp(.1, 10, value[10]);
  //ringsStrkRandomMax = lerp(ringsStrkRandomMin, 10, value[11]);
  //rotation = lerp(0,TWO_PI,value[6]);
  scaleNum = lerp(1, 10, value[10]);
  if (valueIsInActiveArea(8)) {
    scaleNum = lerp(1, 10, normalizedAudio);
  }

  scaleFactor= lerp(.8, 1.2, value[11]); 
  if (valueIsInActiveArea(9)) {
    scaleFactor= lerp(.8, 1.2, normalizedAudio);
  }


  rotationOffsetNum = lerp(1, 10, value[12]);
  if (valueIsInActiveArea(10)) {
    rotationOffsetNum = lerp(1, 10, normalizedAudio);
  }


  rotationOffsetAngle = lerp(0, HALF_PI/8, value[13]);
  if (valueIsInActiveArea(11)) {
    rotationOffsetAngle = lerp(0, HALF_PI/8, normalizedAudio);
  }

  float translationAngle;
  translationAngle  = lerp(0, TWO_PI, value[14]);
  if (valueIsInActiveArea(12)) {
    translationAngle  = lerp(0, TWO_PI, normalizedAudio);
  }
  
  strkW = lerp(.1, 10, value[14]);
  if (valueIsInActiveArea(13)) {
    strkW = lerp(.1, 10, normalizedAudio);
  }
  
  float translationMag;
  translationMag  = lerp(0, 100, value[15]);
  if (valueIsInActiveArea(14)) {
    translationMag  = lerp(0, 100, normalizedAudio);
  }


  float translationX = cos(translationAngle);
  float translationY = sin(translationAngle);

  translation.set(translationX, translationY);
  translation.setMag(translationMag);
  //rotationRate = lerp(0, .01, value[13]);
  rotation += rotationRate;
  //bgFade = lerp(0, 255, value[14]);


  if (!saveCollection) {
    //seed = floor(lerp(10, 10000, value[7]));
  } else {
    seed += floor(random(20, 180));
    rotation += 69*rotationRate;
  }
  points = new PVector[numPoint+3];

  angleStep = 360.0/(numPoint);



  String outputName = "" + convertToBase(seed, 4);
  String timeStamp = timestamp();

  for (int i = 0; i<value.length; i++) {
    int v = round(map(value[i], 0, 1, 0, 1023));
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



boolean valueIsInActiveArea(int index) {
  return (value[7] >= index / 15.0 && value[7] < (index + 1) / 15.0);
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
boolean[] button = new boolean[72]; //Arrray with Buttons


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
  if (index == 41) {
    //DO SOMETHING
  }
}

float mixerLerp(int index, float min, float max) {
  return lerp(min, max, mixer[index]);
}

void midiMessage(MidiMessage message) { // You can also use midiMessage(MidiMessage message, long timestamp, String bus_name)

  if (getIndex(message) >= 0 && getIndex(message) < 8) {
    mixer[getIndex(message)] = map(getValue(message), 0, 127, 0, 1);
    println("button Index: " + getIndex(message) + "    value: " + mixer[getIndex(message)]);
  } else if (getIndex(message) >=16 && getIndex(message) < 25) {
    mixer[getIndex(message) - 8] = map(getValue(message), 0, 127, 0, 1);
    println("button Index: " + getIndex(message) + "    value: " + mixer[getIndex(message) - 8]);
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
