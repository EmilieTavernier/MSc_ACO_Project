import 'dart:collection';
import 'dart:math';
import "../appStaticData.dart";

import '../ProblemsDefinition/JSP.dart';
import 'Ant.dart';

// This class implements ACO for job scheduling
class JobSchedulingACO {
  // User define parameters
  late int nbAnts;
  late int nbIterations;
  int nbConstructionSteps = 0;

  double pheromoneInitValue = 0;
  var alpha;
  var beta;
  late double evaporationRate;
  var pheromoneDecay;

  // Execution variable
  var ants = <Ant>[];

  List<List<List<Task>>> bestScheduleRecord = [];
  List<int> bestScheduleIterationRecord = [];

  List<List<Task>> globalBestSchedule = [];
  var globalShortestPath = [];
  var globalShortestLength;
  bool globalBestHasChanged = false;

  List<List<Task>> iterationBestSchedule = [];
  var iterationShortestPath = [];
  var iterationShortestLength;

  // The constructor accepts user input parameters
  JobSchedulingACO( int nbAnts, int nbIterations,
                    double pheromoneInitValue,
                    var alpha, var beta,
                    double evaporationRate,
                    var pheromoneDecay ){
    if ( jsp == null ) return;

    this.nbAnts = nbAnts;
    // Initialise all ants...
    for(int i=0; i<nbAnts; i++){
      ants.add(new Ant());
      // ...With empty schedules
      for(int j=0; j<=jsp.maxMachine; j++) ants[i].schedule.add([]);
    }
    // Initialise empty best schedule placeholders
    for(int i=0; i<=jsp.maxMachine; i++) {
      globalBestSchedule.add([]);
      iterationBestSchedule.add([]);
    }

    this.nbIterations = nbIterations;
    this.pheromoneInitValue = pheromoneInitValue;
    
    // For all job...
    for(int i=0; i<jsp.jobs.length; i++){
      // ..for all task...
      for(int j=0; j<jsp.jobs[i].tasks.length; j++){
        nbConstructionSteps++; 
        // ...for all successors...
        for(int k=0; k<jsp.jobs[i].tasks[j].successors.length; k++) {
           // ...Initialise pheromone concentration
          jsp.jobs[i].tasks[j].pheromonesConcentration.add(pheromoneInitValue);
        }
      }
    }
    // Number of construction steps = nb of nodes - 1
    nbConstructionSteps--;

    this.alpha = alpha;
    this.beta = beta;
    this.evaporationRate = evaporationRate;
    this.pheromoneDecay = pheromoneDecay;
  }

