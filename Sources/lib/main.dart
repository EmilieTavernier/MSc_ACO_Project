import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

import "appStaticData.dart";
import "GUIComponents/Buttons.dart";
import "GUIComponents/Forms.dart";
import "GUIComponents/Dropdowns.dart";
import "GUIComponents/Painters.dart";
import "GUIComponents/Animations.dart";
import "GUIComponents/ControlBar.dart";
import "GUIComponents/PopUp.dart";

// The main launch the application window
Future<void> main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACO demonstration software',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Ant Colony Optimisation demonstration app'),
      navigatorKey: navigatorKey,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//class _MyHomePageState extends State<MyHomePage> {
class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var citiesWidgetList = <Widget>[];

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          title: Text(widget.title!),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: IconHelpButton(attachedHelp: AppData.helpACO),
            ),
          ]
        ),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 320, // 308 enough for desktop
            height: double.infinity,
            //flex: 3,
            child: Container( 
              // LEFT PANEL (for parameters)
              color: Colors.teal[100],
              height: double.infinity,
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PROBLEM SECTION
                      Text(
                        'Problem selection',
                        style: AppData.sectionTitleStyle,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          ValueListenableBuilder<int>(
                            builder: (BuildContext context, int value, Widget? child) {
                              return Dropdown(
                                itemsList: AppData.problemsList,
                                menu: DropMenu.problemSlct,
                              );
                            },
                            valueListenable: AppState.dropDownNotifier,
                          ),
                          // Problem help button (the help panel it opens depend of selected problem)
                          ValueListenableBuilder<int>(
                            builder: (BuildContext context, int value, Widget? child) {
                              var selectedHelp = AppData.helpTSP;
                              if( AppState.selectedProblem == Problem.TSP ) // Only for clarity sake
                                selectedHelp = AppData.helpTSP;
                              else if( AppState.selectedProblem == Problem.JSP )
                                selectedHelp = AppData.helpJSP;
                              else if( AppState.selectedProblem == Problem.edgeDetection )
                                selectedHelp = AppData.helpEdgeDetection;

                              return HelpButton(attachedHelp: selectedHelp);
                            },
                            valueListenable: AppState.pbFormsNotifier,
                          ),
                        ]
                      ),
                      // Problem parameters input form
                      ProblemParamForm(),
                      SizedBox(height: 50.0),
                      
                      // ALGO SECTION
                      Text(
                        'Algorithm selection',
                        style: AppData.sectionTitleStyle,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ValueListenableBuilder<int>(
                              builder: (BuildContext context, int value, Widget? child) {
                                return new Dropdown(
                                  itemsList: AppData.acoVariantsList,
                                  menu: DropMenu.algoSlct,
                                );
                              },
                              valueListenable: AppState.dropDownNotifier,
                            ),
                            // Algorithm help button (help panels it opens depend of selected algorithm and selected problem)
                            ValueListenableBuilder<int>(
                              builder: (BuildContext context, int value, Widget? child) {
                                var selectedHelp = AppData.helpAS;
                                if( AppState.selectedAlgo == Algorithm.AS ) // Only for clarity sake
                                  selectedHelp = AppData.helpAS;
                                else if( AppState.selectedAlgo == Algorithm.MMAS )
                                  selectedHelp = AppData.helpMMAS;
                                else if( AppState.selectedAlgo == Algorithm.ACS ) {
                                  // ACS is implemented for the three problem so we check which one is selected
                                  if( AppState.selectedProblem == Problem.edgeDetection )
                                    selectedHelp = AppData.helpEdgeDetectionACS;
                                  else if (AppState.selectedProblem == Problem.JSP)
                                    selectedHelp = AppData.helpJobSchedulingACS;
                                  else // if (AppState.selectedProblem == Problem.TSP)
                                    selectedHelp = AppData.helpACS;
                                }
                                return HelpButton(attachedHelp: selectedHelp);
                              },
                              valueListenable: AppState.algoFormsNotifier,
                            ),
                          ]
                      ),
                      // Algorithm parameters input form
                      ACOParamForm(),
                    ]
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              flex: 9,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      // DEMONSTRATION AREA
                      flex: 8,
                      child: Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: AppData.appRoundedBorders(),
                        child: ValueListenableBuilder<int>(
                          builder: (BuildContext context, int value, Widget? child) {
                            return chooseVisual();
                          },
                          valueListenable: AppState.imageChangeNotifier,
                        ),
                      ),
                    ),
                    ControlBar(),
                    Expanded(
                      // INFORMATION AREA
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.all(10.0),
                        decoration: AppData.appRoundedBorders(),
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10.0),

                              child: SingleChildScrollView(
                                child: ValueListenableBuilder<int>(
                                  builder: (BuildContext context, int value, Widget? child) {
                                    return Text(
                                      '${AppState.executionInfo}\n${AppState.additionalInfo}',
                                    );
                                  },
                                  valueListenable: AppState.executionInfoNotifier,
                                ),
                              ),
                            ),
                            /*
                            Positioned(
                              top: 8,
                              right: -5,
                              child: HelpButton(
                                title: 'Traveling Salesman Problem (TSP)',
                                attachedHelp: AppData.helpTSP
                              ),
                            )
                            */
                          ]
                        )
                      ),
                    ),
                  ]
              )
          )
        ]
      ),

      // Button visible only if selected problem is JSP 
      floatingActionButton:
        ValueListenableBuilder<int>(
          builder: (BuildContext context, int value, Widget? child) {
            return AppState.selectedProblem == Problem.JSP ?
              FloatingActionButton(
                onPressed: () {
                  // Open panel to display list of best schedules found as graph
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => ChartPopUp()
                  );
                },
                tooltip: 'Show graph',
                child: Icon(Icons.insert_chart),
              ) : SizedBox(width: 0,height: 0);
          },
          valueListenable: AppState.pbFormsNotifier,
        ),
    );
  }
}

