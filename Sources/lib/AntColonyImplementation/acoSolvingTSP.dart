import 'dart:math';
import '../appStaticData.dart';

import '../AntColonyImplementation/Ant.dart';

// This class implements ACO algorithms (AS, MMAS, ACS) for TSP
class ACO {
  late int nbAnts;
  late int nbIterations;

  var pheromoneInitValue;
  var evaporationRate;
  var pheromoneConcentrations = [];
  var alpha;
  var beta;

  // AS related
  var Q;

  // MMAS related
  var maxPheromone;
  var minPheromone;

  // ACS related
  var pheromoneDecay;
  var q0;

  var distancesBetweenCities = [];
  var ants = <Ant>[];

  var globalShortestPath = [];
  var globalShortestLength;
  bool shortestHasChanged = false;

  // The constructor accepts user input parameters
  ACO( int nbAnts, int nbIterations,
       var pheromoneInitValue,
       var evaporationRate, var alpha, var beta, var Q,
       var maxPheromone, var minPheromone,
       var pheromoneDecay, var q0){
   if ( tsp == null ) return;

    this.nbAnts = nbAnts;
    // Initialise all ants
    for(int i=0; i<nbAnts; i++) ants.add(new Ant());

    this.nbIterations = nbIterations;
    // If the selected algorithm is MMAS...
    if( AppState.selectedAlgo == Algorithm.MMAS )
      // ... pheromone are initialised to the upper bound value
      this.pheromoneInitValue = maxPheromone;
    else 
      this.pheromoneInitValue = pheromoneInitValue;

    this.evaporationRate = evaporationRate;
    // Initialise all edges (paths between cities) pheromone concentrations and compute their length (distance between cities)
    for(int i=0; i<tsp.cities.length; i++){
      var nthCityEdgesPheromones = [];
      var distancesFromCityI = [];
      for(int j=i+1; j<tsp.cities.length; j++){
        nthCityEdgesPheromones.add(maxPheromone != null ? maxPheromone : 1); // TODO: change?
        distancesFromCityI.add( tsp.cities[i].distanceTo( tsp.cities[j] ));
      }
      pheromoneConcentrations.add(nthCityEdgesPheromones);
      distancesBetweenCities.add(distancesFromCityI);
    }

    this.alpha = alpha;
    this.beta = beta;
    this.Q = Q;
    this.maxPheromone = maxPheromone;
    this.minPheromone = minPheromone;
    this.pheromoneDecay = pheromoneDecay;
    this.q0 = q0;
  }

