// Kinect Physics Example by Amnon Owed (15/09/12)
 
// import libraries
import processing.opengl.*; // opengl
import SimpleOpenNI.*; // kinect
import blobDetection.*; // blobs
import toxi.geom.*; // toxiclibs shapes and vectors
import toxi.processing.*; // toxiclibs display
import pbox2d.*; // shiffman's jbox2d helper library
import org.jbox2d.collision.shapes.*; // jbox2d
import org.jbox2d.common.*; // jbox2d
import org.jbox2d.dynamics.*; // jbox2d

// Not sure why this java lib needs to be imported, but the others don't
import java.util.Collections;
 
// declare SimpleOpenNI object
SimpleOpenNI context;
// declare BlobDetection object
BlobDetection theBlobDetection;
// ToxiclibsSupport for displaying polygons
ToxiclibsSupport gfx;
// declare custom PolygonBlob object (see class for more info)
PolygonBlob poly;
 
// PImage to hold incoming imagery and smaller one for blob detection
PImage cam, blobs;
// the kinect's dimensions to be used later on for calculations
int kinectWidth = 640;
int kinectHeight = 480;
// to center and rescale from 640x480 to higher custom resolutions
float reScale;
 
// background and blob color
color bgColor, blobColor;
// three color palettes (artifact from me storing many interesting color palettes as strings in an external data file ;-)
String[] palettes = {
  "-1117720,-13683658,-8410437,-9998215,-1849945,-5517090,-4250587,-14178341,-5804972,-3498634",
  "-67879,-9633503,-8858441,-144382,-4996094,-16604779,-588031",
  "-1978728,-724510,-15131349,-13932461,-4741770,-9232823,-3195858,-8989771,-2850983,-10314372"
};
color[] colorPalette;
 
// the main PBox2D object in which all the physics-based stuff is happening
PBox2D box2d;
// list to hold all the custom shapes (circles, polygons)
ArrayList<CustomShape> polygons = new ArrayList<CustomShape>();
 
void setup() {
  println("Running setup");
  // it's possible to customize this, for example 1920x1080
  size(1280, 720, OPENGL);
  context = new SimpleOpenNI(this);
  // initialize SimpleOpenNI object
  if (!context.enableScene()) {
    // if context.enableScene() returns false
    // then the Kinect is not working correctly
    // make sure the green light is blinking
    println("Kinect not connected!");
    exit();
  } else {
    // mirror the image to be more intuitive
    context.setMirror(true);
    // calculate the reScale value
    // currently it's rescaled to fill the complete width (cuts of top-bottom)
    // it's also possible to fill the complete height (leaves empty sides)
    reScale = (float) width / kinectWidth;
    // create a smaller blob image for speed and efficiency
    blobs = createImage(kinectWidth/3, kinectHeight/3, RGB);
    // initialize blob detection object to the blob image dimensions
    theBlobDetection = new BlobDetection(blobs.width, blobs.height);
    theBlobDetection.setThreshold(0.2);
    // initialize ToxiclibsSupport object
    gfx = new ToxiclibsSupport(this);
    // setup box2d, create world, set gravity
    box2d = new PBox2D(this);
    box2d.createWorld();
    box2d.setGravity(0, -20);
    // set random colors (background, blob)
    setRandomColors(1);
    println("Done setting up");
  }
}
 
void draw() {
  background(bgColor);
  // update the SimpleOpenNI object
  context.update();
  // put the image into a PImage
  cam = context.sceneImage().get();
  // copy the image into the smaller blob image
  blobs.copy(cam, 0, 0, cam.width, cam.height, 0, 0, blobs.width, blobs.height);
  // blur the blob image
  blobs.filter(BLUR, 1);
  // detect the blobs
  theBlobDetection.computeBlobs(blobs.pixels);
  // initialize a new polygon
  poly = new PolygonBlob();
  // create the polygon from the blobs (custom functionality, see class)
  poly.createPolygon();
  // create the box2d body from the polygon
  poly.createBody();
  // update and draw everything (see method)
  updateAndDrawBox2D();
  // destroy the person's body (important!)
  poly.destroyBody();
  // set the colors randomly every 240th frame
  setRandomColors(240);
}
 
