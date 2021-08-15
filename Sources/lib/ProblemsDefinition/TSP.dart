import 'dart:math';

class TSP {
  var cities = <Point>[];

  TSP({int nbCities = 5}){
    final Random rng = new Random();

    for(int i=0; i<nbCities; i++){
      cities.add( Point(rng.nextDouble(), rng.nextDouble()) );
    }
  }
}