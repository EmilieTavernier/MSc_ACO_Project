import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';

import 'AntColonyImplementation/acoSolvingTSP.dart';
import 'AntColonyImplementation/acoSolvingJSP.dart';
import "AntColonyImplementation/acoSolvingEdgeDetection.dart";
import "GUIComponents/PopUp.dart";
import 'ProblemsDefinition/TSP.dart';
import 'ProblemsDefinition/JSP.dart';
import 'ProblemsDefinition/EdgeDetection.dart';

// ********************************************************************
// STATE RELATED DATA
// ********************************************************************

TSP tsp = new TSP(nbCities: 0);
ACO aco = new ACO(0, 0, 0, 0, 0, 0, 0, null, null, null, null);
JSP jsp = new JSP([]);
EdgeDetection edgeDetection = new EdgeDetection();
EdgeDetectionACO edgeDetectionACO = new EdgeDetectionACO(0, 0, 0, 0, 0, 0, 0, 0);
JobSchedulingACO jobSchedulingACO = new JobSchedulingACO(0, 0, 0, 0, 0, 0, 0);

late Animation<double> animation;
late AnimationController controller;
final navigatorKey = GlobalKey<NavigatorState>();

List<Widget> jobsField = [];
var jobsCtrl = [];

class AppState{
  static final ValueNotifier<int> tspNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> imageChangeNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> pheromonesNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> tasksNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> animationNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> buttonsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> executionInfoNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> algoFormsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> pbFormsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> dropDownNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> visualNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> helpNotifier = ValueNotifier<int>(0);

  static Algorithm? selectedAlgo = Algorithm.AS; // O AS, 1 MMAS, 2 ACS
  static Problem? selectedProblem = Problem.TSP; // O TSP, 1 JSP, 3 Edge Detection
  static BestAnt? selectedBest = BestAnt.globalBest;

  static FileSource? selectedSource = FileSource.sample;
  static ImageData selectedImage = ImageData();

  static var currentHelp = AppData.helpACO;

  static String executionInfo = 'Press the button Generate in the section "Problem parameters" and then the button Start in "Algorithm selection" to launch a demonstration.';
  static String additionalInfo = '';

  static bool performingACO = false;
  static bool animating = false;
  static bool abort = false;

  static bool paused = false;
  static int pauseStartTime = 0;
  static int pauseDuration = 0;

  static int speedInMs = 2000;

  static void stop(){
    controller.stop();
    if(performingACO) abort = true;

    // Security in case the demonstration was already paused:
    pauseStartTime = 0;
    paused = false;
    updateButtons();
    updateDropDown();

    executionInfo = 'Press the button Start in the section "Algorithm selection" to launch a demonstration';
    additionalInfo = '';
    updateExecutionInfo();
  }

  static void overflow(){
    stop();
    showDialog<String>(
        context: navigatorKey.currentState!.overlay!.context,
        builder: (context) => Alert()
    );
  }

  static void pause(){
    if(performingACO){
      pauseStartTime = DateTime.now().millisecondsSinceEpoch;
      paused = true;
      updateButtons();
      updateDropDown();
      controller.stop();
    }
  }

  static void play(){
    if(performingACO && paused){
      pauseDuration += DateTime.now().millisecondsSinceEpoch - pauseStartTime;
      paused = false;
      updateButtons();
      updateDropDown();
      controller.forward();
    }
  }

  static void generateProblem({nbCities, jobsDescription}){
    executionInfo = 'Press the button Start in the section "Algorithm selection" to launch a demonstration';
    additionalInfo = '';
    updateExecutionInfo();

    // Reinitialised ACO related data and update GUI
    tsp = new TSP(nbCities: 0);
    aco = new ACO(0, 0, 0, 0, 0, 0, 0, null, null, null, null);
    aco.pheromoneConcentrations = [];
    edgeDetectionACO = new EdgeDetectionACO(0, 0, 0, 0, 0, 0, 0, 0);
    jobSchedulingACO = new JobSchedulingACO(0, 0, 0, 0, 0, 0, 0);

    if(selectedProblem == Problem.TSP) {
      tsp = new TSP(nbCities: nbCities);
      controller.duration = Duration(milliseconds: AppState.speedInMs);
    }
    else if(selectedProblem == Problem.edgeDetection) {
      edgeDetection = new EdgeDetection();
      controller.duration = const Duration(seconds: 0);
    }
    else if(selectedProblem == Problem.JSP){
      jsp = new JSP(jobsDescription);
      controller.duration = Duration(milliseconds: AppState.speedInMs);
    }
    tspNotifier.value = (AppState.tspNotifier.value + 1) % 2;

    updatePheromones();
    updateAnimation();
    updateVisual();
    updateTasks();
    imageChangeNotifier.value = (AppState.imageChangeNotifier.value + 1) % 2;
  }