  // This function perform ACS for JSP
  performACS() async {
    if(nbAnts == 0 || ants.length == 0) return null;
    //print("performJobSchedulingACS()");
    AppState.updateDemoStatus();

    // Looping for nbIterations iterations
    for(int i=0; i<nbIterations; i++){
      globalBestHasChanged = false;

      // Looping on all ants to reinitialise the fields at the beginning of each iteration
      for(int j=0; j<nbAnts; j++) {
        ants[j].currentNode = 0;
        ants[j].solutionLength = 0;
        ants[j].solution = [];
        ants[j].solution.add(ants[j].currentNode);
        ants[j].schedule = [];
        for(int k=0; k<=jsp.maxMachine; k++) ants[j].schedule.add([]);
      }

      // Construct each ant's solution
      for(int step = 0; step < nbConstructionSteps; step++){
        // Update GUI informations
        AppState.updateExecutionInfo(
            info: 'Iteration ${i+1}/$nbIterations - Step ${step+1}/$nbConstructionSteps',
            additional: i == 0? 'At start, all edges have same pheromone concentration' : AppState.additionalInfo
        );
        // For all ants, choose next destination
        for(int j=0; j<nbAnts; j++) chooseNextDestination(j);
        // And perform local update
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
          await Future.delayed(const Duration(milliseconds: 1));
        }
        // update controller duration in case it was changed during execution
        controller.duration = Duration(milliseconds: AppState.speedInMs);
      }
      updatePheromones();
      //print(pheromoneConcentrations);
      // Inform GUI to update pheromones display
      AppState.updatePheromones();
      var info = i > 0 ? AppState.additionalInfo : '';

      // If we found a new best solution...
      if(globalBestHasChanged) {
        // Store it
        bestScheduleRecord.add(globalBestSchedule);
        bestScheduleIterationRecord.add(i);
        // And display a GUI update notice
        if(i > 0) info += '...\n';
        info += 'Iteration ${i + 1} update - shortest known solution (orange path) duration: ${globalShortestLength.toStringAsFixed(2)}';
      }
      AppState.updateExecutionInfo(
          additional: info
      );
    }
    // Tell app state ACS is not performing anymore
    AppState.updateDemoStatus();
  }

  // This functions selects next destination for an ant
  chooseNextDestination(int antIndex){
    var potentialNextProbabilities = []; // Pseudo probabilities of candidates to be chosen as next destination
    var sumProbabilities = 0.0;

    int heuristicInfo = 0;

    // COMPUTE "PROBABILITIES" FOR NEXT DESTINATION AMONG CURRENT NODE'S NEIGHBOURS
    int currentTask = ants[antIndex].currentNode % 100;
    int currentJob = ((ants[antIndex].currentNode - currentTask) / 100).floor();
    Task currentNode = jsp.jobs[currentJob].tasks[currentTask];

    List<Task> successors = jsp.jobs[currentJob].tasks[currentTask].successors;
    List<double> pheromones = jsp.jobs[currentJob].tasks[currentTask].pheromonesConcentration;

    // For all potential successors
    for(int i=0; i<successors.length; i++){
      // We compute the successor's probability to be chosen as next destination
      var pseudoProbability;

      // If a successor was already visited or if it's same job predecessors weren't visited yet...
      if( ants[antIndex].solution.contains(successors[i].id) ||
          (successors[i].id % 100 > 0 && !ants[antIndex].solution.contains(successors[i].id-1)) ){
        // ... it can't be chosen as next destination
        pseudoProbability = 0;
      }
      else {
        // If current node and successors needs to be executed on the same machine,
        // there is a delay before being able to run the successor (= current node duration)
        var delay = currentNode.machine == successors[i].machine ?
                    currentNode.duration : 0;
        heuristicInfo = successors[i].duration + delay;
        double pheromoneValue = pheromones[i];

        pseudoProbability = pow(pheromoneValue, alpha) *
            pow(1 / heuristicInfo, beta);
        // Remark: not a true probability since it won't sum up to 1
        // but we are only interested in a proportion between cities

        // SECURITY: some value (especially tau) may be too big (infinite)
        if (pseudoProbability.isInfinite && !AppState.abort) {
          // Would not crash the program but the demonstration result would be meaningless
          // So instead we interrupt demonstration and show alert message
          AppState.overflow();
        }
      }
      potentialNextProbabilities.add(pseudoProbability);
      sumProbabilities += pseudoProbability;
    }

    // CHOSE NEXT DESTINATION
    final Random rng = new Random();
    var nextDestinationSelector = rng.nextDouble() * sumProbabilities;
    int nextDestinationIdx = 0;
    var cumulativeSum = potentialNextProbabilities[nextDestinationIdx];
    while( nextDestinationIdx < successors.length &&
           cumulativeSum < nextDestinationSelector ) {
      nextDestinationIdx++;
      cumulativeSum += potentialNextProbabilities[nextDestinationIdx];
    }

    // SECURITY: if ALL unvisited cities have ZERO probability to be chosen...
    if(cumulativeSum == 0){
      // ... we chose next destination among unvisited cities randomly
      // (with equal probability)
      nextDestinationIdx = rng.nextInt(successors.length);
      // This SHOULD NOT happen as long as
      // pheromone initial value is not 0 AND evaporation rate is strictly inferior to 1
    }

    // Updating ant fields with new destination information
    ants[antIndex].previousNode = ants[antIndex].currentNode;
    ants[antIndex].currentNode = successors[nextDestinationIdx].id;
    ants[antIndex].solution.add(ants[antIndex].currentNode);

    updateSchedule(ants[antIndex]);
  }

  // This function performs pheromone local updates
  updatePheromonesIntermediate(){
    // For all ants...
    for(int i=0; i<nbAnts; i++){
      // Translate node id to array indexes
      int prevTask = ants[i].previousNode % 100;
      int prevJob = ((ants[i].previousNode - prevTask) / 100).floor();

      // And find which successors it correspond to
      int j = 0;
      var successors = jsp.jobs[prevJob].tasks[prevTask].successors;
      while (ants[i].currentNode != successors[j].id) j++;

      // ... compute new pheromone values for successor
      var oldPheromoneValue = jsp.jobs[prevJob].tasks[prevTask].pheromonesConcentration[j];

      jsp.jobs[prevJob].tasks[prevTask].pheromonesConcentration[j] =
        (1 - pheromoneDecay) * oldPheromoneValue + pheromoneDecay * pheromoneInitValue;
    }
  }

  // This function performs pheromone oflline updates
  updatePheromones(){
    iterationShortestLength = null;
    // For all ants...
    for(int i=0; i<nbAnts; i++) {
      // ... Comput solution length
      ants[i].solutionLength = computeSolutionLength(ants[i].schedule);
      // ... And update best solutions if needed
      if (iterationShortestLength == null || ants[i].solutionLength < iterationShortestLength){
        iterationShortestLength = ants[i].solutionLength;
        iterationShortestPath = ants[i].solution;
        iterationBestSchedule = ants[i].schedule;
      }
      if (globalShortestLength == null || ants[i].solutionLength < globalShortestLength) {
        globalShortestLength = ants[i].solutionLength;
        globalShortestPath = ants[i].solution;
        globalBestSchedule = ants[i].schedule;
        globalBestHasChanged = true;
      }
    }

    // Compute pheromone evaporation
    for(int i=0; i<jsp.jobs.length; i++){
      for(int j=0; j<jsp.jobs[i].tasks.length; j++){
        for(int k=0; k<jsp.jobs[i].tasks[j].successors.length; k++){
          // Compute pheromone evaporation
          var oldPheromone = jsp.jobs[i].tasks[j].pheromonesConcentration[k];
          var newPheromone = (1 - evaporationRate) * oldPheromone;

          // Compute Ant Deposit
          var id1 = jsp.jobs[i].tasks[j].id;
          var id2 = jsp.jobs[i].tasks[j].successors[k].id;

          // Global best option (user selected)
          if(AppState.selectedBest == BestAnt.globalBest){
            if (isEdgeIJInPath(globalShortestPath, id1, id2)) {
              newPheromone += (evaporationRate * 1 / globalShortestLength);
            }
          }
          // Iteration best option (user selected)
          if(AppState.selectedBest == BestAnt.iterationBest){
            if (isEdgeIJInPath(iterationShortestPath, i, j+i+1)) {
              newPheromone += (evaporationRate * 1 / iterationShortestLength);
            }
          }

          // Update pheromones
          jsp.jobs[i].tasks[j].pheromonesConcentration[k] = newPheromone;
        }
      }
    }
  }

  // This function append last visited node to an ant schedule
  void updateSchedule(Ant ant) {
    // Convert node id to array indexes
    var taskId = ant.currentNode;
    int currentTask = taskId % 100;
    int currentJob = ((taskId - currentTask) / 100).floor();

    Task task = jsp.jobs[currentJob].tasks[currentTask];
    if(task.machine == -1) return;

    int jobConstraintDelay = 0;
    int machineConstraintDelay = 0;
    if( currentTask > 0 ) {
      for (int j = 0; j < ant.schedule.length; j++) {
        jobConstraintDelay = 0;
        int k = 0;
        while (k < ant.schedule[j].length && ant.schedule[j][k].id != task.id - 1) {
          jobConstraintDelay += ant.schedule[j][k].duration;
          k++;
        }
        // if we found machineSchedule[j][k].id == task.id - 1...
        // ... we have computed the final jobConstraintDelay.
        if (k < ant.schedule[j].length && k != 0){
          jobConstraintDelay += ant.schedule[j][k].duration;
          break;
        }
      }
    }
    for(int j=0; j<ant.schedule[task.machine].length; j++){
      machineConstraintDelay += ant.schedule[task.machine][j].duration;
    }
    var delay = jobConstraintDelay > machineConstraintDelay ?
                jobConstraintDelay - machineConstraintDelay : 0;

    ant.schedule[task.machine].add(new Task(task.machine, delay, new Point(-1, -1), -1)); // Dummy task = delay
    ant.schedule[task.machine].add(task);
  }

  // This function returns the length (= duration) of a schedule
  int computeSolutionLength(List<List<Task>> schedule){
    var machineScheduleLengths = <int>[];

    for(int i=0; i<schedule.length; i++){
      machineScheduleLengths.add(0);
      for(int j=0; j<schedule[i].length; j++) {
        machineScheduleLengths[i] += schedule[i][j].duration;
      }
    }
    return( machineScheduleLengths.reduce(max) );
  }

  // This function checks if edge is an edge is part of a solution (solution = path)
  bool isEdgeIJInPath(path, i, j){
    int node = 0;
    if(path.isNotEmpty) {
      while (node < path.length && path[node] != i) node++;
      if(node >= path.length ) return false;

      if (node < path.length - 1 && path[node + 1] == j) {
        return true;
      }
    }
    return false;
  }

  // This functions print a schedule to the console
  printSchedule(List<List<Task>> schedule){
    for(int machine=0; machine<schedule.length; machine++){
      var str = 'machine $machine: ';
      for(int task=0; task<schedule[machine].length; task++) {
        var t = schedule[machine][task];
        str += '(${t.id}, ${t.duration})';
      }
      print(str);
    }
    print('');
  }

  // This functions print a solution (list of nodes id) to the console
  printAntsSolution(){
    for(int i=0; i<nbAnts; i++)
      print(ants[i].solution);
  }
}

