import SimpleOpenNI.*;

SimpleOpenNI context;

PImage cam;
int iters = 0;
int user = 0;

//Change to arraylist to support multiple people
ArrayList<SkeletonBody> bodies;

boolean playback = false;

void setup(){
  
  frameRate(30);
 
  context = new SimpleOpenNI(this);
  context.setMirror(true);
  
  if (!context.enableDepth()){
    println("Depth not enabled");
  }
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  if (!context.enableScene()){
    println("Kinect not connected");
    exit();
  }
  
  smooth();
  
  size(640,480);
  
  bodies = new ArrayList<SkeletonBody>();
  //point = new SkeletonPoint(0,0);
}

void draw() {
  context.update();
  image(context.sceneImage(), 0, 0);

  for (int i = 0; i < bodies.size(); i++){
    bodies.get(i).update();
  }
}

//---------------------------------------------
// Override functions for the skeleton stuff.
//---------------------------------------------

void onNewUser(int userId) {
  println("detected: " + userId);
  user = userId;
  context.requestCalibrationSkeleton(userId, true);
}
void onLostUser(int userId) {
  println("lost: " + userId);
  user = 0;
  bodies.remove(userId - 1);
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

void onEndCalibration(int userId, boolean successful)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successful);

  if (successful) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
 
    bodies.add(new SkeletonBody(userId));
    
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.requestCalibrationSkeleton(userId, true);
  }
}

void onStartPose(String pose, int userId)
{
  println("onStartdPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}