  // This functions performs AS, MMAS or ACS for TSP
  performAntSystem() async {
    if(nbAnts == 0 || ants.length == 0) return null;
    //print("performAntSystem()");
    
    // Update app state to "performingACO"
    AppState.updateDemoStatus();

    // Looping for nbMaxStep iteration
    for(int i=0; i<nbIterations; i++){
      shortestHasChanged = false;

      // Looping on all ants
      for(int j=0; j<nbAnts; j++) {
        // If we are at first iteration...
        if(i == 0){
          // ... we initialized randomly each ant's departure city
          final Random rng = new Random();
          ants[j].currentNode = rng.nextInt(tsp.cities.length);
        }
        // (else) each ants start next iteration were it finished the previous one (= departure point)

        ants[j].solution = [ants[j].currentNode];
      }
      // Construct each ant's solution
      while(ants[0].solution.length <= tsp.cities.length){
        AppState.updateExecutionInfo(
          info: 'Iteration ${i+1}/$nbIterations - Step ${ants[0].solution.length}/${tsp.cities.length}',
          additional: i == 0? 'At start, all edges have same pheromone concentration' : AppState.additionalInfo
        );

        // if each ant has already visited all cities...
        if(ants[0].solution.length == tsp.cities.length) {
          // ... they go back to where they started their tour
          for (int j = 0; j < nbAnts; j++) {
            ants[j].previousNode = ants[j].currentNode;
            ants[j].currentNode = ants[j].solution[0]; // tour's departure point
            ants[j].solution.add(ants[j].currentNode);
          }
        }
        // Else (if not all cities where yet visited)...
        else {
          // ... chose next destination among unvisited cities
          for(int j=0; j<nbAnts; j++) chooseNextDestination(j);
        }
        // If we are performing ACS ...
        if(AppState.selectedAlgo == Algorithm.ACS) {
          // ... we do the local pheromone update
          acsLocalUpdatePheromones();
          AppState.updatePheromones();
        }

        // After choosing next destination for each ants,
        // we inform GUI to animate their movement on screen
        AppState.pauseDuration = 0; // Reset pause duration
        AppState.animating = true;
        AppState.updateAnimation();

        // We save the animation starting time
        int animationStartTime = DateTime.now().millisecondsSinceEpoch;

        // And wait for the animation to finish
        while( AppState.animating ){
          int now = DateTime.now().millisecondsSinceEpoch;
          if(AppState.abort){
            print("ABORT");
            AppState.updateDemoStatus();
            AppState.animating = false;
            AppState.abort = false;
            return;
          }
          if(!AppState.paused){
            // Check if animation duration (2s) is completed...
            // ... with a 50ms margin
            // ... and including eventual pause duration
            if( now > animationStartTime +
                controller.duration!.inMilliseconds + 50 + AppState.pauseDuration ) {
              AppState.animating = false; // Animation finished
            }
          }

          // Small delay before checking time again (to limit number of computations)
          await Future.delayed(const Duration(milliseconds: 50));
        }
        // update controller duration in case it was changed during execution
        controller.duration = Duration(milliseconds: AppState.speedInMs);
      }
      updatePheromones();
      //print(pheromoneConcentrations);
      // Inform GUI to update pheromones display
      AppState.updatePheromones();
      var info = i > 0 ? AppState.additionalInfo : '';
      if(shortestHasChanged) {
        if(i > 0) info += '...\n';
        info += 'Iteration ${i + 1} update - shortest known solution (orange path) length: ${globalShortestLength.toStringAsFixed(2)}';
      }
      AppState.updateExecutionInfo(
        additional: info
      );
    }
    // Update app state to "not performingACO"
    AppState.updateDemoStatus();
  }

  // This function selects next city destination for an ant
  chooseNextDestination(int antIndex){
    var potentialNextCity = [];          // List of potential candidates for next destination
    var potentialNextProbabilities = []; // Pseudo probabilities of candidates to be chosen as next destination
    var sumProbabilities = 0.0;

    final Random rng = new Random();

    // ACS specific behaviour
    var randQ = rng.nextDouble();
    // remark:
    // ACS true range for randQ should be [0,1] but nextDouble range is [0, 1)
    // This is a minor imprecision we accept for simplicity sake.

    // If selected algorithm is ACS and random variable inferior or equal to q0 treshold...
    if(AppState.selectedAlgo == Algorithm.ACS && randQ <= q0)
      var argmax = -1.0;
      var maxIndex = 0;
      for(int potentialNext=0; potentialNext<tsp.cities.length; potentialNext++){
        // If the city has not been visited yet...
        if( !ants[antIndex].solution.contains(potentialNext) ){
          var smallerIndex = min(ants[antIndex].currentNode, potentialNext);
          var greaterIndex = max(ants[antIndex].currentNode, potentialNext);

          var arg = pheromoneConcentrations[smallerIndex][greaterIndex - smallerIndex - 1] *
                    pow(distancesBetweenCities[smallerIndex][greaterIndex  - smallerIndex - 1], beta); // TODO: check formula
          if(arg > argmax){
            argmax = arg;
            maxIndex = potentialNext;
          }
        }
      }

      // Updating ant fields with new destination information
      ants[antIndex].previousNode = ants[antIndex].currentNode;
      ants[antIndex].currentNode = maxIndex;
      ants[antIndex].solution.add(ants[antIndex].currentNode);

      return;
    }
    // End of ACS specific behaviour