// This method redirects to demonstration display method corresponding to the currently selected problem
Widget chooseVisual(){
  if(AppState.selectedProblem == Problem.TSP) return VisualTSP();
  if(AppState.selectedProblem == Problem.JSP) return VisualJSP();
  if(AppState.selectedProblem == Problem.edgeDetection) return VisualEdgeDetection();
  return VisualTSP();
}

// This method implements visuals of the TSP demonstration
class VisualTSP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // DISPLAY THE LECTURE KEY
        ValueListenableBuilder<int>(
          builder: (BuildContext context, int value, Widget? child) {
            return CustomPaint( //CustomPaint widget
              size: const Size(double.infinity, double.infinity),
              painter: TSPLegendPainter(),
            );
          },
          valueListenable: AppState.tspNotifier,
        ),
        // DISPLAY PHEROMONES
        ValueListenableBuilder<int>(
          builder: (BuildContext context, int value, Widget? child) {
            return CustomPaint( //CustomPaint widget
              size: const Size(double.infinity, double.infinity),
              painter: PheromonePainter(tsp.cities, aco.pheromoneConcentrations),
            );
          },
          valueListenable: AppState.pheromonesNotifier,
        ),
        // DISPLAY GRAPH NODES (TSP cities)
        ValueListenableBuilder<int>(
          builder: (BuildContext context, int value, Widget? child) {
            return CustomPaint( //CustomPaint widget
              size: const Size(double.infinity, double.infinity),
              painter: CitiesPainter(tsp.cities),
            );
          },
          valueListenable: AppState.tspNotifier,
        ),
        // DISPLAY ANIMATED ANTS
        ValueListenableBuilder<int>(
          builder: (BuildContext context, int value, Widget? child) {
            return Stack(
              fit: StackFit.expand,
              children: aco.ants.asMap().entries.map(
                (e) => AnimatedItemWidget(
                  animation: animation,
                  x: tsp.cities[aco.ants[e.key].previousNode].x.toDouble(),
                  y: tsp.cities[aco.ants[e.key].previousNode].y.toDouble(),
                  targetedX: tsp.cities[aco.ants[e.key].currentNode].x.toDouble(),
                  targetedY: tsp.cities[aco.ants[e.key].currentNode].y.toDouble(),
                ),
              ).toList(),
            );
          },
          valueListenable: AppState.animationNotifier,
        ),
        // TSP GRAPH HELP BUTTON 
        Positioned(
          top: 8,
          right: -5,
          child: HelpButton(attachedHelp: AppData.helpGraphTSP),
          /*
          child: ValueListenableBuilder<int>(
            builder: (BuildContext context, int value, Widget? child) {
              var selectedHelp = AppData.helpGraphTSP;
              if( AppState.selectedProblem == Problem.TSP ) // Only for clarity sake
                selectedHelp = AppData.helpGraphTSP;
              else if( AppState.selectedProblem == Problem.JSP )
                selectedHelp = AppData.helpGraphJSP;
              else if( AppState.selectedProblem == Problem.edgeDetection )
                selectedHelp = AppData.helpGraphImage;

              return HelpButton(attachedHelp: selectedHelp);
            },
            valueListenable: AppState.pbFormsNotifier,
          ),
         */
        ),
      ]
    );
  }
}

