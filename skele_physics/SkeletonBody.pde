class SkeletonBody {
  ArrayList<SkeletonPoint> body_points = new ArrayList<SkeletonPoint>();
  
  SkeletonBody(int user_id){
    println("Made a new skeleton body for user: " + user_id);
    body_points.add(new SkeletonPoint(user_id, context.SKEL_HEAD));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_NECK));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_TORSO));
    //Left Arm
    body_points.add(new SkeletonPoint(user_id, context.SKEL_LEFT_SHOULDER));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_LEFT_ELBOW));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_LEFT_HAND));
    //Right Arm
    body_points.add(new SkeletonPoint(user_id, context.SKEL_RIGHT_SHOULDER));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_RIGHT_ELBOW));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_RIGHT_HAND));
    //Left Leg
    body_points.add(new SkeletonPoint(user_id, context.SKEL_LEFT_HIP));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_LEFT_KNEE));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_LEFT_FOOT));
    //Right Leg
    body_points.add(new SkeletonPoint(user_id, context.SKEL_RIGHT_HIP));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_RIGHT_KNEE));
    body_points.add(new SkeletonPoint(user_id, context.SKEL_RIGHT_FOOT));
  }
  
  public void update(){
    for (int i = 0; i < body_points.size(); i++){
      body_points.get(i).update();
    }
  }
}
