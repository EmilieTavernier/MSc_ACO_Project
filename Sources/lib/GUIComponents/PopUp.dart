import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'Buttons.dart';
import '../appStaticData.dart';
import 'Painters.dart';
import 'ScrollBar.dart';

// Help panel pop up definition
class HelpPopUp extends StatelessWidget {
  HelpPopUp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      builder: (BuildContext context, int value, Widget? child){
        if(AppState.currentHelp.content == '')
          AppState.currentHelp.loadAsset();

        var widgetButtonsList = getButtonsList();

        return AlertDialog(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween ,
            children:[
              Text(AppState.currentHelp.title),
              Row(
                children: [
                  IconHomeButton(),
                  IconCreditButton()
                ]
              )
            ]
          ),
          content: Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.60, // Width of panel is 60% of the application window
            child: CustomScrollbar(
              //isAlwaysShown: true,
                builder: (context, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Html( // define HTML display style instructions
                          data: AppState.currentHelp.content,
                          style: {
                            // tables will have the below background color
                            "p": Style( // Paragraph
                              fontSize: FontSize(16.0),
                            ),
                            "li": Style( // List
                              fontSize: FontSize(16.0),
                            ),
                            "div": Style( // Workaround for not bold title
                              fontSize: FontSize(20.0),
                            )
                          }
                      ),
                      widgetButtonsList,
                    ]
                  ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        );
      },
      valueListenable: AppState.helpNotifier, // To update help panel after html file was loaded
    );
  }
}

// Alert pop up if computation result is out of range (= infinity)
class Alert extends StatelessWidget {
  Alert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Oops, something went wrong'),
      content: Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.60, // Width of panel is 60% of the application window
        child: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Text('Oops, some parameters are too big and may cause performance issues.'),
              //Text('We reduce them to the maximum allowed.'),
              Text('Some computed number exceeded computer\'s limit' ),
              Text('Please consider reducing alpha, beta or Q parameter' ),
            ]
          )
        ),
      ),
    );
  }
}

// CURRENTLY NOT USED (TODO)
// Alert panel to notify the user if an image is too big and may result in slow performances
class AlertBigImage extends StatelessWidget {
  AlertBigImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Warning'),
      content: Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.60,
        child: SingleChildScrollView(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Text('Oops, some parameters are too big and may cause performance issues.'),
                  //Text('We reduce them to the maximum allowed.'),
                  Text('The image you picked is quite big. This may result in long computation time.' ),
                  Text('For a quicker execution and better results, we recommend using images of size 250x250 or less' ),
                ]
            )
        ),
      ),
    );
  }
}