// This method implements visuals of the edge detection demonstration
class VisualEdgeDetection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Edge detection related
        Row(
          children: [
            Expanded(
              // LEFT HALF OF THE DEMONSTRATION SPACE
              flex: 2, 
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(10),
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                    // DISPLAY SELECTED IMAGE (on left)
                    ValueListenableBuilder<int>(
                      builder: (BuildContext context, int value, Widget? child) {
                        if( AppState.selectedProblem == Problem.edgeDetection &&
                          AppState.selectedImage.bytes.isNotEmpty ) {
                          return Image.memory(
                            Uint8List.fromList(AppState.selectedImage.bytes),
                            scale: 0.5, // TODO: adapt to take maximum available space
                          );
                        }
                        return SizedBox(width: 0, height: 0);
                      },
                      valueListenable: AppState.imageChangeNotifier,
                    ),
                    // DISPLAY ANIMATED ANTS
                    ValueListenableBuilder<int>(
                      builder: (BuildContext context, int value, Widget? child) {
                        return Stack(
                          fit: StackFit.expand,
                          children: edgeDetectionACO.ants.asMap().entries.map(
                            (e) => AnimatedItemWidget(
                              animation: animation,
                              x: edgeDetection.pixels[edgeDetectionACO.ants[e.key].previousNode].coordinates.x.toDouble(),
                              y: edgeDetection.pixels[edgeDetectionACO.ants[e.key].previousNode].coordinates.y.toDouble(),
                              targetedX: edgeDetection.pixels[edgeDetectionACO.ants[e.key].currentNode].coordinates.x.toDouble(),
                              targetedY: edgeDetection.pixels[edgeDetectionACO.ants[e.key].currentNode].coordinates.y.toDouble(),
                            ),
                          ).toList(),
                        );
                      },
                      valueListenable: AppState.animationNotifier,
                    ),
                  ]
                ),
              ),
            ),
            Expanded(
              // RIGHT HALF OF THE DEMONSTRATION SPACE
              flex: 2,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: [
                    // PHEROMONE DISPLAY (on right)
                    ValueListenableBuilder<int>(
                      builder: (BuildContext context, int value, Widget? child) {
                        return CustomPaint( //CustomPaint widget
                          size: Size(double.infinity, double.infinity),
                          painter: PheromonePainterEdgeDetection(),
                        );
                      },
                      valueListenable: AppState.pheromonesNotifier,
                    ),
                    // ANIMATED ANTS DISPLAY (on right)
                    ValueListenableBuilder<int>(
                      builder: (BuildContext context, int value, Widget? child) {
                        return Stack(
                          fit: StackFit.expand,
                          children: edgeDetectionACO.ants.asMap().entries.map(
                                (e) => AnimatedItemWidget(
                              animation: animation,
                              x: edgeDetection.pixels[edgeDetectionACO.ants[e.key].previousNode].coordinates.x.toDouble(),
                              y: edgeDetection.pixels[edgeDetectionACO.ants[e.key].previousNode].coordinates.y.toDouble(),
                              targetedX: edgeDetection.pixels[edgeDetectionACO.ants[e.key].currentNode].coordinates.x.toDouble(),
                              targetedY: edgeDetection.pixels[edgeDetectionACO.ants[e.key].currentNode].coordinates.y.toDouble(),
                            ),
                          ).toList(),
                        );
                      },
                      valueListenable: AppState.animationNotifier,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned( 
          // GRAPH REPRESENTATION HELP BUTTON 
          top: 8,
          right: -5,
          child: HelpButton(attachedHelp: AppData.helpGraphImage),
        ),
      ]
    );
  }
}