    // COMPUTE "PROBABILITIES" FOR NEXT DESTINATION
    for(int potentialNext=0; potentialNext<tsp.cities.length; potentialNext++){
      // If the city has not been visited yet...
      if( !ants[antIndex].solution.contains(potentialNext) ){
        // ... we compute the city's probability to be chosen as next destination

        var smallerIndex = min(ants[antIndex].currentNode, potentialNext);
        var greaterIndex = max(ants[antIndex].currentNode, potentialNext);

        var tau = pheromoneConcentrations[smallerIndex][greaterIndex - smallerIndex - 1];
        var dist = distancesBetweenCities[smallerIndex][greaterIndex - smallerIndex - 1];

        var pseudoProbability = pow(tau, alpha) * pow(1/dist, beta);
        // Remark: not a true probability since it won't sum up to 1
        // but we are only interested in a proportion between cities

        //print('tau $tau, paw(tau,alpha) ${pow(tau, alpha)}');
        //print('beta ${1/dist}, paw(beta,alpha) ${pow(1/dist, beta)}');
        //print('pseudoProbability $pseudoProbability');

        // SECURITY: some value (especially tau) may be too big (infinite)
        if( pseudoProbability.isInfinite && !AppState.abort ){
          // Would not crash the program but the demonstration result would be meaningless
          // So instead we interrupt demonstration and show alert message
          AppState.overflow();
        }

        potentialNextCity.add(potentialNext);
        potentialNextProbabilities.add(pseudoProbability);
        sumProbabilities += pseudoProbability;
      }
      // else if (city already visited)...
      // ... {0 chance to be chosen as next destination}
    }

    // CHOSE NEXT DESTINATION
    var nextDestinationSelector = rng.nextDouble() * sumProbabilities;
    int nextDestinationIdx = 0;
    var cumulativeSum = potentialNextProbabilities[nextDestinationIdx];
    while( nextDestinationIdx < potentialNextCity.length &&
           cumulativeSum < nextDestinationSelector ) {
      nextDestinationIdx++;
      cumulativeSum += potentialNextProbabilities[nextDestinationIdx];
    }

    // SECURITY: if ALL unvisited cities have ZERO probability to be chosen...
    if(cumulativeSum == 0){
      // ... we chose next destination among unvisited cities randomly
      // (with equal probability)
      nextDestinationIdx = rng.nextInt(potentialNextCity.length);
      // This SHOULD NOT happen as long as
      // pheromone initial value is not 0 AND evaporation rate is strictly inferior to 1
    }

