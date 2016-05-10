class Coordinate { 
  double x ;
  double y ;

  double imagex ;
  double imagey ;

  Coordinate (double lat, double lon) {  
    x = lat ;
    y = lon ;
  } 

  void toPixelCoordinates() { 
    double siny = Math.sin(x * Math.PI / 180);
    siny = Math.min(Math.max(siny, -0.9999), 0.9999);
    x = TILE_SIZE * (0.5 + y / 360) ;
    y = TILE_SIZE * (0.5 - Math.log((1 + siny) / (1 - siny)) / (4 * Math.PI));
    x = x * mapscale ;
    y = y * mapscale;   
    //System.out.println(x + " and " + y) ;
  } 

  void toContainerCoordinates() {
    /*
    int floor = (int) (x / TILE_SIZE) ;
     imagex = (int) (x - (floor * TILE_SIZE)) ;
     
     floor = (int) (y / TILE_SIZE) ;
     imagey = (int) (y - (floor * TILE_SIZE)) ;
     */

    imagex = x - xScale ;
    imagey = y - yScale ;
  }

  float getCenterX() {
    return (float) imagex + (imagewidth / 2) ;
  }

  float getCenterY() {
    return (float) imagey + (imageheight / 2) ;
  }

  double getX() {
    return imagex ;
  }

  double getY() {
    return imagey ;
  }

  double getPreciseCenterX() {
    return imagex + (imagewidth / 2) ;
  }

  double getPreciseCenterY() {
    return imagey + (imageheight / 2) ;
  }
} 



void findBoundaryCoordinates() {
  double smallestX = coordinates.get(0).x ;
  double largestX = coordinates.get(0).x ;
  double smallestY = coordinates.get(0).y ;
  double largestY = coordinates.get(0).y ;

  for (int i = 1; i < coordinates.size(); i++) {
    double x = coordinates.get(i).x ;
    double y = coordinates.get(i).y ;

    if (x < smallestX) {
      smallestX = x ;
    }

    if (x > largestX) {
      largestX = x ;
    }

    if (y < smallestY) {
      smallestY = y ;
    }

    if (y > largestX) {
      largestY = y ;
    }
  }

  boundaries[0] = smallestX;
  boundaries[1] = largestX ;
  boundaries[2] = smallestY ;
  boundaries[3] = largestY ;
}

void findScaleAmount() {
  double floor = boundaries[0] / TILE_SIZE ;
  xScale = floor * TILE_SIZE ;

  floor = boundaries[2] / TILE_SIZE ;
  yScale = floor * TILE_SIZE ;
}