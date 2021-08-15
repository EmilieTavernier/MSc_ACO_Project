import 'dart:collection';

import '../ProblemsDefinition/JSP.dart';

class Ant {
  var previousNode = 0;
  var currentNode = 0;
  List<int> solution = [];
  List<List<Task>> schedule = []; // JSP Specific
  HashSet<int> solutionHashSet = HashSet.of([]);
  var solutionLength;
}