void updateAndDrawBox2D() {
  // if frameRate is sufficient, add a polygon and a circle with a random radius
  if (polygons.size() < 128) {
    polygons.add(new CustomShape(kinectWidth/2, -50, -1));
    polygons.add(new CustomShape(kinectWidth/2, -50, random(2.5, 20)));
  }
  // take one step in the box2d physics world
  box2d.step();
 
  // center and reScale from Kinect to custom dimensions
  translate(0, (height-kinectHeight*reScale)/2);
  scale(reScale);
 
  // display the person's polygon  
  noStroke();
  fill(blobColor);
  gfx.polygon2D(poly);
 
  // display all the shapes (circles, polygons)
  // go backwards to allow removal of shapes
  for (int i=polygons.size()-1; i>=0; i--) {
    CustomShape cs = polygons.get(i);
    // if the shape is off-screen remove it (see class for more info)
    if (cs.done()) {
      polygons.remove(i);
    // otherwise update (keep shape outside person) and display (circle or polygon)
    } else {
      cs.update();
      cs.display();
    }
  }
}
 
// sets the colors every nth frame
void setRandomColors(int nthFrame) {
  if (frameCount % nthFrame == 0) {
    // turn a palette into a series of strings
    String[] paletteStrings = split(palettes[int(random(palettes.length))], ",");
    // turn strings into colors
    colorPalette = new color[paletteStrings.length];
    for (int i=0; i<paletteStrings.length; i++) {
      colorPalette[i] = int(paletteStrings[i]);
    }
    // set background color to first color from palette
    bgColor = colorPalette[0];
    // set blob color to second color from palette
    blobColor = colorPalette[1];
    // set all shape colors randomly
    for (CustomShape cs: polygons) { cs.col = getRandomColor(); }
  }
}
 
// returns a random color from the palette (excluding first aka background color)
color getRandomColor() {
  return colorPalette[int(random(1, colorPalette.length))];
}

/*******************************************************************************************/
/*                                       Custom Shape                                      */
/*******************************************************************************************/
// usually one would probably make a generic Shape class and subclass different types (circle, polygon), but that
// would mean at least 3 instead of 1 class, so for this tutorial it's a combi-class CustomShape for all types of shapes
// to save some space and keep the code as concise as possible I took a few shortcuts to prevent repeating the same code
class CustomShape {
  // to hold the box2d body
  Body body;
  // to hold the Toxiclibs polygon shape
  Polygon2D toxiPoly;
  // custom color for each shape
  color col;
  // radius (also used to distinguish between circles and polygons in this combi-class
  float r;
 
  CustomShape(float x, float y, float r) {
    this.r = r;
    // create a body (polygon or circle based on the r)
    makeBody(x, y);
    // get a random color
    col = getRandomColor();
  }
 
  void makeBody(float x, float y) {
    // define a dynamic body positioned at xy in box2d world coordinates,
    // create it and set the initial values for this box2d body's speed and angle
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
    body = box2d.createBody(bd);
    body.setLinearVelocity(new Vec2(random(-8, 8), random(2, 8)));
    body.setAngularVelocity(random(-5, 5));
    
    // depending on the r this combi-code creates either a box2d polygon or a circle
    if (r == -1) {
      // box2d polygon shape
      PolygonShape sd = new PolygonShape();
      // toxiclibs polygon creator (triangle, square, etc)
      toxiPoly = new Circle(random(5, 20)).toPolygon2D(int(random(3, 6)));
      // place the toxiclibs polygon's vertices into a vec2d array
      Vec2[] vertices = new Vec2[toxiPoly.getNumPoints()];
      for (int i=0; i<vertices.length; i++) {
        Vec2D v = toxiPoly.vertices.get(i);
        vertices[i] = box2d.vectorPixelsToWorld(new Vec2(v.x, v.y));
      }
      // put the vertices into the box2d shape
      sd.set(vertices, vertices.length);
      // create the fixture from the shape (deflect things based on the actual polygon shape)
      body.createFixture(sd, 1);
    } else {
      // box2d circle shape of radius r
      CircleShape cs = new CircleShape();
      cs.m_radius = box2d.scalarPixelsToWorld(r);
      // tweak the circle's fixture def a little bit
      FixtureDef fd = new FixtureDef();
      fd.shape = cs;
      fd.density = 1;
      fd.friction = 0.01;
      fd.restitution = 0.3;
      // create the fixture from the shape's fixture def (deflect things based on the actual circle shape)
      body.createFixture(fd);
    }
  }
 
