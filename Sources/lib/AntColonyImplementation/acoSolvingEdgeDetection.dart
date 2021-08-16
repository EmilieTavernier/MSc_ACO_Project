import 'dart:collection';
import 'dart:math';
import "../appStaticData.dart";

import '../ProblemsDefinition/EdgeDetection.dart';
import 'Ant.dart';


// This class implements ACO for edge detection
class EdgeDetectionACO {
  late int nbAnts;
  late int nbConstructionSteps;
  late int nbIterations;

  double pheromoneInitValue = 0;
  var alpha;
  var beta;
  late double evaporationRate;
  var pheromoneDecay;

  var ants = <Ant>[];

  // The constructor accepts user input parameters
  EdgeDetectionACO( int nbAnts, int nbIterations, int nbConstructionSteps,
                    double pheromoneInitValue,
                    var alpha, var beta,
                    double evaporationRate,
                    var pheromoneDecay ){
    if ( edgeDetection == null ) return;

    this.nbAnts = nbAnts;
    // We initialise the ants
    for(int i=0; i<nbAnts; i++) ants.add(new Ant());

    this.nbIterations = nbIterations;
    this.nbConstructionSteps = nbConstructionSteps;
    this.pheromoneInitValue = pheromoneInitValue;

    // We initialise all nodes (pixels) pheromone value
    for(int i=0; i<edgeDetection.pixels.length; i++){
      edgeDetection.pixels[i].pheromoneValue = pheromoneInitValue;
    }

    this.alpha = alpha;
    this.beta = beta;
    this.evaporationRate = evaporationRate;
    this.pheromoneDecay = pheromoneDecay;
  }