// This method implements visuals of the JSP demonstration
class VisualJSP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children: [
          // DISPLAY LECTURE KEY
          ValueListenableBuilder<int>(
            builder: (BuildContext context, int value, Widget? child) {
              return CustomPaint( //CustomPaint widget
                size: const Size(double.infinity, double.infinity),
                painter: JSPLegendPainter(),
              );
            },
            valueListenable: AppState.tasksNotifier,
          ),
          // DISPLAY PHEROMONES
          ValueListenableBuilder<int>(
            builder: (BuildContext context, int value, Widget? child) {
              return CustomPaint( //CustomPaint widget
                size: Size(double.infinity, double.infinity),
                painter: PheromonePainterJSP(),
              );
            },
            valueListenable: AppState.pheromonesNotifier,
          ),
          // DISPLAY JSP GRAPH (nodes + edges)
          ValueListenableBuilder<int>(
            builder: (BuildContext context, int value, Widget? child) {
              return CustomPaint( //CustomPaint widget
                size: const Size(double.infinity, double.infinity),
                painter: TaskPainter(),
              );
            },
            valueListenable: AppState.tasksNotifier,
          ),
          // DISPLAY ANIMATED ANTS
          ValueListenableBuilder<int>(
            builder: (BuildContext context, int value, Widget? child) {
              return Stack(
                fit: StackFit.expand,
                children: jobSchedulingACO.ants.asMap().entries.map(
                      (e) => AnimatedItemWidget(
                    animation: animation,
                    x: jsp.jobs[((jobSchedulingACO.ants[e.key].previousNode - jobSchedulingACO.ants[e.key].previousNode % 100) / 100).floor()]
                        .tasks[jobSchedulingACO.ants[e.key].previousNode % 100]
                        .coordinates.x.toDouble(),
                    y: jsp.jobs[((jobSchedulingACO.ants[e.key].previousNode - jobSchedulingACO.ants[e.key].previousNode % 100) / 100).floor()]
                        .tasks[jobSchedulingACO.ants[e.key].previousNode % 100]
                        .coordinates.y.toDouble(),
                    targetedX: jsp.jobs[((jobSchedulingACO.ants[e.key].currentNode - jobSchedulingACO.ants[e.key].currentNode % 100) / 100).floor()]
                        .tasks[jobSchedulingACO.ants[e.key].currentNode % 100]
                        .coordinates.x.toDouble(),
                    targetedY: jsp.jobs[((jobSchedulingACO.ants[e.key].currentNode - jobSchedulingACO.ants[e.key].currentNode % 100) / 100).floor()]
                        .tasks[jobSchedulingACO.ants[e.key].currentNode % 100]
                        .coordinates.y.toDouble(),
                  ),
                ).toList(),
              );
            },
            valueListenable: AppState.animationNotifier,
          ),
          // JSP GRAPH HELP BUTTON
          Positioned(
            top: 8,
            right: -5,
            child: HelpButton(attachedHelp: AppData.helpGraphJSP),
          ),
        ]
    );
  }
}

