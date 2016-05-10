import com.badlogic.gdx.math.*;
import com.badlogic.gdx.math.CatmullRomSpline;
import com.badlogic.gdx.math.Vector2;


import java.util.*;

//EDIT VARIABLES
//int FINALIMAGESIZE = 640 ;
int FINALIMAGESIZE = 618;
String directory = "pakistan";
String filename = "pakistan";
String termination = ".geojson";
double mapscale = 1 << 14;
//EDIT VARIABLES

double TILE_SIZE = 256;

double[] boundaries = new double[4];

List < PImage > images = new ArrayList < PImage > ();
List < Coordinate > coordinates = new ArrayList < Coordinate > ();
List < PVector > normals = new ArrayList < PVector > ();
int colors[];

double xScale;
double yScale;
int lastx;
int lasty;

int imagewidth = FINALIMAGESIZE;
int imageheight = FINALIMAGESIZE;

boolean imageTaken;

PImage current = createImage(3000, 1300, RGB);

Vector2[] curvePoints;
CatmullRomSpline < Vector2 > curve;
List < Coordinate > newcoordinates = new ArrayList < Coordinate > ();

void setup() {
  String file = directory + "/" + filename + termination;
  JSONObject json = loadJSONObject(file);

  JSONArray features = json.getJSONArray("features");
  JSONObject geometry = features.getJSONObject(0).getJSONObject("geometry");
  JSONArray coordinate_points = geometry.getJSONArray("coordinates").getJSONArray(0).getJSONArray(0);

  for (int i = 0; i < coordinate_points.size(); i++) {
    JSONArray test = coordinate_points.getJSONArray(i);
    String s = test.toString();

    String[] list = split(s, ',');
    String lonc = split(list[0], '[')[1];
    String latc = split(list[1], ']')[0];

    Double lat = Double.parseDouble(latc);
    Double lon = Double.parseDouble(lonc);

    Coordinate c = new Coordinate(lat, lon);
    c.toPixelCoordinates();
    coordinates.add(c);
  }

  findBoundaryCoordinates();
  findScaleAmount();

  for (int i = 0; i < coordinates.size(); i++) {
    coordinates.get(i).toContainerCoordinates();
  }


  //FIND INTERPOLATION
  int i = 0;
  println("there are now START " + coordinates.size());
  while (i < (coordinates.size() - 2)) {
    //for(int o = 0 ; o < 18 ; o++ ) {
    double tempx = coordinates.get(i).getX();
    double tempy = coordinates.get(i).getY();

    int z = i + 1;
    double tempx2 = coordinates.get(z).getX();
    double tempy2 = coordinates.get(z).getY();


    double distance = distance(tempx, tempy, tempx2, tempy2);
    //float distance = dist(tempx, tempy, tempx2, tempy2) ;
    if (distance >= (FINALIMAGESIZE - 100)) {
      double x = LinearInterpolate(tempx, tempx2, 0.5);
      double y = LinearInterpolate(tempy, tempy2, 0.5);

      Location middle = toCoordinates(x, y);
      //println("Middle for " + i + " is, lat: " + middle.lat + " lon: " + middle.lon) ;
      Coordinate c = new Coordinate(middle.lat, middle.lon);
      c.toPixelCoordinates();
      c.toContainerCoordinates();
      coordinates.add(z, c);
      //println("adding a new image at " + z) ;
      //println("Pixel cord for " + i + " is, lat: " + x + " lon: " + y) ;
      //println("Pixel cord test for " + i + " is, lat: " + c.getX() + " lon: " + c.getY()) ;
    } else {
      int third = i + 2;
      double thirdx = coordinates.get(third).getX();
      double thirdy = coordinates.get(third).getY();
      double thirddistance = distance(tempx, tempy, thirdx, thirdy);
      if (thirddistance < FINALIMAGESIZE - 240) {
        //println("removed") ;
        coordinates.remove(z);
      } else {
        i = i + 1;
      }
    }
  }

  println("Now there are " + coordinates.size());

  //STRING ONE
  StringBuilder interp = new StringBuilder();
  for (int h = 0; h < coordinates.size() - 2; h++) {
    interp.append("[");
    Location temp = toCoordinates(coordinates.get(h).getX(), coordinates.get(h).getY());
    Coordinate ctemp = new Coordinate(temp.lat, temp.lon);
    ctemp.toPixelCoordinates();
    ctemp.toContainerCoordinates();
    newcoordinates.add(ctemp);
    interp.append(temp.lon + "," + temp.lat);
    interp.append("], ");
  }

  println(interp);

  ///STRING TWO
  StringBuilder borders = new StringBuilder();
  borders.append("{\n");
  borders.append("\"elements\": [");

  //OJO storing lon, lat as geojson requires
  for (int b = 0; b < coordinates.size() - 2; b++) {
    double tempx = coordinates.get(b).getX();
    double tempy = coordinates.get(b).getY();
    Location coordinate = toCoordinates(tempx, tempy);

    String temp = "{ \"lat\":" + coordinate.lat + ", \"lon\":" + coordinate.lon + "},\n";
    borders.append(temp);
  }

  //Format for the last borders
  int last = coordinates.size() - 1;
  double tempx = coordinates.get(last).getX();
  double tempy = coordinates.get(last).getY();
  Location coordinate = toCoordinates(tempx, tempy);
  String temp = "{ \"lat\":" + coordinate.lat + ", \"lon\":" + coordinate.lon + "}\n";
  borders.append(temp);

  borders.append("]}");

  //System.out.println(borders) ;
  println("there are now " + coordinates.size());

  String output_name = "data/" + directory + "/" + filename + "_final" + termination;
  PrintWriter output = createWriter(output_name);
  output.println(borders);
  output.flush();
  output.close();
  exit();
}

double distance(double x1, double y1, double x2, double y2) {
  double distance = Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
  return distance;
}

double LinearInterpolate(double y1, double y2, double mu) {
  return (y1 * (1 - mu) + y2 * mu);
}

//double CosineInterpolate(
//   double y1,double y2,
//   double mu)
//{
//   double mu2;

//   mu2 = (1-cos(mu*PI))/2;
//   return(y1*(1-mu2)+y2*mu2);
//}