  static void updateImage(){
    edgeDetection = new EdgeDetection();
  }

  static void updateTSP(nbCities){
    tsp = new TSP(nbCities: nbCities);
  }

  static void launchDemonstration( int nbAnts, int nbIterations, int nbConstructionSteps,
                                   var pheromoneInitValue,
                                   var evaporationRate, var alpha, var beta, var Q,
                                   var maxPheromone, var minPheromone,
                                   var pheromoneDecay, var q0){

    // Reinitialised ACO related data and update gui
    aco = new ACO(0, 0, 0, 0, 0, 0, 0, null, null, null, null);
    aco.pheromoneConcentrations = [];

    controller.duration = Duration(milliseconds: AppState.speedInMs);

    updatePheromones();
    updateAnimation();

    // Launch new ACO algorithm
    if(selectedProblem == Problem.TSP){
      if (tsp.cities.length <= 1) return;
      aco = new ACO(
          nbAnts, nbIterations, pheromoneInitValue, evaporationRate, alpha, beta, Q,
          maxPheromone, minPheromone,
          pheromoneDecay, q0
      );
      aco.performAntSystem();
    }
    else if (selectedProblem == Problem.edgeDetection){
      if(edgeDetection.pixels.isEmpty) return;
      edgeDetectionACO = new EdgeDetectionACO(
        nbAnts, nbIterations, nbConstructionSteps, pheromoneInitValue,
        alpha, beta, evaporationRate, pheromoneDecay
      );
      edgeDetectionACO.performACS();
    }
    else if (selectedProblem == Problem.JSP){
      JSP jsp = new JSP(['(0,3);(1,2);(2,2)', '(0,2);(2,1);(1,4)', '(1,4);(2,3)']);
      jobSchedulingACO = new JobSchedulingACO(
        nbAnts, nbIterations, pheromoneInitValue,
        alpha, beta, evaporationRate, pheromoneDecay
      );
      jobSchedulingACO.performACS();
    }
  }

  static void updatePheromones(){
    //aco = new ACO(10, 20, 1, 0.3, 1, 1, 2);
    //aco.performAntSystem();
    //aco.printAntsSolution();
    AppState.pheromonesNotifier.value = (AppState.pheromonesNotifier.value + 1) % 2;
  }

  static void updateAnimation(){
    AppState.animationNotifier.value = (AppState.animationNotifier.value + 1) % 2;
    controller.reset();
    if( performingACO ) controller.forward();
  }

  static void updateDemoStatus(){
    performingACO = !performingACO;
    updateButtons();
    updateDropDown();
  }

  static void updateButtons(){
    AppState.buttonsNotifier.value = (AppState.buttonsNotifier.value + 1) % 2;
  }

  static void updateDropDown(){
    AppState.dropDownNotifier.value = (AppState.dropDownNotifier.value + 1) % 2;
  }

  static void updateAlgoForms(){
    AppState.algoFormsNotifier.value = (AppState.algoFormsNotifier.value + 1) % 2;
  }

  static void updatePbForms(){
    AppState.pbFormsNotifier.value = (AppState.pbFormsNotifier.value + 1) % 2;
  }

  static void updateVisual(){
    AppState.visualNotifier.value = (AppState.visualNotifier.value + 1) % 2;
  }

  static void updateHelp(){
    AppState.helpNotifier.value = (AppState.helpNotifier.value + 1) % 2;
  }

  static void updateExecutionInfo({String? info, String? additional}){
    executionInfo = info == null ? executionInfo : info;
    additionalInfo = additional == null ? additionalInfo : additional;
    executionInfoNotifier.value = (AppState.executionInfoNotifier.value + 1) % 2;
  }

