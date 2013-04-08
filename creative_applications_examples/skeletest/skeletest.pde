// Kinect Basic Example by Amnon Owed (15/09/12)

// import library
import SimpleOpenNI.*;
// declare SimpleOpenNI object
SimpleOpenNI context;

// PImage to hold incoming imagery
PImage cam;
int iters = 0;
int user = 0;
PVector pos = new PVector();
PVector pos2D = new PVector();

void setup() {
  // same as Kinect dimensions
  size(640, 480);
  // initialize SimpleOpenNI object
  context = new SimpleOpenNI(this);
  context.addLicense("PrimeSense", "0KOIk2JeIBYClPWVnMoRKn5cdY4=");
  if (false && context.openFileRecording("hometest_single.oni")) {
    println("Open File Recording was successful"); 
  } else {
    println("File opening was not successful"); 
  }
  if (!context.enableScene()) {
    // if context.enableScene() returns false
    // then the Kinect is not working correctly
    // make sure the green light is blinking
    println("Kinect not connected!");
    exit();
  } 
  else {
    // mirror the image to be more intuitive
    context.setMirror(true);
    if(!context.enableDepth()){
      println("failed to enable depth");
    }
    context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
    background(200,0,0);
    stroke(0,255,255);
    strokeWeight(3);
    smooth();
  }
}

void draw() {
  // update the SimpleOpenNI object
  context.update();
  // put the image into a PImage
  //cam = context.sceneImage().get();
  // display the image
  image(context.sceneImage(), 0, 0);
  if(user > 0){
    drawHead(user);
  }
}

void drawHead(int userId){
  context.getJointPositionSkeleton(user, context.SKEL_HEAD, pos);
  context.convertRealWorldToProjective(pos, pos2D);
  pos = pos2D;
  println(pos.x + " " + pos.y + " " + pos.z);
  //println(pos2D.x + " " + pos2D.y);
  ellipse(pos2D.x, pos2D.y, 30-pos.z*0.1, 30-pos.z*0.1);
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
 
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

void onNewUser(int userId){
  println("detected" + userId);
  user = userId;
  context.requestCalibrationSkeleton(userId,true);
}
void onLostUser(int userId){
  println("lost: " + userId);
  user = 0;
}
void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}
 
void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}
 
 
void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}
 
void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
 
  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.requestCalibrationSkeleton(userId,true);
  }
}
 
void onStartPose(String pose,int userId)
{
  println("onStartdPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
 
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
 
}
 
void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}
