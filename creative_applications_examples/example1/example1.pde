// Kinect Basic Example by Amnon Owed (15/09/12)

// import library
import SimpleOpenNI.*;
// declare SimpleOpenNI object
SimpleOpenNI context;
 
// PImage to hold incoming imagery
PImage cam;
int iters = 0;
 
void setup() {
  // same as Kinect dimensions
  size(640, 480);
  // initialize SimpleOpenNI object
  context = new SimpleOpenNI(this);
  if (!context.enableScene()) {
    // if context.enableScene() returns false
    // then the Kinect is not working correctly
    // make sure the green light is blinking
    println("Kinect not connected!");
    exit();
  } else {
    // mirror the image to be more intuitive
    context.setMirror(true);
  }
}

void draw() {
  // update the SimpleOpenNI object
  context.update();
  // put the image into a PImage
  //cam = context.sceneImage().get();
  //System.gc();
  // display the image
  image(context.sceneImage(), 0, 0);
  if (iters > 50) {
   exit(); 
  }
  //iters++;
  println("Iteration: " + iters);
}
