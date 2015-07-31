class Sand {
  PVector location;
  PVector acceleration;
  PVector velocity;
  float lifespan;
  float mass;


  String word = "";
  float thesize = 0;
  color c;
  float maxspeed;
  float maxforce;
  int transText;
  int transParticle;
  boolean gotocenter = false;
  
  Sand(String s, float sz, PVector l, color c_) {
    word = s;
    setSize(sz);
    acceleration = new PVector(0, 0);
    acceleration = PVector.random2D();
    velocity = new PVector (0, 0);
    location = l.get();
    lifespan = 255.0;
    mass = random(5, 10);
    c = c_;

    maxspeed = 3;
    maxforce = 0.15;
  }

  void setSize(float sz) {
    thesize = sz*10;
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }


  void update() {
    //acceleration = PVector.random2D();
    velocity.add(acceleration);
    location.add(velocity);

    lifespan -= 0.5;
    acceleration.mult(0);
  }


  void display() {
    noStroke();
    // c = color(map(location.y, 0, height, 20, 220), map(location.x, 0, width, 70, 100), 70, lifespan);

    pushMatrix();
    translate(location.x, location.y);
    rotate(velocity.heading());
    //thesize = map(thesize, 0,3,20,40);
    textSize(2*thesize);
    //textSize(16);
    //ellipse(0,0, 16, 16);
    textAlign(CENTER, CENTER);
    if (getMotion == true) {
      transParticle = 0;
      fill(c, transText);
      transText = constrain(transText + int(0.1*(int)thesize), 0, 255);
      text(word, 0, 0);
    } else {
      transText = 0;
      transParticle = constrain(transParticle + int(0.1*(int)thesize), 0,255);
      fill(c, transParticle);
      rectMode(RADIUS);
      rect(0, 0, 10, 10);
    }
    popMatrix();
  }

  //------------------stayWithinCircle----------------------------------------------//
 /* void boundaries() {
    PVector desired = null;

    PVector predict = velocity.get();
    predict.mult(25);
    PVector futureLocation = PVector.add(location, predict);
    float distance = PVector.dist(futureLocation, circleLocation);

    if (distance > circleRadius || gotocenter) {
      gotocenter = true;
      PVector toCenter = PVector.sub(circleLocation, location);
      toCenter.normalize();
      toCenter.mult(velocity.mag());
      desired = PVector.add(velocity, toCenter);
      desired.normalize();
      desired.mult(maxspeed);
      
      if (distance < 50) {
        gotocenter = false; 
      }
    }

    if (desired != null) {
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      applyForce(steer);
    }
  }
  */
  //------------------stayWithinCircle----------------------------------------------//

  //-------------------stayWithinScreen-----------------------------------------------//
  void boundaries() {

    float d = 50;
    float w = 150;

    PVector force = new PVector(0, 0);

    if (location.x < w) {
      force.x = 1;
    } else if (location.x > width -w) {
      force.x = -1;
    } 

    if (location.y < d) {
      force.y = 1;
    } else if (location.y > height-d) {
      force.y = -1;
    } 

    force.normalize();
    force.mult(0.1);

    applyForce(force);
  }
  //-------------------stayWithinScreen-----------------------------------------------//

  boolean closed(Sand other) {
    float d = dist(location.x, location.y, other.location.x, other.location.y);
    if (d < r) {
      return true;
    } else {
      return false;
    }
  }
  // boolean isDead() {
  //   if (lifespan < 0.0) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }
}
