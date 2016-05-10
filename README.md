IACD Final Project :: Virtual Borders
====

Code base for a set of tools used to download satellite imagery, interpolate points along a border and texture map curvy images onto straight lines. 

Short description of each tool:

* 0.prune_geojson: this is a web app that loads a geojson file and helps the user trim down points of interest.
* 1.interpolate_geojson: this is a Processing application that interpolates points along the border to either add points where the data is sparse (i.e. two adjacent points are too far apart to fit into a map tile) or remove points where there is too much data (i.e. 2 or more points that all fit within the same map tile).
* 2.borders_tiles: not included in this repo. A script to download Google satellite map tiles or Mapbox satellite map tiles of a series of latitude and longitude coordinates. 
* 3.strip_creation: where all the magic happens. A Processing app that converts spherical coordinates into pixel coordinates, arranges a series of map tiles into one single image, creates 2 offset curves along a border, and finally texture maps the curvy border onto a long strip of pixels.

