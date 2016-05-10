import com.badlogic.gdx.math.*;
import com.badlogic.gdx.math.CatmullRomSpline;
import com.badlogic.gdx.math.Vector2;
import java.util.*;
import java.awt.geom.*;
import java.awt.Point;

//VARIALBES TO CHANGE
double mapscale = 1 << 14;
int startpic = 60 ; //+15
int endpic = 80 ; //20
int width = 6000 ;
int height = 6000 ;
int STRIP_WIDTH = 15000 ;
String TYPE = ".png" ;
//VARIABLES TO CHANGE

//double TILE_SIZE = 256;
//int IMAGESIZE = 618;
double TILE_SIZE = 512;
int IMAGESIZE = 1236 ;
int imagewidth = IMAGESIZE;
int imageheight = IMAGESIZE;
int THICKNESS = 600;

//FOR CURVY PARTS
int SCALING = 1 ;

double[] boundaries = new double[4];

List < PImage > images = new ArrayList < PImage > ();
List < Coordinate > coordinates = new ArrayList < Coordinate > ();
List < PVector > normals = new ArrayList < PVector > ();
int colors[];

double xScale;
double yScale;
int lastx;
int lasty;

boolean imageTaken;

boolean mouse;


PGraphics big;
PGraphics output;
PGraphics temp;

boolean once = true;

int OFFSET = 0;

Vector2[] curvePoints;
CatmullRomSpline < Vector2 > curve;
CatmullRomSpline < Vector2 > testcenter;
CatmullRomSpline < Vector2 > leftcurve;
CatmullRomSpline < Vector2 > rightcurve;


void setup() {
  size(100, 100, P3D);
  //surface.setResizable(true);

  big = createGraphics(width, height, P3D);
  temp = createGraphics(width, height, P3D);

  // we'll have a look in the data folder
  java.io.File folder = new java.io.File(dataPath(""));

  // list the files in the data folder
  String[] filenames_all = folder.list();
  String[] filenames = folder.list();

  if (filenames_all[0].equals(".DS_Store")) {
    filenames = Arrays.copyOfRange(filenames_all, 1, filenames_all.length) ;
  }

  // get and display the number of jpg files
  //println(filenames.length + " png files in specified directory");

  // display the filenames
  //for (int i = 0; i < filenames.length; i++) {
  for (int i = startpic; i < endpic; i++) {
    String[] parts = filenames[i].split("_");

    //PImage img = loadImage(filenames[i]);
    //img.copy(0, 0, img.width, img.height - 30, 0, 0, img.width, img.height);
    //images.add(img);

    double lat = Double.parseDouble(parts[1]);
    double lon = Double.parseDouble(parts[2]);
    //System.out.println(lat + " and " + lon) ;

    Coordinate c = new Coordinate(lat, lon);
    c.toPixelCoordinates();
    //c.toContainerCoordinates() ;

    coordinates.add(c);
  }

  findBoundaryCoordinates();
  println("found boundary coordinates") ;
  findScaleAmount();
  println("found scale amount") ;

  for (int i = 0; i < coordinates.size(); i++) {
    coordinates.get(i).toContainerCoordinates();
  }
  println("found container coordinates") ;

  curvePoints = new Vector2[coordinates.size()];

  for (int i = 0; i < coordinates.size(); i++) {
    double x = coordinates.get(i).getPreciseCenterX();
    double y = coordinates.get(i).getPreciseCenterY();
    //Point2D temp = new Point2D.Double(x,y) ;
    Vector2 temp = new Vector2((float) x, (float) y);
    curvePoints[i] = temp;
  }

  curve = new CatmullRomSpline < Vector2 > (curvePoints, false);
  println("created catmull rom curve") ;
  ////END CATMULL ROM


  //Drawing to graphics card
  big.beginDraw();
  big.background(0);
  big.scale(1);

  //Draw images
  for (int i = 0; i < coordinates.size(); i++) {
    int j = startpic + i ;
    PImage img = loadImage(filenames[j]); //Has to be one more because we're loading DSStore into filename
    big.image(img, (float) coordinates.get(i).getX(), ((float) coordinates.get(i).getY()), IMAGESIZE, (IMAGESIZE));

    //big.image(images.get(i), (float) coordinates.get(i).getX(), (float) coordinates.get(i).getY() + OFFSET, IMAGESIZE, IMAGESIZE);
  }

  //put text number in outputBig.tif
  for (int i = 0; i < coordinates.size(); i++) {
    float x = (float) coordinates.get(i).getPreciseCenterX();
    float y = (float) coordinates.get(i).getPreciseCenterY();
    textSize(22) ;
    int number = i + startpic ;
    big.text(number, x, y) ;
  }

  big.endDraw();

  //Saving an image without any marked points
  //Need thsi one to print out to strip
  big.save("outputBig" + TYPE);
  println("Drew first output") ;


  //Drawing to graphics card


  temp.beginDraw();
  temp.background(0);
  temp.scale(1);
  for (int i = 0; i < coordinates.size(); i++) {
    int j = startpic + i ;
    PImage img = loadImage(filenames[j]);
    temp.image(img, (float) coordinates.get(i).getX(), (float) coordinates.get(i).getY() + OFFSET, IMAGESIZE, IMAGESIZE);

    //temp.image(images.get(i), (float) coordinates.get(i).getX(), (float) coordinates.get(i).getY() + OFFSET, IMAGESIZE, IMAGESIZE);
  }

  temp.endDraw();
  println("Drew temp") ;
}