// Define button list for the index panel and "See also" section of other help panels
Widget getButtonsList() {
  // HELP INDEX DEFINITION
  if (AppState.currentHelp == AppData.helpIndex){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text('Introduction: ', style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        RectangularHelpButton(label: 'Ant Colony Optimisation', attachedHelp: AppData.helpACO),

        SizedBox(height: 10),
        Text('Traveling Salesman Problem', style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        Wrap(
            spacing: 10,
            children: [
              Text('Problem description:'),
              RectangularHelpButton(label: 'The Traveling Salesman', attachedHelp: AppData.helpTSP),
            ]
        ),
        SizedBox(height: 10),
        Wrap(
            spacing: 10,
            children: [
              Text('Graph representation:'),
              RectangularHelpButton(label: 'TSP graph', attachedHelp: AppData.helpGraphTSP),
           ]
        ),
        SizedBox(height: 10),
        Wrap(
            spacing: 10,
            children: [
              Text('Solving method (algorithms):'),
              RectangularHelpButton(label: 'Ant System', attachedHelp: AppData.helpAS),
              RectangularHelpButton(label: 'Max-Min Ant System', attachedHelp: AppData.helpMMAS),
              RectangularHelpButton(label: 'Ant Colony System', attachedHelp: AppData.helpACS),
            ]
        ),


        SizedBox(height: 10),
        Text('Job Scheduling Problem:', style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        Wrap(
            spacing: 10,
            children: [
              Text('Problem description:'),
              RectangularHelpButton(label: 'Job Scheduling', attachedHelp: AppData.helpJSP),
            ]
        ),
        SizedBox(height: 10),
        Wrap(
            spacing: 10,
            children: [
              Text('Graph representation:'),
              RectangularHelpButton(label: 'JSP graph', attachedHelp: AppData.helpGraphJSP),
            ]
        ),
        SizedBox(height: 10),
        Wrap(
            spacing: 10,
            children: [
              Text('Solving method (algorithm):'),
              RectangularHelpButton(label: 'Ant Colony System', attachedHelp: AppData.helpJobSchedulingACS),
            ]
        ),


        SizedBox(height: 10),
        Text('Image processing (edge detection):', style: TextStyle(fontSize: 20)),
        SizedBox(height: 10),
        Wrap(
            spacing: 10,
            children: [
              Text('Problem description:'),
              RectangularHelpButton(label: 'Edge Detection', attachedHelp: AppData.helpEdgeDetection),
            ]
        ),
        SizedBox(height: 10),
        Wrap(
            spacing: 10,
            children: [
              Text('Graph representation:'),
              RectangularHelpButton(label: 'Image graph', attachedHelp: AppData.helpGraphImage),
            ]
        ),
        SizedBox(height: 10),
        Wrap(
            spacing: 10,
            children: [
              Text('Solving method (algorithm):'),
              RectangularHelpButton(label: 'Ant Colony System', attachedHelp: AppData.helpEdgeDetectionACS),
            ]
        ),

      ]
    );
  }

  // HELP PANEL "See Also" SECTION
  var buttonsList = <Widget>[];

  if(AppState.currentHelp == AppData.helpACO) {
    buttonsList.add( RectangularHelpButton(label: 'AS', attachedHelp: AppData.helpAS) );
    buttonsList.add( RectangularHelpButton(label: 'MMAS', attachedHelp: AppData.helpMMAS) );
    buttonsList.add( RectangularHelpButton(label: 'ACS', attachedHelp: AppData.helpACS) );
    buttonsList.add( RectangularHelpButton(label: 'TSP', attachedHelp: AppData.helpTSP) );
    buttonsList.add( RectangularHelpButton(label: 'JSP', attachedHelp: AppData.helpJSP) );
    buttonsList.add( RectangularHelpButton(label: 'Edge detection', attachedHelp: AppData.helpEdgeDetection) );
  }
  else if( AppState.currentHelp == AppData.helpTSP ){
    buttonsList.add( RectangularHelpButton(label: 'TSP graph', attachedHelp: AppData.helpGraphTSP) );
  }
  else if( AppState.currentHelp == AppData.helpJSP ){
    buttonsList.add( RectangularHelpButton(label: 'JSP graph', attachedHelp: AppData.helpGraphJSP) );
  }
  else if( AppState.currentHelp == AppData.helpEdgeDetection ){
    buttonsList.add( RectangularHelpButton(label: 'Image graph', attachedHelp: AppData.helpGraphImage) );
  }
  else if( AppState.currentHelp == AppData.helpGraphTSP ){
    buttonsList.add( RectangularHelpButton(label: 'TSP', attachedHelp: AppData.helpTSP) );
    buttonsList.add( RectangularHelpButton(label: 'AS', attachedHelp: AppData.helpAS) );
    buttonsList.add( RectangularHelpButton(label: 'MMAS', attachedHelp: AppData.helpMMAS) );
    buttonsList.add( RectangularHelpButton(label: 'ACS', attachedHelp: AppData.helpACS) );
  }
  else if( AppState.currentHelp == AppData.helpGraphImage ){
    buttonsList.add( RectangularHelpButton(label: 'Edge detection', attachedHelp: AppData.helpEdgeDetection) );
    buttonsList.add( RectangularHelpButton(label: 'ACS', attachedHelp: AppData.helpEdgeDetectionACS) );
  }
  else if( AppState.currentHelp == AppData.helpGraphJSP ){
    buttonsList.add( RectangularHelpButton(label: 'JSP', attachedHelp: AppData.helpJSP) );
    buttonsList.add( RectangularHelpButton(label: 'ACS', attachedHelp: AppData.helpJobSchedulingACS) );
  }
  else if( AppState.currentHelp == AppData.helpAS ){
    buttonsList.add( RectangularHelpButton(label: 'ACO', attachedHelp: AppData.helpACO) );
    buttonsList.add( RectangularHelpButton(label: 'TSP', attachedHelp: AppData.helpTSP) );
    buttonsList.add( RectangularHelpButton(label: 'TSP graph', attachedHelp: AppData.helpGraphTSP) );
  }
  else if( AppState.currentHelp == AppData.helpMMAS ){
    buttonsList.add( RectangularHelpButton(label: 'ACO', attachedHelp: AppData.helpACO) );
    buttonsList.add( RectangularHelpButton(label: 'TSP', attachedHelp: AppData.helpTSP) );
    buttonsList.add( RectangularHelpButton(label: 'TSP graph', attachedHelp: AppData.helpGraphTSP) );
  }
  else if( AppState.currentHelp == AppData.helpACS ){
    buttonsList.add( RectangularHelpButton(label: 'ACO', attachedHelp: AppData.helpACO) );
    buttonsList.add( RectangularHelpButton(label: 'TSP', attachedHelp: AppData.helpTSP) );
    buttonsList.add( RectangularHelpButton(label: 'TSP graph', attachedHelp: AppData.helpGraphTSP) );
  }
  else if( AppState.currentHelp == AppData.helpEdgeDetectionACS ){
    buttonsList.add( RectangularHelpButton(label: 'Edge detection', attachedHelp: AppData.helpEdgeDetection) );
    buttonsList.add( RectangularHelpButton(label: 'Image graph', attachedHelp: AppData.helpGraphImage) );
  }
  else if( AppState.currentHelp == AppData.helpJobSchedulingACS ){
    buttonsList.add( RectangularHelpButton(label: 'JSP', attachedHelp: AppData.helpJSP) );
    buttonsList.add( RectangularHelpButton(label: 'JSP graph', attachedHelp: AppData.helpGraphJSP) );
  }
  else if( AppState.currentHelp == AppData.helpJobDescription ){
    buttonsList.add( RectangularHelpButton(label: 'JSP', attachedHelp: AppData.helpJSP) );
  }
  else if( AppState.currentHelp == AppData.helpCredits ){
    buttonsList.add( RectangularHelpButton(label: 'Index', attachedHelp: AppData.helpIndex) );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "See Also",
        style: TextStyle(fontSize: 20),
      ),
      SizedBox(height: 10),
      Wrap(
        spacing: 10,
        children: buttonsList,
      ),
    ],
  );

}

