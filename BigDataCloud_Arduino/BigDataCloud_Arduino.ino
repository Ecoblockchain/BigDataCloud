#include <Stepper.h>

#define GREENPIN 6
#define FADESPEED 15 


const int stepsPerRevolution = 200;  // change this to fit the number of steps per revolution
int height = 20;// for your motor

// initialize the stepper library on pins 8 through 11:
Stepper myStepper(stepsPerRevolution, 8,9,10,11);            

boolean stepperDown;
boolean stepperUp;

int stepCount = 0;
long myPos = 0;
long dest = 0;

void setup() {
  // set the speed at 60 rpm:
  myStepper.setSpeed(50); 
  // initialize the serial port:
  Serial.begin(9600);
  //Serial.println("0,0,0,0");

}

void loop() {
  if(Serial.available()>0){
    char input = Serial.read();
    if(input == 'd'){
      dest = height * stepsPerRevolution;
    }
    if(input == 'u'){
      dest = 0;
    }
    if(input == 's'){
      myPos = dest;
    }
    if(input == 'z'){
      myPos = 0;
    }
    if(input == 'p'){
      myPos = stepsPerRevolution;
      dest = 0;
    }
  }


  if(myPos == dest){
  }
  else if(myPos < dest){

    myStepper.step(1);
    myPos++;
  }
  else if(myPos > dest){
    myStepper.step(-1); 
    myPos--;
  }

  Serial.println(myPos);
}