  // method to loosely move shapes outside a person's polygon
  // (alternatively you could allow or remove shapes inside a person's polygon)
  void update() {
    // get the screen position from this shape (circle of polygon)
    Vec2 posScreen = box2d.getBodyPixelCoord(body);
    // turn it into a toxiclibs Vec2D
    Vec2D toxiScreen = new Vec2D(posScreen.x, posScreen.y);
    // check if this shape's position is inside the person's polygon
    boolean inBody = poly.containsPoint(toxiScreen);
    // if a shape is inside the person
    if (inBody) {
      // find the closest point on the polygon to the current position
      Vec2D closestPoint = toxiScreen;
      float closestDistance = 9999999;
      for (Vec2D v : poly.vertices) {
        float distance = v.distanceTo(toxiScreen);
        if (distance < closestDistance) {
          closestDistance = distance;
          closestPoint = v;
        }
      }
      // create a box2d position from the closest point on the polygon
      Vec2 contourPos = new Vec2(closestPoint.x, closestPoint.y);
      Vec2 posWorld = box2d.coordPixelsToWorld(contourPos);
      float angle = body.getAngle();
      // set the box2d body's position of this CustomShape to the new position (use the current angle)
      body.setTransform(posWorld, angle);
    }
  }
 
  // display the customShape
  void display() {
    // get the pixel coordinates of the body
    Vec2 pos = box2d.getBodyPixelCoord(body);
    pushMatrix();
    // translate to the position
    translate(pos.x, pos.y);
    noStroke();
    // use the shape's custom color
    fill(col);
    // depending on the r this combi-code displays either a polygon or a circle
    if (r == -1) {
      // rotate by the body's angle
      float a = body.getAngle();
      rotate(-a); // minus!
      gfx.polygon2D(toxiPoly);
    } else {
      ellipse(0, 0, r*2, r*2);
    }
    popMatrix();
  }
 
  // if the shape moves off-screen, destroy the box2d body (important!)
  // and return true (which will lead to the removal of this CustomShape object)
  boolean done() {
    Vec2 posScreen = box2d.getBodyPixelCoord(body);
    boolean offscreen = posScreen.y > height;
    if (offscreen) {
      box2d.destroyBody(body);
      return true;
    }
    return false;
  }
}

 
/*******************************************************************************************/
/*                                       Polygon Blob                                      */
/*******************************************************************************************/
// an extended polygon class quite similar to the earlier PolygonBlob class (but extending Toxiclibs' Polygon2D class instead)
// The main difference is that this one is able to create (and destroy) a box2d body from it's own shape
class PolygonBlob extends Polygon2D {
  // to hold the box2d body
  Body body;