// CURRENTLY NOT USED
// To use if some dropdown options are not implemented yet
class AlertNotAvailable extends StatelessWidget {
  AlertNotAvailable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Option unavailable'),
      content: Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.60,
        child: SingleChildScrollView(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Text('Oops, some parameters are too big and may cause performance issues.'),
                  //Text('We reduce them to the maximum allowed.'),
                  Text('Sorry, this option has not been implemented yet' ),
                ]
            )
        ),
      ),
    );
  }
}

// JSP specific pop up to display best schedule graphs
class ChartPopUp extends StatelessWidget {
  ChartPopUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String intro = 'Here is the list of the global best schedules found during the current experiment.';
    if( jobSchedulingACO.bestScheduleRecord.isEmpty )
      intro = 'No schedule yet';

    return AlertDialog(
      title: Text('Schedule'),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.60,
        height: MediaQuery.of(context).size.height * 0.80,
        child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(intro),

                CustomPaint( //CustomPaint widget
                  //size: const Size(double.infinity, double.infinity),
                  size: Size(
                    MediaQuery.of(context).size.width * 0.60,
                    MediaQuery.of(context).size.height * 0.80  / 10,
                  ),
                  painter: JSPLegendPainter(inLine: true),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: jobSchedulingACO.bestScheduleRecord.asMap().entries.map(
                    (e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Best schedule known after iteration ${jobSchedulingACO.bestScheduleIterationRecord[e.key] + 1}:'),
                        SizedBox(height: 40),
                        CustomPaint( //CustomPaint widget
                          //size: const Size(double.infinity, double.infinity),
                          size: Size(
                            MediaQuery.of(context).size.width * 0.60,
                            MediaQuery.of(context).size.height * 0.80  / 2,
                          ),
                          painter: SchedulePainter(schedule: jobSchedulingACO.bestScheduleRecord[e.key]),
                        ),
                        SizedBox(height: 40),
                      ]
                    ),
                  ).toList()
                ),

              ]
            )
        ),
      ),
    );
  }
}