  // This function implements  ACS algorithm for edge detection
  performACS() async {
    if(nbAnts == 0 || ants.length == 0) return null;
    print("performEdgeDetectionACS()");
    AppState.updateDemoStatus();

    // Looping for nbIterations iterations
    for(int i=0; i<nbIterations; i++){

      // Looping on all ants
      for(int j=0; j<nbAnts; j++) {
        // If we are at first iteration...
        if(i == 0){
          // ... we initialized randomly each ant's departure city
          final Random rng = new Random();
          ants[j].currentNode = rng.nextInt(edgeDetection.pixels.length);
        }
        // (else) each ants start next iteration were it finished the previous one (= departure point)

        ants[j].solution = [ants[j].currentNode];
        ants[j].solutionLength = 0;
        ants[j].solutionHashSet = HashSet.of(ants[j].solution);
      }

      // Construct each ant's solution
      for(int step = 0; step < nbConstructionSteps; step++){
        // We update GUI execution info (iteration and step counter)
        AppState.updateExecutionInfo(
            info: 'Iteration ${i+1}/$nbIterations - Step ${step+1}/$nbConstructionSteps',
            additional: i == 0? 'At start, all pixels have same pheromone concentration' : AppState.additionalInfo
        );
        // For all ants, we choose next destination
        for(int j=0; j<nbAnts; j++) chooseNextDestination(j);
        updatePheromonesIntermediate();

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
          // If stop button was clicked (or if computation exceeded capacity, resulting in "infinity")
          if(AppState.abort){
            // print("ABORT");
            AppState.updateDemoStatus();
            AppState.animating = false;
            AppState.abort = false;
            return;
          }
          // If pause button was clicked
          if(!AppState.paused){
            // Check if animation duration (2s) is completed...
            // ... with a 50ms margin
            // ... and including eventual pause duration
            if(now > animationStartTime + 1 + AppState.pauseDuration) {
              AppState.animating = false; // Animation finished
            }
          }
          // Small delay before checking time again (to limit number of computations)
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
      // Compute new pheromone values
      updatePheromones();
      //print(pheromoneConcentrations);
      
      // Inform GUI to update pheromones display
      AppState.updatePheromones();
      AppState.updateExecutionInfo(additional: '');
    }
    AppState.updateDemoStatus();
  }

  // This function select the next destination for an ant
  chooseNextDestination(int antIndex){
    var potentialNextProbabilities = []; // List of pseudo probabilities of candidates to be chosen as next destination
    var sumProbabilities = 0.0;

    double heuristicInfo = 0;

    // COMPUTE "PROBABILITIES" FOR NEXT DESTINATION AMONG CURRENT NODE'S NEIGHBOURS
    List<Pixel> neighbours = edgeDetection.pixels[ants[antIndex].currentNode].neighbours;
    for(int i=0; i<neighbours.length; i++){

      // We compute the neighbour's probability to be chosen as next destination
      heuristicInfo = neighbours[i].intensityVariation / edgeDetection.maxIntensityVariation;
      double pheromoneValue = neighbours[i].pheromoneValue;

      var pseudoProbability = pow(pheromoneValue, alpha) * pow(heuristicInfo, beta);
      // Remark: not a true probability since it won't sum up to 1
      // but we are only interested in a proportion between cities

      // SECURITY: some value (especially tau) may be too big (infinite)
      if( pseudoProbability.isInfinite && !AppState.abort ){
        // Would not crash the program but the demonstration result would be meaningless
        // So instead we interrupt demonstration and show alert message
        AppState.overflow();
      }

      potentialNextProbabilities.add(pseudoProbability);
      sumProbabilities += pseudoProbability;
    }

    // CHOSE NEXT DESTINATION
    final Random rng = new Random();
    var nextDestinationSelector = rng.nextDouble() * sumProbabilities;
    int nextDestinationIdx = 0;
    var cumulativeSum = potentialNextProbabilities[nextDestinationIdx];
    while( nextDestinationIdx < neighbours.length &&
           cumulativeSum < nextDestinationSelector ) {
      nextDestinationIdx++;
      cumulativeSum += potentialNextProbabilities[nextDestinationIdx];
    }

    // SECURITY: if ALL unvisited cities have ZERO probability to be chosen...
    if(cumulativeSum == 0){
      // ... we chose next destination among unvisited cities randomly
      // (with equal probability)
      nextDestinationIdx = rng.nextInt(neighbours.length);
      // This SHOULD NOT happen as long as
      // pheromone initial value is not 0 AND evaporation rate is strictly inferior to 1
    }

    // Updating ant fields with new destination information
    ants[antIndex].previousNode = ants[antIndex].currentNode;
    ants[antIndex].currentNode = neighbours[nextDestinationIdx].index;
    ants[antIndex].solution.add(ants[antIndex].currentNode);

    // We update the sum of heuristic info which will be needed
    // to compute the heuristic info average (equivalent to solution length)
    // later in updatePheromone()
    ants[antIndex].solutionLength += heuristicInfo;
    ants[antIndex].solutionHashSet.add(ants[antIndex].currentNode);
  }

  // This function performs the local pheromone update
  updatePheromonesIntermediate(){
    // For all ants...
    for(int j=0; j<nbAnts; j++){
      // ... Compute new pheromone value for current pixel
      var oldPheromoneValue = edgeDetection.pixels[ants[j].currentNode].pheromoneValue;
      edgeDetection.pixels[ants[j].currentNode].pheromoneValue =
        (1 - pheromoneDecay) * oldPheromoneValue + pheromoneDecay * pheromoneInitValue;
    }
  }

  // This function performs the offline pheromone update
  updatePheromones(){
    // Compute ants' solution lengths
    for(int i=0; i<nbAnts; i++){
      // Compute kth solution's length equivalent
      // which is the average of the heuristic info
      // (the sum of heuristic info was computed previously in chooseNextDestination())
      ants[i].solutionLength = ants[i].solutionLength / ants[i].solution.length;
    }

    // For all nodes (pixels), compute pheromone evaporation
    for(int i=0; i<edgeDetection.pixels.length; i++) {
      var oldPheromone = edgeDetection.pixels[i].pheromoneValue;
      var newPheromone = (1 - evaporationRate) * oldPheromone;
      edgeDetection.pixels[i].pheromoneValue = newPheromone;
    }
    // Compute pheromone laid by all ants
    for (int i = 0; i < nbAnts; i++) {
      var depositPheromone = evaporationRate * ants[i].solutionLength;
      for (int j = 0; j < ants[i].solution.length; j++ ){
        edgeDetection.pixels[ ants[i].solution[j] ].pheromoneValue += depositPheromone;
      }
    }

    /* 
    // Old non optimise code
    for(int i=0; i<edgeDetection.pixels.length; i++) {
      var oldPheromone = edgeDetection.pixels[i].pheromoneValue;
      var depositPheromone = 0.0;
      for (int j = 0; j < nbAnts; j++) {
        if (ants[j].solutionHashSet.contains(i)) depositPheromone += ants[j].solutionLength;
      }
      var newPheromone = (1 - evaporationRate) * oldPheromone + evaporationRate * depositPheromone;

      edgeDetection.pixels[i].pheromoneValue = newPheromone;
    }
    */
  }

  // Print an ant solution (list of visited nodes' id)
  printAntsSolution(){
    for(int i=0; i<nbAnts; i++)
      print(ants[i].solution);
  }
}

