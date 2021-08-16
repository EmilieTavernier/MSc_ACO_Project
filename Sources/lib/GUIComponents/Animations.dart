import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

import '../appStaticData.dart';
import "Painters.dart";

// Class defining animation for ants movements
class AnimatedItemWidget extends AnimatedWidget {
  AnimatedItemWidget({Key? key,
    required Animation<double> animation,
    required this.x, required this.y,
    required this.targetedX, required this.targetedY})
      : super(key: key, listenable: animation);

  final double x;
  final double y;
  final double targetedX;
  final double targetedY;

  Widget build(BuildContext context) {
    final _xTween = Tween<double>(begin: x, end: targetedX);
    final _yTween = Tween<double>(begin: y, end: targetedY);
    //final _JSPTween = Tween<double>(begin: 0.0, end: 2.0);


    final animation = listenable as Animation<double>;

    var customPainter;
    if(AppState.selectedProblem == Problem.JSP){

      var radius = 10.0;
      //var adjustment =  y < targetedY ? - radius : radius;
      var adjustment = 0.0;
      // If x,y correspond to departure tasks... 
      if( x == jsp.jobs[0].tasks[0].coordinates.x &&
          y == jsp.jobs[0].tasks[0].coordinates.y ){
        // ... We need a small adjustements to follow graph edges
        adjustment = -radius;
      }

      customPainter = CirclePainterJSP(
        x: x, // _xTween.evaluate(animation),
        y: y, // _yTween.evaluate(animation),
        targetedX: targetedX,
        targetedY: targetedY,
        value: animation.value,
        adjustment: adjustment,
      );
    }
    else if(AppState.selectedProblem == Problem.edgeDetection){
      customPainter = CirclePainterEdgeDetection(
        x: _xTween.evaluate(animation),
        y: _yTween.evaluate(animation),
      );
    }
    else{ // if problem == TSP
      customPainter = CirclePainter(
        x: _xTween.evaluate(animation),
        y: _yTween.evaluate(animation),
      );
    }

    return CustomPaint( //CustomPaint widget
        size: const Size(double.infinity, double.infinity),
        painter: customPainter,
    );
  }
}