void draw() {
  ellipseMode(CENTER);

  background(255);

  scale(1);

  noFill();

  big.beginDraw();
  println("within draw") ;

  List < Vector2 > calculatedCurve = new ArrayList < Vector2 > ();
  List < Vector2 > leftcalculatedCurve = new ArrayList < Vector2 > ();
  List < Vector2 > rightcalculatedCurve = new ArrayList < Vector2 > ();

  for (int i = 0; i <= 100 / SCALING; i++) {
    Vector2 point = new Vector2();
    float points = (0.01 * SCALING) ;
    curve.valueAt(point, i * points);
    calculatedCurve.add(point);
  }

  big.stroke(255, 0, 0);
  big.fill(255, 0, 0);
  println("Curve size: " + calculatedCurve.size());

  List < Vector2 > perparray = new ArrayList < Vector2 > ();

  for (int i = 0; i < calculatedCurve.size(); i++) {
    int p0 = (i + calculatedCurve.size() - 1) % calculatedCurve.size();
    int p1 = i;
    int p2 = (i + 1) % calculatedCurve.size();

    Vector2 tangent = new Vector2(calculatedCurve.get(p2).x - calculatedCurve.get(p0).x, calculatedCurve.get(p2).y - calculatedCurve.get(p0).y);
    tangent.nor(); //normalize(); for PVector

    Vector2 perpendicular = new Vector2(-tangent.y, tangent.x);
    perparray.add(perpendicular);
  }
  println("calculating the perpendicular array") ;


  List < Vector2 > leftOffset = new ArrayList < Vector2 > ();
  List < Vector2 > rightOffset = new ArrayList < Vector2 > ();
  for (int i = 0; i < calculatedCurve.size(); i++) {
    Vector2 original = new Vector2(calculatedCurve.get(i).x, calculatedCurve.get(i).y);
    Vector2 perp = perparray.get(i);

    float offsetLeftX = original.x + perp.x * +THICKNESS;
    float offsetLeftY = original.y + perp.y * +THICKNESS;
    Vector2 left = new Vector2(offsetLeftX, offsetLeftY);
    leftOffset.add(left);
    //big.ellipse(offsetLeftX, offsetLeftY, 14,14) ;
    //big.line(original.x, original.y, offsetLeftX, offsetLeftY) ;

    float offsetRightX = original.x + perp.x * -THICKNESS;
    float offsetRightY = original.y + perp.y * -THICKNESS;
    Vector2 right = new Vector2(offsetRightX, offsetRightY);
    rightOffset.add(right);
  }

  leftOffset.remove(leftOffset.size() - 1);
  leftOffset.remove(0);
  rightOffset.remove(rightOffset.size() - 1);
  //rightOffset.remove(0); // ADDITIONAL TWEAK
  rightOffset.remove(0) ;

  calculatedCurve.remove(calculatedCurve.size() - 1);
  calculatedCurve.remove(0);
  //calculatedCurve.remove(0);

  //testcenter = interpolateCurve(calculatedCurve) ;

  testcenter = getPrunedOffsetCurve(calculatedCurve)  ;


  leftcurve = getPrunedOffsetCurve(leftOffset) ;    
  leftcalculatedCurve = interpolateCurve(leftcurve) ;

  rightcurve = getPrunedOffsetCurve(rightOffset) ;
  rightcalculatedCurve = interpolateCurve(rightcurve) ;
  println("Calculated offset curves") ;


  /*
    for (int i = 0; i < calculatedCurve.size() ; i++) {
   big.fill(0, 0, 255);
   big.ellipse(calculatedCurve.get(i).x, calculatedCurve.get(i).y, 10, 10);
   big.ellipse(leftcalculatedCurve.get(i).x, leftcalculatedCurve.get(i).y, 10, 10);
   big.ellipse(rightcalculatedCurve.get(i).x, rightcalculatedCurve.get(i).y, 10, 10);
   big.text(i, calculatedCurve.get(i).x, calculatedCurve.get(i).y);
   big.text(rightOffset.get(i).x + "," + rightOffset.get(i).y, rightOffset.get(i).x+10, rightOffset.get(i).y+10);
   
   //big.fill(0, 255, 0);
   //big.ellipse(leftOffset.get(i).x, leftOffset.get(i).y, 10, 10);
   //big.ellipse(rightOffset.get(i).x, rightOffset.get(i).y, 10, 10);
   
   /// big.fill(0, 255, 0);
   }
   */


  float total_dist = 0 ;

  for (int i = 0; i <= (100 / SCALING); i++) {
    //println((i*0.01f)*centerdist) ;

    float points = 0.01 * SCALING ;

    //RIGHT CUREV
    Vector2 cinter = new Vector2();
    testcenter.valueAt(cinter, i * points);

    //RIGHT CUREV
    Vector2 right = new Vector2();
    leftcurve.valueAt(right, i * points);

    //LEFTCURVE
    Vector2 left = new Vector2();
    rightcurve.valueAt(left, i * points);

    float distancetocenter = (i*points)* (testcenter.approxLength(10000)*1) ;

    //float l = (i*0.001f)* leftdist ;
    //float r = (i*0.001f)* rightdist ;
    big.ellipse(right.x, right.y, 10, 10);
    big.ellipse(left.x, left.y, 10, 10);
    big.ellipse(cinter.x, cinter.y, 10, 10);
    //textSize(12);
    //big.text(i, cinter.x+10, cinter.y+10);

    //DRAWING DISTANCES OF POINTS
    //RIGHT CUREV
    Vector2 r = new Vector2();
    rightcurve.valueAt(r, i * points);

    //LEFTCURVE
    Vector2 l = new Vector2();
    leftcurve.valueAt(l, i * points);

    float leftdist = leftcurve.approxLength(10000) ;
    float rightdist = rightcurve.approxLength(10000) ;
    float lefttext = leftdist * (i * points) ;
    float righttext = rightdist * (i * points) ;

    big.stroke(0, 255, 0);
    big.ellipse(r.x, r.y, 10, 10);
    //big.text(righttext, r.x+10, r.y+10) ;
    big.ellipse(l.x, l.y, 10, 10);
    //big.text(lefttext, l.x+10, l.y+10) ;
  }

  big.endDraw();
  big.save("output2" + TYPE);
  println("printing output2") ;

  total_dist = (leftcurve.approxLength(10000) + rightcurve.approxLength(10000)) / 2 ;


  drawStrip(calculatedCurve, leftOffset, rightOffset);
  println("finished printing strip") ;
  //drawStripScale(testcenter, leftcurve, rightcurve, total_dist); // was using center

  println("CENTER: " + testcenter.approxLength(10000)) ; // was using center
  println("LEFT: " + leftcurve.approxLength(10000)) ;
  println("RIGHT: " + rightcurve.approxLength(10000)) ;



  exit();
}


