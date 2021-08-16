import 'dart:math';
import 'dart:ui';

import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/material.dart';

import "../appStaticData.dart";
import '../ProblemsDefinition/JSP.dart';


//*******************************************************
// PHEROMONE PAINTER (TSP)
//*******************************************************

class PheromonePainter extends CustomPainter { //         <-- CustomPainter class
  var tspCities;
  var pheromoneConcentrations;

  PheromonePainter(tspCities, pheromoneConcentrations){
    this.tspCities = tspCities;
    this.pheromoneConcentrations = pheromoneConcentrations;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if(pheromoneConcentrations.length == 0) return;

    var parentWidth = size.width;
    var parentHeight = size.height;
    var marginX = 0.1 * parentWidth;
    var marginY = 0.1 * parentHeight;

    // Find pheromones max value. -> TODO? optimised in ACOImplementation.dart?
    var max = pheromoneConcentrations[0][0];
    bool allEqual = true;

    // Iterate through all edges i-j to find the maximum pheromone concentration
    for(int i=0; i<pheromoneConcentrations.length; i++){
      for(int j=0; j<pheromoneConcentrations[i].length; j++){
        if(max < pheromoneConcentrations[i][j] )
          max = pheromoneConcentrations[i][j];
        if( pheromoneConcentrations[i][j] != max )
          allEqual = false;
      }
    }

    // Paint pheromones
    for(int i=0; i<pheromoneConcentrations.length; i++){
      for(int j=0; j<pheromoneConcentrations[i].length; j++){
        Color edgeColor = Colors.black;
        double thickness = 3.0;

        // If edge ij is in best path...
        if ( aco.isEdgeIJInPath(aco.globalShortestPath, i, j+i+1) ){
          //... we paint it in orange
          edgeColor = Colors.deepOrange;
        }
        // If pheromones concentration are all equal (first iteration), we reduce thickness for visual clarity
        if(allEqual) thickness = 1.0;

        // Paint edges with opacity and thickness proportional to pheromone concentration for the current iteration
        var paint = Paint()
        ..color = edgeColor.withOpacity(pheromoneConcentrations[i][j]/max)
        ..strokeWidth = thickness * pheromoneConcentrations[i][j]/max;

        // Translate cities coordinates to demonstration area coordinates
        double x1 = marginX + tsp.cities[i].x.toDouble() * (parentWidth - 2 * marginX);
        double y1 = parentHeight - (marginY + tsp.cities[i].y.toDouble() * (parentHeight - 2 * marginY));
        double x2 = marginX + tsp.cities[j+i+1].x.toDouble() * (parentWidth - 2 * marginX);
        double y2 = parentHeight - (marginY + tsp.cities[j+i+1].y.toDouble() * (parentHeight - 2 * marginY));

        var p1 = Offset(x1, y1);
        var p2 = Offset(x2, y2);
        // Draw edge ij pheromone concentration
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(PheromonePainter old) {
    return true;
    //return old.pheromoneConcentrations != pheromoneConcentrations;
  }
}

//*******************************************************
// PHEROMONE PAINTER (Edge Detection)
//*******************************************************
class PheromonePainterEdgeDetection extends CustomPainter { //         <-- CustomPainter class
  @override
  void paint(Canvas canvas, Size size) {
    if( edgeDetection.pixels.length == 0 ||
        edgeDetection.pixels[0].pheromoneValue == 0) return;

    var parentWidth = size.width;
    var parentHeight = size.height;
    var newImageWidth = AppState.selectedImage.width.toDouble() * 2;
    var newImageHeight = AppState.selectedImage.height.toDouble() * 2;

    // Compute onscreen image dimensions
    if( AppState.selectedImage.width > AppState.selectedImage.height &&
        AppState.selectedImage.width > size.width / 2){
      newImageWidth = parentWidth;
      newImageHeight = newImageWidth * AppState.selectedImage.height / AppState.selectedImage.width;
    }
    else if( AppState.selectedImage.height > AppState.selectedImage.width &&
             AppState.selectedImage.height > size.height ){
      newImageHeight = parentHeight;
      newImageWidth = newImageHeight * AppState.selectedImage.width / AppState.selectedImage.height;
    }

    // Find pheromones max and mean value. -> TODO? optimised in ACOImplementation.dart?
    List<double> pheromone = [];
    for(int i=0; i<edgeDetection.pixels.length; i++){
      pheromone.add(edgeDetection.pixels[i].pheromoneValue);
    }
    pheromone.sort();
    var max = pheromone.last;
    var median = pheromone[(pheromone.length/2).floor()];

    // For all pixels, paint pheromones...
    for(int i=0; i<edgeDetection.pixels.length; i++){
      // ... only if concentration is big enough (> median)
      if(edgeDetection.pixels[i].pheromoneValue > median) {
        Color edgeColor = Colors.black;

        var paint = Paint()
          ..color = edgeColor.withOpacity(
              edgeDetection.pixels[i].pheromoneValue / max)
          ..strokeWidth = 1.0;

        // Translate pixel image coordinates to demonstration 
        double x = edgeDetection.pixels[i].coordinates.x.toDouble();
        double y = edgeDetection.pixels[i].coordinates.y.toDouble();

        x = x * newImageWidth / AppState.selectedImage.width;
        y = y * newImageHeight / AppState.selectedImage.height;

        // Demonstration area is cut in half (image on left side, pheromone display on right side)
        x = x + parentWidth / 2 - newImageWidth / 2;
        y = y + parentHeight / 2 - newImageHeight / 2;

        // TODO: correct if greater than available space
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(PheromonePainterEdgeDetection old) {
    return true;
    //return old.pheromoneConcentrations != pheromoneConcentrations;
  }
}

//*******************************************************
// CITIES PAINTER (TSP)
//*******************************************************

class CitiesPainter extends CustomPainter { //         <-- CustomPainter class
  var tspCities;

  CitiesPainter(tspCities){
    this.tspCities = tspCities;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var parentWidth = size.width;
    var parentHeight = size.height;
    var marginX = 0.1 * parentWidth;
    var marginY = 0.1 * parentHeight;

    // Paint pheromones
    for(int i=0; i<tspCities.length; i++){
      var paint = Paint()
        ..color = Colors.teal
        ..style = PaintingStyle.fill;

      // Translate cities coordinates to demonstration area coordinates
      double x = marginX + tsp.cities[i].x.toDouble() * (parentWidth - 2 * marginX);
      double y = parentHeight - (marginY + tsp.cities[i].y.toDouble() * (parentHeight - 2 * marginY));

      canvas.drawCircle(Offset(x, y), 10, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}

//*******************************************************
// CIRCLE PAINTER (Ants - TSP)
//*******************************************************

class CirclePainter extends CustomPainter { //         <-- CustomPainter class
  CirclePainter({required this.x, required this.y});
  final double x;
  final double y;

  @override
  void paint(Canvas canvas, Size size) {
    var parentWidth = size.width;
    var parentHeight = size.height;
    var marginX = 0.1 * parentWidth;
    var marginY = 0.1 * parentHeight;

    // Paint circle
    var paint = Paint()
      ..color = Colors.amber.shade800
      ..style = PaintingStyle.fill;

    
    // Translate ants coordinates to demonstration area coordinates
    double newX = marginX + x * (parentWidth - 2 * marginX);
    double newY = parentHeight - (marginY + y * (parentHeight - 2 * marginY));
    
    canvas.drawCircle(Offset(newX, newY), 5, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

//*******************************************************
// CIRCLE PAINTER (Ants - Edge Detection)
//*******************************************************

class CirclePainterEdgeDetection extends CustomPainter { //         <-- CustomPainter class
  CirclePainterEdgeDetection({required this.x, required this.y});
  final double x;
  final double y;

  @override
  void paint(Canvas canvas, Size size) {
    var parentWidth = size.width;
    var parentHeight = size.height;
    var newImageWidth = AppState.selectedImage.width.toDouble() * 2;
    var newImageHeight = AppState.selectedImage.height.toDouble() * 2;

    // Retrieve on screen image dimensions
    if( AppState.selectedImage.width > AppState.selectedImage.height &&
        AppState.selectedImage.width > size.width / 2){
      newImageWidth = parentWidth;
      newImageHeight = newImageWidth * AppState.selectedImage.height / AppState.selectedImage.width;
    }
    else if( AppState.selectedImage.height > AppState.selectedImage.width &&
        AppState.selectedImage.height > size.height ){
      newImageHeight = parentHeight;
      newImageWidth = newImageHeight * AppState.selectedImage.width / AppState.selectedImage.height;
    }

    // Paint circle
    var paint = Paint()
      ..color = Colors.amber.shade800
      ..style = PaintingStyle.fill;

    // Translate ant coordinates to demonstration area coordinates
    double newX = x * newImageWidth / AppState.selectedImage.width;
    double newY = y * newImageHeight / AppState.selectedImage.height;

    // Demonstration area is cut in half (image displayed on left side, pheromone displayed on right side)
    newX = newX + parentWidth / 2 - newImageWidth / 2;
    newY = newY + parentHeight / 2 - newImageHeight / 2;

    canvas.drawCircle(Offset(newX, newY), 1, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}



//*******************************************************
// CIRCLE PAINTER (Ants - JSP)
//*******************************************************

class CirclePainterJSP extends CustomPainter { //         <-- CustomPainter class
  CirclePainterJSP({
    required this.x, required this.y,
    required this.targetedX, required this.targetedY,
    var value, required this.adjustment
  });
  double x;
  double y;
  double adjustment;

  var value;
  var targetedX;
  var targetedY;

  @override
  void paint(Canvas canvas, Size size) {
    if(!AppState.animating || AppState.paused) return;
    var parentWidth = size.width;
    var parentHeight = size.height;
    var marginX = 0.1 * parentWidth;
    var marginY = 0.1 * parentHeight;

    // Paint circle
    var paint = Paint()
      ..color = Colors.amber.shade800
      ..style = PaintingStyle.fill;

    bool noShift = false;
    if( ( x == jsp.jobs[0].tasks[0].coordinates.x &&
        y == jsp.jobs[0].tasks[0].coordinates.y ) ||
        y == targetedY ){
      noShift = true;
    }

    // Translate ant coordinates to demonstration area coordinates
    x = marginX + x/jsp.nbMaxTasks * (parentWidth - 2 * marginX);
    y = parentHeight - (marginY + y/jsp.jobs.length * (parentHeight - 2 * marginY));
    targetedX = marginX + targetedX/jsp.nbMaxTasks * (parentWidth - 2 * marginX);
    targetedY = parentHeight - (marginY + targetedY/jsp.jobs.length * (parentHeight - 2 * marginY));
    targetedX += adjustment;

    // Take into account edge's curve
    var norm = sqrt((targetedY - y) * (targetedY - y) + (targetedX - x) * (targetedX - x));
    var unitVectorX = - (targetedY - y) / norm;
    var unitVectorY = (targetedX - x) / norm;
    var shift = norm * 0.1;
    if( noShift ) shift = 0;

    Path path = Path();
    path.moveTo(x, y);
    path.quadraticBezierTo(
        (x + targetedX)/2 + unitVectorX * shift,
        (y + targetedY)/2 + unitVectorY * shift,
        targetedX,
        targetedY
    );

    PathMetrics pathMetrics = path.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt(0);
    value = pathMetric.length * animation.value;
    Tangent pos = pathMetric.getTangentForOffset(value)!;

    //var currentX = marginX + pos.position.dx/jsp.nbMaxTasks * (parentWidth - 2 * marginX);
    //var currentY = parentHeight - (marginY + pos.position.dy/jsp.jobs.length * (parentHeight - 2 * marginY));

    canvas.drawCircle(Offset(pos.position.dx, pos.position.dy), 5, paint);

    //x = marginX + x/jsp.nbMaxTasks * (parentWidth - 2 * marginX);
    //y = parentHeight - (marginY + y/jsp.jobs.length * (parentHeight - 2 * marginY));
    //canvas.drawCircle(Offset(x + adjustment, y), 5, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}


//*******************************************************
// Task painters (JSP)
//*******************************************************

class TaskPainter extends CustomPainter { //         <-- CustomPainter class
  var canvas;

  var parentWidth;
  var parentHeight;
  var marginX;
  var marginY;

  var radius = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    this.canvas = canvas;

    parentWidth = size.width;
    parentHeight = size.height;
    marginX = 0.1 * parentWidth;
    marginY = 0.1 * parentHeight;

    // PAINT DIRECTED EDGES (ARROWS)
    for(int i=0; i<jsp.jobs.length; i++) {
      var tasks = jsp.jobs[i].tasks;
      for (int j = 0; j < tasks.length; j++) {
        for(int k = 0; k < tasks[j].successors.length; k++) {
          paintArrow(tasks[j], tasks[j].successors[k]);
        }
      }
    }

    // PAINT TASKS
    for(int i=0; i<jsp.jobs.length; i++){
      var tasks = jsp.jobs[i].tasks;

      for(int j=0; j<tasks.length; j++) {
        var paint = Paint()
          ..color = AppData.jspJobColors[i] //Colors.teal
          ..style = PaintingStyle.fill;

        double x = tasks[j].coordinates.x.toDouble();
        double y = tasks[j].coordinates.y.toDouble();

        // Translate task node coordinates to demonstration area coordinates
        x = marginX + x/jsp.nbMaxTasks * (parentWidth - 2 * marginX);
        y = parentHeight - (marginY + y/jsp.jobs.length * (parentHeight - 2 * marginY));

        canvas.drawCircle(Offset(x, y), radius, paint);

        // Display task description "(machine, duration)" above the task node
        String str = '(${tasks[j].machine}, ${tasks[j].duration})';
        if(i == 0) str = 'start';
        TextSpan span = new TextSpan(
            style: AppData.regularTextStyle,
            text: str,
        );
        final textPainter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: size.width,
        );
        var deltaX = 15;
        textPainter.paint(canvas, Offset(x - deltaX, y-35));
      }
    }
  }

  // Method to paint an arrow
  paintArrow(task1, task2){
    double x1 = task1.coordinates.x.toDouble();
    double y1 = task1.coordinates.y.toDouble();
    double x2 = task2.coordinates.x.toDouble();
    double y2 = task2.coordinates.y.toDouble();

    // Translate to demonstration area coordinates
    x1 = marginX + x1 / jsp.nbMaxTasks * (parentWidth - 2 * marginX);
    y1 = parentHeight -
        (marginY + y1 / jsp.jobs.length * (parentHeight - 2 * marginY));
    x2 = marginX + x2 / jsp.nbMaxTasks * (parentWidth - 2 * marginX);
    y2 = parentHeight -
        (marginY + y2 / jsp.jobs.length * (parentHeight - 2 * marginY));

    var t1 = task1.id % 100;
    var t2 = task2.id % 100;
    var j1 = ((task1.id - t1) / 100).floor();
    var j2 = ((task2.id - t2) / 100).floor();

    var paint = Paint();
    var path = Path();

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    paint.color = Colors.black.withOpacity(0.2);

    // If edge is linked to departure point or linked 2 tasks from a common job
    if(j1 == 0 || j1 == j2) {
      // ... it is a straight edge (no curve)
      path.moveTo(x1, y1);
      path.lineTo(x2 - radius, y2);
      path = ArrowPath.make(path: path);

      canvas.drawPath(path, paint);
    }
    else{
      // ... else it is curved to prevent overlaps
      
      //var adjustment =  j1 < j2 ? - radius : radius;

      //paint.color = AppData.jspMachineColors[task1.machine];
      //path.moveTo(x1 + adjustment, y1);
      //path.lineTo(x2 + adjustment, y2);

      var norm = sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1));

      var unitVectorX = - (y2 - y1) / norm;
      var unitVectorY = (x2 - x1) / norm;

      var shift = norm * 0.1;

      path.moveTo(x1, y1);
      path.quadraticBezierTo(
          (x1 + x2)/2 + unitVectorX * shift,
          (y1 + y2)/2 + unitVectorY * shift,
          x2,
          y2
      );

      //canvas.drawPath(path, paint);
      path = ArrowPath.make(path: path);
      canvas.drawPath(path, paint);
      /*
      canvas.drawPath(
        dashPath(path, dashArray: CircularIntervalList<double>(<double>[5.0, 10.0])),
        paint
      );
      */
    }

  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

//*******************************************************
// PHEROMONE PAINTER (JSP)
//*******************************************************

class PheromonePainterJSP extends CustomPainter { //         <-- CustomPainter class

  @override
  void paint(Canvas canvas, Size size) {
    if(jsp.jobs[0].tasks[0].pheromonesConcentration.isEmpty) return;

    var parentWidth = size.width;
    var parentHeight = size.height;
    var marginX = 0.1 * parentWidth;
    var marginY = 0.1 * parentHeight;

    var radius = 10.0;

    double graphHeight = parentHeight - 2 * marginY;
    double graphWidth = parentWidth - 2 * marginX;

    // Find pheromones max value.
    var max = jsp.jobs[0].tasks[0].pheromonesConcentration[0];

    for(int i=0; i<jsp.jobs.length; i++){
      for(int j=0; j<jsp.jobs[i].tasks.length; j++){
        for(int k=0; k<jsp.jobs[i].tasks[j].successors.length; k++) {
          if (max < jsp.jobs[i].tasks[j].pheromonesConcentration[k]) {
            max = jsp.jobs[i].tasks[j].pheromonesConcentration[k];
          }
        }
      }
    }

    // Paint pheromones
    for(int i=0; i<jsp.jobs.length; i++){
      for(int j=0; j<jsp.jobs[i].tasks.length; j++){
        Task taskJ = jsp.jobs[i].tasks[j];
        for(int k=0; k<jsp.jobs[i].tasks[j].successors.length; k++) {
          Task successorK = jsp.jobs[i].tasks[j].successors[k];

          Color edgeColor = Colors.black;
          // if edge ij belong to best path...
          if ( jobSchedulingACO.isEdgeIJInPath(jobSchedulingACO.globalShortestPath, taskJ.id, successorK.id) ){
            //... It is painted in orange
            edgeColor = Colors.deepOrange;
          }

          var paint = Paint()
          ..color = edgeColor.withOpacity(taskJ.pheromonesConcentration[k]/max)
          //..color = edgeColor == Colors.deepOrange? edgeColor.withOpacity(1) : edgeColor.withOpacity(0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
          //..strokeWidth = 2.0;

          // Translate to demonstration area coordinates
          double x1 = marginX + 
                      taskJ.coordinates.x.toDouble() / 
                      jsp.nbMaxTasks * (parentWidth - 2 * marginX);
          double y1 = parentHeight - (
                        marginY + taskJ.coordinates.y.toDouble() / 
                        jsp.jobs.length * (parentHeight - 2 * marginY)
                      );
          double x2 = marginX + 
                      successorK.coordinates.x.toDouble() / 
                      jsp.nbMaxTasks * (parentWidth - 2 * marginX);
          double y2 = parentHeight - (
                        marginY + successorK.coordinates.y.toDouble() / 
                        jsp.jobs.length * (parentHeight - 2 * marginY)
                      );

          var startAdjustment =  taskJ.id == 0 ? - radius : 0;
          //var crossAdjustment =  taskJ.id < successorK.id ? - radius : radius;
          //if(startAdjustment != 0) crossAdjustment = 0;

          // Computing edge's curve 
          var norm = sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1));

          var unitVectorX = - (y2 - y1) / norm;
          var unitVectorY = (x2 - x1) / norm;

          var shift = norm * 0.1;
          //if(j1 < j2) shift = -1 * shift;
          if( taskJ.id == 0 ||
              taskJ.id - (taskJ.id % 100) == successorK.id - (successorK.id % 100) ){
            shift = 0;
          }

          Path path = Path();
          path.moveTo(x1, y1);
          path.quadraticBezierTo(
              (x1 + x2)/2 + unitVectorX * shift,
              (y1 + y2)/2 + unitVectorY * shift,
              x2 + startAdjustment,
              y2
          );

          //var p1 = Offset(x1 + crossAdjustment, y1);
          //var p2 = Offset(x2 + startAdjustment + crossAdjustment, y2);
          //canvas.drawLine(p1, p2, paint);

          canvas.drawPath(path, paint);
        }
      }
    }

  }

  @override
  bool shouldRepaint(PheromonePainterJSP old) {
    return true;
    //return old.pheromoneConcentrations != pheromoneConcentrations;
  }
}







//*******************************************************
// Legend painter (JSP)
//*******************************************************

class JSPLegendPainter extends CustomPainter { //         <-- CustomPainter class

  bool inLine = false;

  JSPLegendPainter({inLine = false}){
    this.inLine = inLine;
  }

  @override
  void paint(Canvas canvas, Size size) {

    var marginX = 0.1 * size.width;
    var marginY = 0.1 * size.height;
    var radius = 10.0;

    // PAINT TASKS
    for(int i=1; i<jsp.jobs.length; i++) {
      var paint = Paint()
        ..color = AppData.jspJobColors[i] //Colors.teal
        ..style = PaintingStyle.fill;

      var x, y;
      if(inLine){
        x = i * (2 * radius) + (i-1) * 50;
        y = size.height/2;
      }
      else { // = in Column
        x = 20.0;
        y = i * (2 * radius + 5);
      }

      canvas.drawCircle(Offset(x, y), radius, paint);

      String str = 'Job $i';
      TextSpan span = new TextSpan(
        style: AppData.regularTextStyle,
        text: str,
      );
      final textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainter.paint(canvas, Offset(x + radius + 10, y - 10));
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}





//*******************************************************
// Schedule painter
//*******************************************************
class SchedulePainter extends CustomPainter { //         <-- CustomPainter class
  var canvas;

  List<List<Task>> schedule;
  var parentWidth;
  var parentHeight;
  var marginX;
  var marginY;

  SchedulePainter({required this.schedule,});

  var radius = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    print('Best schedule');
    jobSchedulingACO.printSchedule(schedule);

    this.canvas = canvas;

    parentWidth = size.width;
    parentHeight = size.height;
    marginX = 0.1 * parentWidth;
    marginY = 0.1 * parentHeight;

    double graphHeight = parentHeight - 2 * marginY;
    double graphWidth = parentWidth - 2 * marginX;

    Paint paint = Paint();

    var firstScheduleLength = jobSchedulingACO.computeSolutionLength(
        jobSchedulingACO.bestScheduleRecord.first
    );

    // PAINT TASKS
    for(int machine=0; machine<schedule.length; machine++){
      var currentX = 0.0;
      for(int task=0; task<schedule[machine].length; task++){
        var taskId = schedule[machine][task].id;
        var duration = schedule[machine][task].duration;

        var job = ((taskId - taskId % 100) / 100).floor();

        // Translate to help panel coordinates
        var x = marginX + currentX;
        var y = parentHeight - (marginY + (machine+1) / (schedule.length) * graphHeight);
        var width = duration / firstScheduleLength * graphWidth;
        var height = ( 1 / (schedule.length) * graphHeight );

        currentX += width;

        if (taskId <= 0)
          paint.color = Colors.white;
        else
          paint.color = AppData.jspJobColors[job];

        //print("(x $x, y $y)");
        //print("(w $width, h $height)");
        //print("");

        canvas.drawRect(Offset(x, y) & Size(width, height), paint);
      }
    }

    // PAINT AXES
    var path = Path();

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    paint.color = Colors.black;

    path.moveTo(marginX, parentHeight - marginY);
    path.lineTo(marginX + graphWidth + 30, parentHeight - marginY);
    path = ArrowPath.make(path: path);
    canvas.drawPath(path, paint);

    path.moveTo(marginX, parentHeight - marginY);
    path.lineTo(marginX, parentHeight - (marginY + graphHeight + 30));
    path = ArrowPath.make(path: path);
    canvas.drawPath(path, paint);

    // PAINT AXES GRADUATION
    for(int i=1; i<=firstScheduleLength; i++){
      var p1 = Offset(marginX + i / firstScheduleLength * graphWidth, parentHeight - (marginY - 5));
      var p2 = Offset(marginX + i / firstScheduleLength * graphWidth, parentHeight - (marginY + 5));
      canvas.drawLine(p1, p2, paint);
    }

    // PAINT TEXT
    for(int i=0; i<schedule.length; i++) {
      String str = 'M$i';
      TextSpan span = new TextSpan(style: AppData.regularTextStyle, text: str);
      final textPainter = TextPainter(text: span, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: size.width );

      var x = marginX - 40;
      var y =  parentHeight -
          (marginY + (i + 1) / schedule.length * graphHeight) +
          (0.25 / schedule.length * graphHeight);

      textPainter.paint(canvas, Offset(x, y));
    }

    // X axis legend
    String str = 'Duration';
    TextSpan span = new TextSpan(style: AppData.regularTextStyle, text: str);
    var textPainter = TextPainter(text: span, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);

    var x = marginX + graphWidth/2 - 25;
    var y =  parentHeight - (marginY - 20);

    textPainter.paint(canvas, Offset(x, y));
  }



  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}





//*******************************************************
// Legend painter (TSP)
//*******************************************************

class TSPLegendPainter extends CustomPainter { //         <-- CustomPainter class
  @override
  void paint(Canvas canvas, Size size) {

    var marginX = 0.1 * size.width;
    var marginY = 0.1 * size.height;
    var radius = 10.0;

    // PAINT TASKS
    var paint = Paint()
      ..color = Colors.teal //Colors.teal
      ..style = PaintingStyle.fill;

    var x = 20.0;
    var y = 5.0 + 2 * radius;
    canvas.drawCircle(Offset(x, y), radius, paint);

    String str = 'Cities';
    TextSpan span = new TextSpan(style: AppData.regularTextStyle, text: str);
    var textPainter = TextPainter(text: span, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, Offset(x + radius + 10, y - 10));

    paint.color = Colors.amber.shade800;
    x = 20;
    y += 2 * radius;
    canvas.drawCircle(Offset(x, y), radius / 2, paint);

    str = 'Ants';
    span = new TextSpan(style: AppData.regularTextStyle, text: str);
    textPainter = TextPainter(text: span, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, Offset(x + radius + 10, y - 10));
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}


