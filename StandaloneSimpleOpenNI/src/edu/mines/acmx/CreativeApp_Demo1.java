package edu.mines.acmx;

import processing.core.PApplet;
import processing.core.PImage;
import SimpleOpenNI.SimpleOpenNI;

public class CreativeApp_Demo1 extends PApplet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	SimpleOpenNI context;

	PImage cam;
	int iters = 0;

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//PApplet.main(new String[] { "--present", "edu.mines.acmx.CreativeApp_Demo1" });
		PApplet.main("edu.mines.acmx.CreativeApp_Demo1");
	}

	public void setup() {
		// same as Kinect dimensions
		size(640, 480);
		background(0);
		// initialize SimpleOpenNI object
		context = new SimpleOpenNI(this);
		if (context.openFileRecording(System.getProperty("user.dir")+"/input.oni")) {
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
		}
	}

	public void draw() {
		// update the SimpleOpenNI object
		context.update();

		// display the image
		image(context.sceneImage(), 0, 0);
	}

}