int stripCounter = 0;


void drawStrip(List < Vector2 > centerCurve, List < Vector2 > curveleft, List < Vector2 > curveright) {
  output = createGraphics(STRIP_WIDTH, (THICKNESS * 2), P3D);

  output.beginDraw();
  //output.stroke(255,0,0);
  output.textureMode(IMAGE);

  if (centerCurve.size() == 2) {
    output.beginShape(QUADS);
  } else {
    output.beginShape(TRIANGLE_STRIP);
  }

  output.noStroke();
  output.texture(temp);


  float top_coord = 0;
  float bottom_coord = 0;
  float[][][] multi = new float[centerCurve.size()][2][2];

  multi[0][0][0] = curveright.get(0).x;
  multi[0][0][1] = curveright.get(0).y;
  multi[0][1][0] = curveleft.get(0).x;
  multi[0][1][1] = curveleft.get(0).y;

  output.vertex(0, 0, curveright.get(0).x, curveright.get(0).y);
  output.vertex(0, (THICKNESS * 2), curveleft.get(0).x, curveleft.get(0).y);

  println("curve size: " + centerCurve.size());
  for (int i = 1; i < centerCurve.size(); i++) {
    Vector2 center = centerCurve.get(i);
    float leftx = curveleft.get(i).x;
    float lefty = curveleft.get(i).y;
    float rightx = curveright.get(i).x;
    float righty = curveright.get(i).y;

    float top_dist = dist(multi[i - 1][0][0], multi[i - 1][0][1], rightx, righty);
    float bottom_dist = dist(multi[i - 1][1][0], multi[i - 1][1][1], leftx, lefty);

    multi[i][0][0] = rightx;
    multi[i][0][1] = righty;
    multi[i][1][0] = leftx;
    multi[i][1][1] = lefty;

    float firsttop = (top_coord + top_dist);
    float secondtop = (bottom_coord + bottom_dist);

    //CASE OF 2 - special case
    if (centerCurve.size() == 2) {
      float dist = ((top_dist + bottom_dist) / 2);
      output.vertex(dist, 0, rightx, righty);
      output.vertex(dist, (THICKNESS * 2), leftx, lefty);
    } else { // ALL OTHER CASES
      output.vertex(firsttop, 0, rightx, righty);
      output.vertex(secondtop, (THICKNESS * 2), leftx, lefty);
    }

    top_coord = (top_coord + top_dist);
    bottom_coord = (bottom_coord + bottom_dist);
  }
  output.endShape();
  output.endDraw();
  output.save("strip" + stripCounter + TYPE);


  stripCounter = stripCounter + 1;
}