    // Updating ant fields with new destination information
    ants[antIndex].previousNode = ants[antIndex].currentNode;
    ants[antIndex].currentNode = potentialNextCity[nextDestinationIdx];
    ants[antIndex].solution.add(ants[antIndex].currentNode);
  }

  // This function performs local pheromone update (ACS specific)
  acsLocalUpdatePheromones(){
    var updatedPheromones = pheromoneConcentrations;
    for(int k=0; k<nbAnts; k++) {
      var currentNode = ants[k].solution[ ants[k].solution.length - 1 ];
      var previousNode = ants[k].solution[ ants[k].solution.length - 2 ];

      var smallerIndex = min(currentNode, previousNode);
      var greaterIndex = max(currentNode, previousNode);

      updatedPheromones[smallerIndex][greaterIndex - smallerIndex - 1] =
        (1-pheromoneDecay) * updatedPheromones[smallerIndex][greaterIndex - smallerIndex - 1] +
        pheromoneDecay * pheromoneInitValue;
    }
    pheromoneConcentrations = updatedPheromones;
  }

  // This method performs offline pheromone update (AS, MMAS and ACS)
  updatePheromones(){
    var updatedPheromones = pheromoneConcentrations;
    var iterationShortestPath = [];
    var iterationShortestLength;

    // Compute ants' solution lengths
    for(int k=0; k<nbAnts; k++){

      // Compute kth solution's length
      var solutionLength = 0.0;
      for(int city=0; city<ants[k].solution.length - 1; city++){
        int city1 = ants[k].solution[city];
        int city2 = ants[k].solution[city+1];

        var smallerIndex = min(city1, city2);
        var greaterIndex = max(city1, city2);

        solutionLength += distancesBetweenCities[smallerIndex][greaterIndex - smallerIndex - 1];
      }
      ants[k].solutionLength = solutionLength;
      // We take the opportunity to update shortest path length if needed
      if( iterationShortestLength == null || solutionLength < iterationShortestLength ) {
        iterationShortestLength = solutionLength;
        iterationShortestPath = ants[k].solution;
      }
      if( globalShortestLength == null || solutionLength < globalShortestLength ) {
        globalShortestLength = solutionLength;
        globalShortestPath = ants[k].solution;
        shortestHasChanged = true;
      }
    }
    
    // PHEROMONE UPDATE
    for(int i=0; i<pheromoneConcentrations.length; i++){
      for(int j=0; j<pheromoneConcentrations[i].length; j++){
        var tau = pheromoneConcentrations[i][j];
        updatedPheromones[i][j] = (1-evaporationRate) * tau;

        // AS pheromone update
        if( AppState.selectedAlgo == Algorithm.AS ) {
          // Add pheromones each time i-j (or j-i) edge is used in a solution.
          for (int k = 0; k < nbAnts; k++) {
            if (isEdgeIJInPath(ants[k].solution, i, j+i+1)) {
              updatedPheromones[i][j] += (Q / ants[k].solutionLength);
            }
          }
        }

        // MMAS pheromone update
        else if(AppState.selectedAlgo == Algorithm.MMAS){
          // Global best option
          if(AppState.selectedBest == BestAnt.globalBest){
            if (isEdgeIJInPath(globalShortestPath, i, j+i+1)) {
              updatedPheromones[i][j] += (1 / globalShortestLength);
            }
          }
          // Iteration best option
          if(AppState.selectedBest == BestAnt.iterationBest){
            if (isEdgeIJInPath(iterationShortestPath, i, j+i+1)) {
              updatedPheromones[i][j] += (1 / iterationShortestLength);
            }
          }
          if( updatedPheromones[i][j] > maxPheromone )
            updatedPheromones[i][j] = maxPheromone;
          else if ( updatedPheromones[i][j] < minPheromone )
            updatedPheromones[i][j] = minPheromone;
        }

        // ACS pheromone update
        else {
          // Global best option (selected by user)
          if(AppState.selectedBest == BestAnt.globalBest){
            if (isEdgeIJInPath(globalShortestPath, i, j+i+1)) {
              updatedPheromones[i][j] += (evaporationRate * 1 / globalShortestLength);
            }
          }
          // Iteration best option (selected by user)
          if(AppState.selectedBest == BestAnt.iterationBest){
            if (isEdgeIJInPath(iterationShortestPath, i, j+i+1)) {
              updatedPheromones[i][j] += (evaporationRate * 1 / iterationShortestLength);
            }
          }
        }
      }
    }
    pheromoneConcentrations = updatedPheromones;

    //printPheromoneConcentration();
  }

  // This function checks if edge i-j is in a solution (= path)
  bool isEdgeIJInPath(path, i, j){
    int city = 0;
    if(path.isNotEmpty) {
      while (path[city] != i) city++;
      // Checking if edge j-i is part of shortest path (OR condition closes the path loop)
      if ( (city > 0 && path[city - 1] == j) ||
           (city == 0 && path[path.length - 2] == j) ) {
        return true;
      }
      // Checking for edge i-j is part of shortest path
      else if (city < path.length - 1 && path[city + 1] == j) {
        return true;
      }
    }
    return false;
  }

  // This function prints an ant solution (list of nodes id) to the console
  printAntsSolution(){
    for(int i=0; i<nbAnts; i++)
      print(ants[i].solution);
  }

  // This function prints pheromone concentrations to the console
  printPheromoneConcentration(){
    for(int i=0; i<pheromoneConcentrations.length; i ++){
      String str = '';
      for(int j=0; j<pheromoneConcentrations[i].length; j++){
        var p = pheromoneConcentrations[i][j];
        str += '${p.toStringAsFixed(2)} - ';
      }
      print(str);
    }
    print("");
  }
}
