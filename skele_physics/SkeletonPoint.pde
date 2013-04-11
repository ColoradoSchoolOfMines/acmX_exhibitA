class SkeletonPoint {

  // Update period for the speed calculations (in milliseconds)
  private static final int UPDATE_PERIOD = 100;
  // Controls the csv output of data from this point
  private static final boolean write_to_file = true;

  private PVector initial_position = new PVector();
  private PVector current_position = new PVector();
  private PVector current_position_2D = new PVector();
  
  private float speed_x;
  private float speed_y;

  private int body_part;
  private int user_id;
  private long last_update_time;
  private short elapsed_time;
  private boolean due_for_update;

  PrintWriter output;

  SkeletonPoint() {
  }

  SkeletonPoint(int user_id, int body_part) {
    this.body_part = body_part;
    this.user_id = user_id;
    
    due_for_update = true;
    last_update_time = System.currentTimeMillis();

    println("Adding point to user " + user_id + ", body part: " + body_part);

    if (write_to_file) {
      setupFile();
    }
  }

  public void update() {
    if (System.currentTimeMillis() - last_update_time >= UPDATE_PERIOD) {
      elapsed_time = (short)(System.currentTimeMillis() - last_update_time);
      last_update_time = System.currentTimeMillis();
      due_for_update = true;
    }

    if (due_for_update) {
      due_for_update = false;
      draw();
    }
  }

  private void draw() {
    context.getJointPositionSkeleton(user_id, body_part, current_position);
    context.convertRealWorldToProjective(current_position, current_position_2D);
    fill(200);
    stroke(1);
    ellipse(current_position_2D.x, current_position_2D.y, 20, 20);

    speed_x = (current_position.x - initial_position.x)/elapsed_time;
    speed_y = (current_position.y - initial_position.y)/elapsed_time;
    
    if (write_to_file) {
        output.println(elapsed_time + "," + 
          current_position.x + "," + current_position.y + "," + 
          (current_position.x - initial_position.x) + 
          "," + (current_position.y - initial_position.y) +
          "," + speed_x + "," + speed_y);
    }

    initial_position.x = current_position.x;
    initial_position.y = current_position.y;
  }

  private void setupFile() {
    String filename = "data/positions/";
    switch (body_part) {
    case 1:
      filename += "head";
      break;
    case 2:
      filename += "neck";
      break;
    case 3:
      filename += "torso";
      break;
    case 6:
      filename += "left_shoulder";
      break;
    case 7:
      filename += "left_elbow";
      break;
    case 9:
      filename += "left_hand";
      break;
    case 12:
      filename += "right_shoulder";
      break;
    case 13:
      filename += "right_elbow";
      break;
    case 15:
      filename += "right_hand";
      break;
    case 17:
      filename += "left_hip";
      break;
    case 18:
      filename += "left_knee";
      break;
    case 20:
      filename += "left_foot";
      break;
    case 21:
      filename += "right_hip";
      break;
    case 22:
      filename += "right_knee";
      break;
    case 24:
      filename += "right_foot";
      break;
    }
    filename += "_positions.csv";

    output = createWriter(filename);
    println("Made output file: " + filename);
    
    output.println("delta_t,x,y,delta_x,delta_y,speed_x,speed_y");
  }
}

