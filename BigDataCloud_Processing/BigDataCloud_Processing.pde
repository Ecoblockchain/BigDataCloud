import processing.serial.*;
Serial myPort;
Serial myPrinter;

import processing.video.*;
Capture cam;
PImage backgroundImage;
float threshold = 80;
int w = 320;
int h = 180;
PImage img;
float diffTotal;
float diffCompare;

JSONObject json;
JSONArray jsonArray;

XML xml;
XML[] children;
String[] sentences;
String content;
String[] words;
String delimiters = " ,.?!;:[] ";
IntDict concordance;
String[] keys;
int seconds;

ArrayList<Sand> sands;
ArrayList<Rain>rains;
PVector circleLocation;
float circleRadius;

boolean getMotion;
boolean getText;
boolean prevMotion;
char stepperPosition;
char prevPosition;

float r;

int prevSentences;
String newSentences = "";

boolean startEffect = false;
int count;
int transNew = 0;

boolean cameraEnabled;

void setup() {
  size(displayWidth, displayHeight);
  colorMode(HSB, 360, 100, 100, 100);
  randomSeed(1);

  rains = new ArrayList<Rain>();

  String[] cameras = Capture.list();
  cam = new Capture(this, w, h, cameras[21]);
  //cam = new Capture(this, w, h);
  cam.start();
  backgroundImage = createImage(w, h, RGB);
  img = new PImage(w, h, RGB);

  getContentFromJSON();

  circleLocation = new PVector(width/2, height/2);
  circleRadius = height/2-25;

  getMotion = false;
  prevMotion = false;
  getText = false;
  stepperPosition = 'u';

  cameraEnabled = false;

  println("before serial");
  //----------------------------Serial Communication--------------------------------------------//
  //  println(Serial.list());
  String myPrinterPort = "/dev/tty.usbmodemfa1311";
  myPrinter = new Serial(this, myPrinterPort, 19200);
  String portName = "/dev/tty.usbmodemfa1321";
  myPort = new Serial(this, portName, 9600);
  //myPort.bufferUntil('\n');
  //----------------------------Serial Communication--------------------------------------------//
  println("after serial");

  sands = new ArrayList<Sand>();
  concordance = new IntDict();
  for (int i = 0; i < sentences.length; i++) {
    sentences[i] = trim(sentences[i]);
  }
  content = join(sentences, "\n");
  String allwords = join(sentences, " ");
  words = splitTokens(allwords, delimiters);
  for (int i = 0; i < words.length; i++) {
    String s = words[i].toLowerCase();
    concordance.increment(s);
  }
  concordance.sortValuesReverse();
  keys = concordance.keyArray();
  for (int i = 0; i < keys.length; i++) {
    float _x = (height/2-20)*cos(random(2*PI))+width/2;
    float _y = (height/2-20)*sin(random(2*PI))+height/2;
    sands.add(new Sand(keys[i], concordance.get(keys[i]), new PVector(_x, _y), color(map(_y, 0, height, 130, 180), map(_x, 0, width, 70, 100), 70)));
  }
  prevSentences = sentences.length;
  r = 200;
}

void captureEvent(Capture cam) {
  if (cameraEnabled == true) {
    cam.read();
  }
}

void draw() {
  background(0);
  noCursor();

  //----------------------------camera--------------------------//
  if (cameraEnabled == true) {
    for (int x = 0; x <cam.width; x++) {
      for (int y = 0; y < cam.height; y++) {

        int loc = x + y*cam.width; // Reversing x to mirror the image

        color fgColor = cam.pixels[loc];
        color bgColor = backgroundImage.pixels[loc];

        float r1 = red(fgColor);
        float g1 = green(fgColor);
        float b1 = blue(fgColor);
        float r2 = red(bgColor);
        float g2 = green(bgColor);
        float b2 = blue(bgColor);
        float diff = dist(r1, g1, b1, r2, g2, b2);

        if (diff > threshold) {
          diffTotal ++;
        }
      }
    }
    img.updatePixels();

    diffCompare = diffTotal;
    diffTotal = 0;
    if (diffCompare > 8000) {
      getMotion = true;
      //println("in "+diffCompare);
    } else {
      getMotion = false;
      //println("out "+diffCompare);
    }
  }
  //----------------------------camera--------------------------//
  count++;

  //google spreadsheets
  seconds = second();
  if (seconds%2 == 0) {
    thread("requestNewWord");
  }

  if (seconds%2 ==0) {
    float _x = (height/2-20)*cos(random(2*PI))+width/2;
    float _y = (height/2-20)*sin(random(2*PI))+height/2;
    rains.add(new Rain(new PVector(_x, _y), color(map(_y, 0, height, 130, 180), map(_x, 0, width, 70, 100), 70)));
  }
  for (int i = rains.size ()-1; i >=0; i--) {
    Rain s = rains.get(i);
    s.boundaries();
    s.update();
    s.display();
    if (getMotion == true) {
      s.lifespan = 0;
    } else {
      //s.lifespan = 255;
    }
    if (s.isDead()) {
      rains.remove(i);
    }
  }

  if (count > 80) {
    startEffect = false;
  }

  for (int i = sands.size ()-1; i >=0; i--) {
    Sand s = sands.get(i);
    s.boundaries();
    s.update();
    s.display();
  }

  if (newSentences != null) {
    textSize(148);
    textAlign(CENTER, CENTER);
    transNew = constrain(transNew + 2, 0, 255);
    fill(170, 100, 70, transNew);
    text(newSentences, width/2, height/2);
  }
  //---------------stepper----------------//
  if (getMotion == true && prevMotion == false) {
    stepperPosition = 'd';
    myPort.write('d');
    prevMotion = true;
  } else if (getMotion == false && prevMotion == true) {
    myPort.write('u');
    prevMotion = false;
  } else if (getMotion == false && prevMotion == false) {
    myPort.write("");
  } else if (getMotion == true && prevMotion == true) {
    myPort.write("");
  }
  //---------------stepper----------------//
}


