class Rain {
  PVector location;
  PVector acceleration;
  PVector velocity;
  float lifespan;
  float mass;

  float radius;
  float radiusPlus;
  float radiusConstrain;
  color c;
  float maxspeed;
  float maxforce;
  int transText;
  int transParticle;
  boolean gotocenter = false;

  Rain(PVector l, color c_) {

    acceleration = new PVector(0, 0);
    acceleration = PVector.random2D();
    acceleration.mult(0.5);
    velocity = new PVector (0, 0);
    location = l.get();
    lifespan = 255.0;
    mass = random(5, 10);
    c = c_;
    radiusPlus = random(3);
    radiusConstrain = random(30);
    maxspeed = 3;
    maxforce = 0.15;
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }


  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    lifespan -= 2;
    acceleration.mult(0);
    radius += radiusPlus;
    radius = constrain(radius, 0, radiusConstrain);
  }


  void display() {
    noStroke();
    pushMatrix();
    translate(location.x, location.y);
    rotate(velocity.heading());
    fill(c, lifespan);
    rectMode(RADIUS);
    rect(location.x, location.y, radius, radius);
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

  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