  // the createPolygon() method is nearly identical to the one presented earlier
  // see the Kinect Flow Example for a more detailed description of this method (again, feel free to improve it)
  void createPolygon() {
    ArrayList<ArrayList<PVector>> contours = new ArrayList<ArrayList<PVector>>();
    int selectedContour = 0;
    int selectedPoint = 0;

    // create contours from blobs
    for (int n=0 ; n<theBlobDetection.getBlobNb(); n++) {
      Blob b = theBlobDetection.getBlob(n);
      if (b != null && b.getEdgeNb() > 100) {
        ArrayList<PVector> contour = new ArrayList<PVector>();
        for (int m=0; m<b.getEdgeNb(); m++) {
          EdgeVertex eA = b.getEdgeVertexA(m);
          EdgeVertex eB = b.getEdgeVertexB(m);
          if (eA != null && eB != null) {
            EdgeVertex fn = b.getEdgeVertexA((m+1) % b.getEdgeNb());
            EdgeVertex fp = b.getEdgeVertexA((max(0, m-1)));
            float dn = dist(eA.x*kinectWidth, eA.y*kinectHeight, fn.x*kinectWidth, fn.y*kinectHeight);
            float dp = dist(eA.x*kinectWidth, eA.y*kinectHeight, fp.x*kinectWidth, fp.y*kinectHeight);
            if (dn > 15 || dp > 15) {
              if (contour.size() > 0) {
                contour.add(new PVector(eB.x*kinectWidth, eB.y*kinectHeight));
                contours.add(contour);
                contour = new ArrayList<PVector>();
              } else {
                contour.add(new PVector(eA.x*kinectWidth, eA.y*kinectHeight));
              }
            } else {
              contour.add(new PVector(eA.x*kinectWidth, eA.y*kinectHeight));
            }
          }
        }
      }
    }
    
    while (contours.size() > 0) {
      
      // find next contour
      float distance = 999999999;
      if (getNumPoints() > 0) {
        Vec2D vecLastPoint = vertices.get(getNumPoints()-1);
        PVector lastPoint = new PVector(vecLastPoint.x, vecLastPoint.y);
        for (int i=0; i<contours.size(); i++) {
          ArrayList<PVector> c = contours.get(i);
          PVector fp = c.get(0);
          PVector lp = c.get(c.size()-1);
          if (fp.dist(lastPoint) < distance) { 
            distance = fp.dist(lastPoint); 
            selectedContour = i; 
            selectedPoint = 0;
          }
          if (lp.dist(lastPoint) < distance) { 
            distance = lp.dist(lastPoint); 
            selectedContour = i; 
            selectedPoint = 1;
          }
        }
      } else {
        PVector closestPoint = new PVector(width, height);
        for (int i=0; i<contours.size(); i++) {
          ArrayList<PVector> c = contours.get(i);
          PVector fp = c.get(0);
          PVector lp = c.get(c.size()-1);
          if (fp.y > kinectHeight-5 && fp.x < closestPoint.x) { 
            closestPoint = fp; 
            selectedContour = i; 
            selectedPoint = 0;
          }
          if (lp.y > kinectHeight-5 && lp.x < closestPoint.y) { 
            closestPoint = lp; 
            selectedContour = i; 
            selectedPoint = 1;
          }
        }
      }

      // add contour to polygon
      ArrayList<PVector> contour = contours.get(selectedContour);
      if (selectedPoint > 0) { Collections.reverse(contour); }
      for (PVector p : contour) {
        add(new Vec2D(p.x, p.y));
      }
      contours.remove(selectedContour);
    }
  }

  // creates a shape-deflecting physics chain in the box2d world from this polygon
  void createBody() {
    // for stability the body is always created (and later destroyed)
    BodyDef bd = new BodyDef();
    body = box2d.createBody(bd);
    // if there are more than 0 points (aka a person on screen)...
    if (getNumPoints() > 0) {
      // create a vec2d array of vertices in box2d world coordinates from this polygon
      Vec2[] verts = new Vec2[getNumPoints()];
      for (int i=0; i<getNumPoints(); i++) {
        Vec2D v = vertices.get(i);
        verts[i] = box2d.coordPixelsToWorld(v.x, v.y);
      }
      // create a chain from the array of vertices
      ChainShape chain = new ChainShape();
      chain.createChain(verts, verts.length);
      // create fixture in body from the chain (this makes it actually deflect other shapes)
      body.createFixture(chain, 1);
    }
  }

  // destroy the box2d body (important!)
  void destroyBody() {
    box2d.destroyBody(body);
  }
}