//--------------------------Serial Communication----------------------------------------------//
// void sendToPrinter(String tempString) {
//   tempString += "~";
//   myPort.write(tempString);
// }
//--------------------------Serial Communication----------------------------------------------//

//--------------------------API---------------------------------------------------------------//

// void getContentFromXML() {
//   children = xml.getChildren("entry/content");
//   sentences = new String[children.length];
//   for (int i = 0; i<children.length; i++) {
//     sentences[i] = children[i].getContent();
//   }
// }

void getContentFromJSON() {
  json = loadJSONObject("http://128.122.6.141:3000/results.json");
  //json = loadJSONObject("data/results.json");
  jsonArray = json.getJSONArray("results");
  sentences = new String[jsonArray.size()];
  for (int i = 0; i < jsonArray.size (); i ++) {
    sentences[i] = jsonArray.getString(i);
  }
}

void requestNewWord() {
  getContentFromJSON();
  if (sentences.length != prevSentences) {
    newSentences = "";
    transNew = 0;
    content = join(sentences, "\n\n");
    myPrinter.write("<<<<<<<<Here's the story>>>>>>>>" + "\n\n"+ content + "\n\n" + "<<<<Enjoy your big data rain>>>>"+"\n\n\n\n");
    myPrinter.write(0x0A);
    getText = true;
    for (int i = sentences.length - 1; i >= prevSentences; i--) {
      newSentences += sentences[i] + "\n";
    }
    newSentences = trim(newSentences);
    String[] newWords = splitTokens(newSentences, delimiters);
    for (int i = 0; i < newWords.length; i++) {
      String s = newWords[i].toLowerCase();
      if (concordance.hasKey(s)) {
        concordance.increment(s);
        for (Sand sand : sands) {
          if (s.equals(sand.word)) {
            sand.setSize(concordance.get(s));
          }
        }
      } else {
        float _x = (height/2-20)*cos(random(2*PI))+width/2;
        float _y = (height/2-20)*sin(random(2*PI))+height/2;
        sands.add(new Sand(s, 1, new PVector(_x, _y), color(map(_y, 0, height, 130, 180), map(_x, 0, width, 70, 100), 70)));
        concordance.increment(s);
      }
    }
    prevSentences = sentences.length;
  }

  if (getText == true) {
    myPort.write('u');
    getText = false;
  }
}
//--------------------------API---------------------------------------------------------------//

void keyPressed() {
  if (key == '1') {
    getMotion = true;
  }
  if (key == '2') {
    getMotion = false;
  }
  if (key == '3') {
    getText = true;
  }
  if (key == '4') {
    getText = false;
  }
  if (key == 'c') {
    cameraEnabled = true;
  }
  if (key == 'o') {
    cameraEnabled = false;
  }
  if (key == 'd') {
    myPort.write('d');
  }
  if (key == 'u') {
    myPort.write('u');
  }
  if (key == 's') {
    myPort.write('s');
  }
  if (key == 'z') {
    myPort.write('z');
  }
  if (key == 'p') {
    myPort.write('p');
  }
}

void mousePressed() {
  backgroundImage.copy(cam, 0, 0, cam.width, cam.height, 0, 0, backgroundImage.width, backgroundImage.height);
  backgroundImage.updatePixels();
}
