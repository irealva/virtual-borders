Location toCoordinates(double pixelx, double pixely) {
  double x = pixelx ;
  double y = pixely ;

  x = x + xScale ;
  y = y + yScale ;

  x = x / mapscale ;
  y = y / mapscale ;

  double lon = x / TILE_SIZE * 360 - 180;
  double n = Math.PI - 2 * Math.PI * y / TILE_SIZE;
  double lat = (180 / Math.PI * Math.atan(0.5 * (Math.exp(n) - Math.exp(-n))));

  return new Location(lat, lon) ;
}

class Location {
  double lat ;
  double lon ;

  Location (double latinput, double loninput) {  
    lat = latinput ;
    lon = loninput ;
  }
}