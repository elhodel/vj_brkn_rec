boolean debug = false;

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
float maxAudioDamping = 0.995; 
float easeAudio; 
float easing = 0.25; // easing amount
float normalizedAudio;
int beatSensitivity = 10;

import processing.pdf.*;
boolean savePDF = false;
boolean saveCollection = false;
color bg = #000000; //#edd400;
color bgMin = #000000;
color bgMax = #ffffff;


color strk =#ffffff;// #a33600;
color strkMin = #ffffff;
color strkMax = #ff0000;

float opacity = 255;

int numPoint = 4;
float angleStep;

float rad =400;
float maxOffset = 200;
float edgeRate;
float x, y, a;
float strkW;
float strkWMin = 0.1;
float strkWMax = 40;
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


//boolean[][] audioDependant = new boolean[5][16];
boolean[] mixerRandom = new boolean[16]; 

boolean clear;
String timestampCollection;
char[] dnaProteins = {'a', 't', 'c', 'g'};
void setup() {
  //size(1000, 1000);
  fullScreen();
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


  setMixerDefaults();
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

  //background(bg);
  //blendMode(DIFFERENCE);


  float minInfluence = setValueFromMixer(0, 1, 5, 6, false, false);
  float maxInfluence = setValueFromMixer(minInfluence, 4, 5, 7, false, false); 


  normalizedAudio = map(easeAudio, 0, maxAudio, minInfluence, maxInfluence);

  easing = setValueFromMixer(0, 1, 5, 0, false, false);//mixer2d[0][6];

  rad = setValueFromMixer(10, width/2, 0, 0, true, false);
  println(rad);
  numPoint = round(setValueFromMixer(3, 60, 0, 1, true, true)); //floor(lerp(3, 60, mixer2d[0][2]));

  maxOffset = setValueFromMixer(0, 1, 0, 2, true, false); //lerp(0, 1, mixer2d[0][1]);




  edgeRate = setValueFromMixer(0, 1, 0, 3, true, false);//mixer2d[0][3];

  float skewX;

  skewX = setValueFromMixer(0, 1, 0, 4, true, false);

  float skewY;
  skewY = setValueFromMixer(0, 1, 0, 5, true, false);


  //strkW = .1;

  //strkW = .1;
  rings = floor(setValueFromMixer(1, 10, 1, 0, true, true));//lerp(1, 10, mixer2d[0][8]));



  ringsSpacing = setValueFromMixer(1, width/8, 1, 1, true, false);//lerp(1, 200, mixer2d[0][9]);




  scaleNum = setValueFromMixer(1, 10, 1, 2, true, true);//lerp(1, 10, mixer2d[0][10]);


  scaleFactor= setValueFromMixer(.8, 1.2, 1, 3, true, false); //lerp(.8, 1.2, mixer2d[0][11]); 


  rotationOffsetNum = setValueFromMixer(1, 10, 1, 4, true, true);//lerp(1, 10, mixer2d[0][12]);



  rotationOffsetAngle = setValueFromMixer(0, HALF_PI/8, 1, 5, true, false); //lerp(0, HALF_PI/8, mixer2d[0][13]);


  float translationAngle;
  translationAngle  = setValueFromMixer(0, TWO_PI, 1, 6, true, false); //lerp(0, TWO_PI, mixer2d[0][14]);




  float translationMag;
  translationMag  = setValueFromMixer(0, width/4, 1, 7, true, false);// lerp(0, 100, mixer2d[0][15]);


  bgFade =  setValueFromMixer(0, 255, 2, 0, true, true); // lerp(0, 255, mixer2d[1][0]);


  rotationRate = setValueFromMixer(-0.4, 0.4, 2, 1, true, false);//lerp(0, 0.4, mixer2d[1][8]);




  int strobeFreq = round(setValueFromMixer(0, 30, 2, 2, true, false));//lerp(0, 127, mixer2d[1][10]);
  int strobeBlackFreq = round(setValueFromMixer(0, 127, 2, 3, true, false));


  strkW = setValueFromMixer(strkWMin, strkWMax, 2, 4, true, false);//lerp(.1, 10, mixer2d[1][15]);

  float strkWRandomness = setValueFromMixer(0, 1, 2, 5, true, true);




  seed = round(setValueFromMixer(10, 1000, 2, 7, true, false)); //floor(lerp(10, 10000, mixer2d[1][9]));



  colorMode(HSB, 360, 100, 100, 100);

  float bgMinH = setValueFromMixer(0, 360, 3, 0, true, true);
  float bgMinS = setValueFromMixer(0, 100, 3, 1, true, true);
  float bgMinB = setValueFromMixer(0, 100, 3, 2, true, true);

  float bgMaxH = setValueFromMixer(0, 360, 3, 3, true, true);
  float bgMaxS = setValueFromMixer(0, 100, 3, 4, true, true);
  float bgMaxB = setValueFromMixer(0, 100, 3, 5, true, true);

  bgMin = color(bgMinH, bgMinS, bgMinB);
  bgMax = color(bgMaxH, bgMaxS, bgMaxB);


  float strkMinH = setValueFromMixer(0, 360, 4, 0, true, true);
  float strkMinS = setValueFromMixer(0, 100, 4, 1, true, true);
  float strkMinB = setValueFromMixer(0, 100, 4, 2, true, true);

  float strkMaxH = setValueFromMixer(0, 360, 4, 3, true, true);
  float strkMaxS = setValueFromMixer(0, 100, 4, 4, true, true);
  float strkMaxB = setValueFromMixer(0, 100, 4, 5, true, true);



  strkMin = color(strkMinH, strkMinS, strkMinB);
  strkMax = color(strkMaxH, strkMaxS, strkMaxB);


  colorMode(RGB);
  bg = setValueFromMixerColor(bgMin, bgMax, 3, 7, true, true); //mixer2d[1][1]);

  strk = setValueFromMixerColor(strkMin, strkMax, 4, 7, true, true); //lerpColor(strkMin, strkMax, mixer2d[1][2]);





  if (strobeFreq > 0) {
    if (frameCount%strobeFreq == 0) {

      bg = lerpColor(bgMin, bgMax, 1-mixer2d[1][1]);
      strk = lerpColor(strkMin, strkMax, 1-mixer2d[1][2]);
    }
  }

  if (strobeBlackFreq > 0) {
    if (frameCount%strobeBlackFreq == 0) {

      strk = #000000;
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
  //if (savePDF) beginRecord(PDF, "pdf/" + timeStamp+"#####_" + outputName + ".pdf");
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
        float strkWInfluence = lerp(strkWMin, strkWMax, strkWRandomness);
        strokeWeight(max(strkW+random(-strkWInfluence, strkWInfluence), strkWMin));
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
    //endRecord();
  }

  if (saveCollection) {
    saveFrame("png/" +timestampCollection+"/" + timeStamp+"#####_"+outputName+".png");
    endRecord();
  }

  if (debug) {
    drawEQ();
  }
}

void setMixerDefaults() {

  //SHAPE
  //====================
  //radius
  mixer2dDefaults[0][0] = .69;
  //points
  mixer2dDefaults[0][1] = 1;
  //points offset
  mixer2dDefaults[0][2] = 0;
  //rougness (if point should be rounded (0) or sharp(1)
  mixer2dDefaults[0][3] = 0.00;
  //skew x
  mixer2dDefaults[0][4] = .5;
  //skew y
  mixer2dDefaults[0][5] = .5;
  //------------------------
  mixer2dDefaults[0][6] = 0;
  //------------------------
  mixer2dDefaults[0][7] = 0;


  //MULTIPLICATIONS
  //====================
  // num rings
  mixer2dDefaults[1][0] = 0;
  // rings offset
  mixer2dDefaults[1][1] = 0.42;
  //num scale
  mixer2dDefaults[1][2] = 0;
  //scale factor
  mixer2dDefaults[1][3] = 0.65;
  //num rotation
  mixer2dDefaults[1][4] = 0;
  //rotation angle
  mixer2dDefaults[1][5] = 0.53;
  //roation offset direction
  mixer2dDefaults[1][6] = 0;
  //rotation offset magnitude
  mixer2dDefaults[1][7] = 0;


  //EFFFECTS
  //======================
  //background alpha (0: tansparent, 1: opaque)
  mixer2dDefaults[2][0] = .1;
  //rotation speed
  mixer2dDefaults[2][1] = 0.51;
  //invert flicker frequency
  mixer2dDefaults[2][2] = 0;
  //black flicker frequency
  mixer2dDefaults[2][3] = 0;
  //stroke weight
  mixer2dDefaults[2][4] = 0.14;
  //stroke weight randomness 
  mixer2dDefaults[2][5] = 0;
  //------------------------
  mixer2dDefaults[2][6] = 0;
  //seed
  mixer2dDefaults[2][7] = 1;



  //BACKGROUND COLOR
  //====================

  //bg1 hue
  mixer2dDefaults[3][0] = 0;
  //bg1 saturation
  mixer2dDefaults[3][1] = 0;
  //bg1 brightness
  mixer2dDefaults[3][2] = 0;
  //bg2 hue
  mixer2dDefaults[3][3] = 0.00;
  //bg2 saturation
  mixer2dDefaults[3][4] = 0;
  //bg2 brightness
  mixer2dDefaults[3][5] = 1;
  //------------------------
  mixer2dDefaults[3][5] = 1;
  //fade background color between bg1 and bg2
  mixer2dDefaults[3][7] = 0;



  //STROKE COLOR
  //====================

  //strk1 hue
  mixer2dDefaults[4][0] = 0;
  //strk1 saturation
  mixer2dDefaults[4][1] = 0;
  //strk1 brightness
  mixer2dDefaults[4][2] = 1;
  //strk2 hue
  mixer2dDefaults[4][3] = 1;
  //strk2 saturation
  mixer2dDefaults[4][4] = 1;
  //strk2 brightness
  mixer2dDefaults[4][5] = 1;
  //------------------------
  mixer2dDefaults[4][6] = 0;
  //fade stroke color between strk1 and strk2
  mixer2dDefaults[4][7] = 0;


  //AUDIO
  //====================
  //audio easing
  mixer2dDefaults[5][0] = .1;
  //audio influence min (between 0 and 1)
  mixer2dDefaults[5][6] = 0;
  // audio influence max (between audio influece min and 4)
  mixer2dDefaults[5][7] = .25;


  for (int i = 0; i<mixer2dDefaults.length; i++) {
    for (int j = 8; j<mixer2dDefaults[i].length; j++) {
      mixer2dDefaults[i][j] = 0;
    }
  }
}

void resetMixer() {
  for (int i = 0; i<mixer2d.length; i++) {
    for (int j = 0; j<8; j++) {
      mixer2d[i][j] = mixer2dDefaults[i][j];
    }
  }
}


void randomizeMixer() {
  randomSeed(millis());
  for (int i = 0; i<mixer2d.length; i++) {
    for (int j = 0; j<8; j++) {
      mixer2d[i][j] = random(0.0, 1.0);
    }
  }

  mixer2d[0][1] = random(0, .3);
  mixer2d[1][0] = random(0, .3);
  mixer2d[1][2] = random(0, .3);
  mixer2d[1][4] = random(0, .3);


  /*for (int i = 0; i<audioDependant.length; i++) {
   for (int j = 0; j<audioDependant[i].length; j++) {
   audioDependant[i][j] = random(0,1)<0.5;
   }
   }*/
  randomSeed(seed);
}

void resetMixerCurrentSet() {
  for (int j = 0; j<8; j++) {
    mixer2d[midiMode][j] = mixer2dDefaults[midiMode][j];
  }
}





void randomizeMixerCurrentSet() {
  randomSeed(millis());
  for (int j = 0; j<8; j++) {
    mixer2d[midiMode][j] = random(0.0, 1.0);
  }


  if (midiMode==0) {
    mixer2d[0][1] = random(0, .3);
  } else if (midiMode == 1) {
    mixer2d[1][0] = random(0, .3);
    mixer2d[1][2] = random(0, .3);
    mixer2d[1][4] = random(0, .3);
  }
  randomSeed(seed);
}

void resetAudioDependant() {
  for (int i = 0; i<mixer2d.length; i++) {
    for (int j = 8; j<mixer2d[i].length; j++) {
      mixer2d[i][j] = 0;
    }
  }
}

void randomizeAudioDependant() {
  randomSeed(millis());

  for (int i = 0; i<mixer2d.length; i++) {
    for (int j = 8; j<mixer2d[i].length; j++) {
      mixer2d[i][j] = random(0, 1);
    }
  }

  mixer2d[0][9] = 0;
  mixer2d[1][8] = 0;
  mixer2d[1][10] = 0;
  mixer2d[1][12] = 0;



  randomSeed(seed);
}


void randomizeAudioDependantCurrentSet() {
  randomSeed(millis());
  for (int j = 8; j<mixer2d[midiMode].length; j++) {
    mixer2d[midiMode][j] = random(0, 1);
  }

  if (midiMode==0) {
    mixer2d[0][9] = 0;
  } else if (midiMode == 1) {
    mixer2d[1][8] = 0;
    mixer2d[1][10] = 0;
    mixer2d[1][12] = 0;
  }
  randomSeed(seed);
}

void resetAudioDependantCurrentSet() {
  for (int j = 8; j<mixer2d[midiMode].length; j++) {
    mixer2d[midiMode][j] = 0;
  }
}





void saveCurrentSettings() {
  for (int i =0; i<mixer.length; i++) {
    println("mixer[" + i +"]");
    printArray(mixer[i]);
  }
}




float constrain01(float value) {
  return constrain(value, 0.0, 1.0);
}

float setValueFromMixer(float min, float max, int midiMode, int midiIndex, boolean canBeAudioReactive, boolean constrain) {

  float t = mixer2d[midiMode][midiIndex];
  if (canBeAudioReactive) {
    float influence = mixer2d[midiMode][midiIndex+8];
    float tMin = t-influence;
    float tMax = t+influence;
    tMin = max(0, tMin);
    if (constrain) {
      tMax = min(1, tMax);
    }

    t = lerp(tMin, tMax, normalizedAudio);
  } 

  return lerp(min, max, t);
}


color setValueFromMixerColor(color min, color max, int midiMode, int midiIndex, boolean canBeAudioReactive, boolean constrain) {

  float t = mixer2d[midiMode][midiIndex];

  if (canBeAudioReactive) {
    float influence = mixer2d[midiMode][midiIndex+8];
    float tMin = t-influence;
    float tMax = t+influence;
    tMin = max(0, tMin);
    if (constrain) {
      tMax = min(1, tMax);
    }

    t = lerp(tMin, tMax, normalizedAudio);
  } 

  return lerpColor(min, max, t);
}

/*boolean valueIsInActiveArea(int mode, int index) {
  return audioDependant[mode][index];
  //return (mixer2d[0][7] >= index / 15.0 && mixer2d[0][7] < (index + 1) / 15.0);
}*/








void mousePressed() {
  seed+=100;
  redraw();
}




void keyPressed() {
  if (key == 32) {
    //saveFrame("png/output_"+timestamp()+".png");
    savePDF = true;
  } 
  if (keyCode == 38) { // up arrow 
    amp += 5; 
    ampWave = amp*10;
  } else if (keyCode == 40) { // down arrow 
    amp -= 5; 
    if (amp < 5) { 
      amp = 5;
    } 
    ampWave = amp*10;
  } 
  if (key=='s') {
    saveCollection = !saveCollection;
    timestampCollection = timestamp();
  }
  if (key=='m') {
    clear = true;
  }

  if (key=='r') {
    resetMixer();
  }
  if (key=='t') {
    resetAudioDependant();
  }
  if (key=='y') {
    randomizeMixer();
  }
  if (key=='x') {
    randomizeAudioDependant();
  }
  if (key=='d') {
    debug = !debug;
  }

  redraw();
}


void buttonPressed(int index) {
  println("buttonPressed: " + index + " state: " + button[index]);
  if (index >=40 && index<=45) {
    if (button[index]) {
      midiMode = index - 39;
    } else {
      midiMode = 0;
    }
  } 
  if (button[index]) {
    if (index >= 32 && index<=39) {
      //audioDependant[midiMode][index-24] = !audioDependant[midiMode][index-24];
    } else if (index >= 64 && index<=71) {
      //audioDependant[midiMode][index-64] = !audioDependant[midiMode][index-64];
    } else if (index == 46) {
      resetMixer();
    } else if (index == 48) {
      randomizeMixer();
    } else if (index == 49) {
      resetMixer();
    } else if (index == 50) {
      randomizeMixerCurrentSet();
    } else if (index == 51) {
      resetMixerCurrentSet();
    } else if (index == 52) {
      randomizeAudioDependant();
    } else if (index == 53) {
      resetAudioDependant();
    } else if (index == 54) {
      randomizeAudioDependantCurrentSet();
    } else if (index == 55) {
      resetAudioDependantCurrentSet();
    }
  }
}




























void drawEQ() {

  resetMatrix();
  strokeWeight(1);
  for (int i=0; i < fft.avgSize (); i++) {  
    float x = map(i, 0, fft.avgSize(), 0, width); 
    float w = width/fft.avgSize(); 
    float a = fft.getAvg(i)*amp; 

    noFill();
    stroke(a);
    rect(x, height, w, -a); // -a to make rectangle grow upwards!
  }

  fill(255);
  text("avgAudio", width-100, 40);
  rect(width, 50, -avgAudio, 50);
  text("easeAudio", width-100, 140);
  rect(width, 150, -easeAudio, 50);
  text("maxAudio", width-100, 240);
  rect(width, 250, -maxAudio, 50);
  noFill();
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
  /*if (frameCount%120 == 0) {
   maxAudio = 10;
   } else if (avgAudio > maxAudio) {
   maxAudio = avgAudio;
   }*/
  if (avgAudio > maxAudio) {
    maxAudio = avgAudio;
  } else {
    maxAudio *= maxAudioDamping;
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
 MIDIBUS SETUP
 =============================
 *****************************/

import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;
MidiBus myBus; // The MidiBus
float[] mixer = new float[16]; //Array with Mixer
float[][] mixer2d = new float[6][16];
float[][] mixer2dDefaults = new float[6][16];
boolean[] button = new boolean[72]; //Arrray with Buttons
int midiMode = 0;

void midiInit() { //Put into setup() function
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 1, 0); // Create a new MidiBus object,(this, Input Source, Output Source)
  for (int i = 0; i<mixer.length; i++) {
    mixer[i] = .5;
  }
  for ( int i = 0; i<button.length; i++) {
    button[i]=false;
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
    //printArray(mixer2d[0]);
    //printArray(mixer2d[1]);
  } else if (getIndex(message) >=16 && getIndex(message) < 25) {
    mixer[getIndex(message) - 8] = map(getValue(message), 0, 127, 0, 1);
    mixer2d[midiMode][getIndex(message) - 8] = map(getValue(message), 0, 127, 0, 1);
    //println("button Index: " + getIndex(message) + "    value: " + mixer[getIndex(message) - 8]+"   midiMode: " + midiMode);
    //printArray(mixer2d[0]);
    //printArray(mixer2d[1]);
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
