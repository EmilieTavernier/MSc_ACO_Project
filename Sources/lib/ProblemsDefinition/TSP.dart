import 'dart:math';

// This class defines the traveling salesman problem
class TSP {
  var cities = <Point>[]; // List of coordinates

  TSP({int nbCities = 5}){
    final Random rng = new Random();

    // The cities coordinates are defined randomly
    for(int i=0; i<nbCities; i++){
      cities.add( Point(rng.nextDouble(), rng.nextDouble()) );
    }
  }
}