void drawStripScale(CatmullRomSpline < Vector2 > cCurve, CatmullRomSpline < Vector2 > cleft, CatmullRomSpline < Vector2 > cright, float total_dist) {
  output = createGraphics(10000, (THICKNESS * 2), P3D);

  output.beginDraw();
  //output.stroke(255,0,0);
  output.textureMode(IMAGE);
  output.beginShape(TRIANGLE_STRIP);

  output.noStroke();
  output.texture(temp);



  List < Vector2 > centerCurve =  interpolateCurve(cCurve) ;
  List < Vector2 > curveleft =  interpolateCurve(cleft) ;
  List < Vector2 > curveright =  interpolateCurve(cright) ;

  float centerdist = cCurve.approxLength(10000) ;
  float leftdist = cleft.approxLength(10000) ;
  float rightdist = cright.approxLength(10000) ;

  //float newdist = (leftdist + rightdist) / 2 ;
  float newdist = centerdist ;

  println("\n\nSTARTLIST") ;
  for (int i = 0; i <= 100 / SCALING; i++) {
    //println((i*0.01f)*centerdist) ;

    float points = 0.01 * SCALING ;

    //RIGHT CUREV
    Vector2 right = new Vector2();
    cright.valueAt(right, i * points);

    //LEFTCURVE
    Vector2 left = new Vector2();
    cleft.valueAt(left, i * points);

    float distancetocenter = (i*points)* newdist ;

    float leftdistance = (i*points)* leftdist ; 
    float rightdistance = (i*points)* rightdist ; 
    float centerdistance = (i*points)* centerdist ;

    //float l = (i*0.001f)* leftdist ;
    //float r = (i*0.001f)* rightdist ;
    output.vertex(centerdistance, 0, right.x, right.y);
    output.vertex(centerdistance, (THICKNESS * 2), left.x, left.y);
  }
  println("\n\nENDLIST") ;

  /*
    float top_coord = 0;
   float bottom_coord = 0;
   float[][][] multi = new float[centerCurve.size()][2][2];
   
   multi[0][0][0] = curveright.get(0).x;
   multi[0][0][1] = curveright.get(0).y;
   multi[0][1][0] = curveleft.get(0).x;
   multi[0][1][1] = curveleft.get(0).y;
   
   output.vertex(0, 0, curveright.get(0).x, curveright.get(0).y);
   output.vertex(0, (THICKNESS * 2), curveleft.get(0).x, curveleft.get(0).y);
   
   println("curve size: " + centerCurve.size());
   for (int i = 1; i < centerCurve.size(); i++) {
   Vector2 center = centerCurve.get(i);
   float leftx = curveleft.get(i).x;
   float lefty = curveleft.get(i).y;
   float rightx = curveright.get(i).x;
   float righty = curveright.get(i).y;
   
   float top_dist = dist(multi[i - 1][0][0], multi[i - 1][0][1], rightx, righty);
   float bottom_dist = dist(multi[i - 1][1][0], multi[i - 1][1][1], leftx, lefty);
   
   multi[i][0][0] = rightx;
   multi[i][0][1] = righty;
   multi[i][1][0] = leftx;
   multi[i][1][1] = lefty;
   
   float firsttop = (top_coord + top_dist);
   float secondtop = (bottom_coord + bottom_dist);
   
   //CASE OF 2 - special case
   if (centerCurve.size() == 2) {
   float dist = ((top_dist + bottom_dist) / 2);
   output.vertex(dist, 0, rightx, righty);
   output.vertex(dist, (THICKNESS * 2), leftx, lefty);
   
   } else { // ALL OTHER CASES
   output.vertex(firsttop, 0, rightx, righty);
   output.vertex(secondtop, (THICKNESS * 2), leftx, lefty);
   
   }
   
   top_coord = (top_coord + top_dist);
   bottom_coord = (bottom_coord + bottom_dist);
   
   
   }
   */
  output.endShape();
  output.endDraw();
  output.save("strip" + stripCounter + TYPE);


  stripCounter = stripCounter + 1;
}