  static void updateTasks(){
    AppState.tasksNotifier.value = (AppState.tasksNotifier.value + 1) % 2;
  }

}

// ********************************************************************
// GUI RELATED DATA
// ********************************************************************

class AppData{
  // Selectable features
  static final problemsList = [
    'Traveling Salesman Problem (TSP)',
    'Job Scheduling Problem (JSP)',
    'Edge Detection'
  ];

  static final acoVariantsList = [
    'Ant System (AS)',
    'Max-min Ant System (MMAS)',
    'Ant Colony System (ACS)'
  ];

  // GUI style
  static TextStyle defaultTextStyle = TextStyle(fontSize: 14);
  static TextStyle sectionTitleStyle = TextStyle(height: 2, fontSize: 15);
  static TextStyle regularTextStyle = TextStyle(color: Colors.black);
  static TextStyle helpButtonTextStyle = TextStyle(color: Colors.white);
  static TextStyle rectangularBtnStyle = TextStyle(color: Colors.white);

  static BoxDecoration appRoundedBorders() {
    return BoxDecoration(
      border: Border.all(width: 1.0, color: Color(0xFF303030)),
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  static var jspJobColors = [
    Colors.teal,
    Colors.deepOrangeAccent,
    Colors.amber,
    Colors.deepPurpleAccent[400]!,
    Colors.cyanAccent[400]!,
    Colors.green[600]!,
  ];

  // help content
  static Help helpIndex = Help(
    title: 'Help index',
    content: '''<p>Welcome to the help index. You can access all help content from here.</p>'''
  );
  static Help helpTSP = Help(
    title: 'Traveling Salesman Problem (TSP)',
    file: 'assets/html/traveling_salesman_problem.html'
  );
  static Help helpAS = Help(
    title: 'Ant System (AS)',
    file: 'assets/html/ant_system.html'
  );
  static Help helpACO = Help(
    title: 'Ant Colony Optimisation (ACO)',
    file: 'assets/html/ant_colony_optimisation.html'
  );
  static Help helpGraphTSP = Help(
    title: 'TSP graph representation',
    file: 'assets/html/tsp_graph_representation.html'
  );
  static Help helpEdgeDetection = Help(
    title: 'Edge detection',
    file: 'assets/html/edge_detection.html'
  );
  static Help helpGraphImage = Help(
    title: 'Image graph representation',
    file: 'assets/html/image_graph_representation.html'
  );
  static Help helpMMAS = Help(
    title: 'Max-Min Ant System (MMAS)',
    file: 'assets/html/max_min_ant_system.html'
  );
  static Help helpEdgeDetectionACS = Help(
      title: 'ACS for edge detection',
      file: 'assets/html/acs_for_edge_detection.html'
  );
  static Help helpJobSchedulingACS = Help(
      title: 'ACS for job scheduling',
      file: 'assets/html/acs_for_job_scheduling.html'
  );
  static Help helpGraphJSP = Help(
      title: 'JSP graph representation',
      file: 'assets/html/jsp_graph_representation.html'
  );
  static Help helpJSP = Help(
      title: 'Job Scheduling Problem (JSP)',
      file: 'assets/html/job_scheduling_problem.html'
  );
  static Help helpACS = Help(
      title: 'Ant Colony System (ACS)',
      file: 'assets/html/ant_colony_system.html'
  );
  static Help helpJobDescription = Help(
      title: 'Job description format',
      file: 'assets/html/job_description_format.html'
  );
  static Help helpCredits = Help(
      title: 'Credits',
      file: 'assets/html/credits.html'
  );
}

class Help{
  String title = '';
  String file = '';
  String content = '';

  Help({required title, file, content}){
    this.title = title;
    if(file != null) this.file = file;
    if(content != null) this.content = content;
  }

  void loadAsset() async {
    content = await rootBundle.loadString(file);
    AppState.updateHelp();
  }
}

class ImageData{
  List<int> bytes = [];
  String name = 'apple.PNG'; // Default (first image from sample)
  int width = 0;
  int height = 0;
}

enum BestAnt { globalBest, iterationBest }
enum FileSource { sample, computer }
enum Algorithm { AS, MMAS, ACS }
enum Problem { TSP, JSP, edgeDetection }
enum DropMenu { problemSlct, algoSlct, shortAlgoSlct, imagesSample }