//offsetPoints: unpruned list of offset points
CatmullRomSpline < Vector2 > getPrunedOffsetCurve(List < Vector2 > offsetPoints) {

  //PRUNING THE OFFSET CURVES
  List < Line > lines = new ArrayList < Line > ();

  Line initialline = new Line(offsetPoints.get(0).x, offsetPoints.get(0).y, offsetPoints.get(1).x, offsetPoints.get(1).y);
  lines.add(initialline);
  for (int i = 2; i < offsetPoints.size(); i++) {
    Vector2 prev = offsetPoints.get(i - 1);
    Vector2 temp = offsetPoints.get(i);
    //println("ON " + i);

    Line newline = new Line(prev.x, prev.y, temp.x, temp.y);
    //lines.add(newline) ;

    //println(lines) ; 

    int store = 0;
    int j;
    Line templine = new Line(0, 0, 0, 0);
    int size = lines.size();
    for (j = 0; j < size; j++) {
      templine = lines.get(j);
      int intersected = newline.intersect(templine);
      //print("checking points: " + newline.printline() + " WITH " + templine.printline());
      //println("\n") ;

      //If the two linest intersect
      if (intersected == 2) {
        //println("INTERSECTED");
        store = 1;

        for (int k = j; k < size; k++) {
          Line toremove = lines.get(j);
          //println("REMOVING " + toremove.printline());
          lines.remove(j); // remove j because array gets smaller as we remove lines
        }
        break;
      }
    }

    if (store == 1) {
      Line additionalline = new Line(templine.x1, templine.y1, temp.x, temp.y);
      //println("INTERSECTED SO ADDED: " + additionalline.printline());
      lines.add(additionalline);
    }
    if (store == 0) {
      lines.add(newline);
      //println("DID NOT INTERSECT SO ADDED: " + newline.printline());
    }

    for (int z = 0; z < lines.size(); z++) {
      //println("Position: " + z + ": " + lines.get(z).printline());
    }
  }

  Vector2[] prunedCurvePoints =  new Vector2[lines.size() + 1]; // number of points in final left offset curve

  for (int i = 0; i < lines.size(); i++) {
    float x = lines.get(i).x1;
    float y = lines.get(i).y1;

    Vector2 temp = new Vector2(x, y);
    prunedCurvePoints[i] = temp;
  }

  float x = lines.get(lines.size() - 1).x2; // final point
  float y = lines.get(lines.size() - 1).y2; // final point
  Vector2 finalPoint = new Vector2(x, y);
  prunedCurvePoints[lines.size()] = finalPoint ;


  CatmullRomSpline < Vector2 > offsetCurve = new CatmullRomSpline < Vector2 > (prunedCurvePoints, false);

  return offsetCurve ;
}

List < Vector2 > interpolateCurve(CatmullRomSpline < Vector2 > curve) {
  List < Vector2 > interpolatedCurve = new ArrayList < Vector2 > ();

  for (int i = 0; i <= 100 / SCALING; i++) {

    float points = 0.01 * SCALING ;
    Vector2 point = new Vector2();
    curve.valueAt(point, i * points);
    interpolatedCurve.add(point);
  }

  return interpolatedCurve ;
}