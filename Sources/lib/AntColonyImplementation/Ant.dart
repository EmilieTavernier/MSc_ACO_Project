import 'dart:collection';

import '../ProblemsDefinition/JSP.dart';

// This class defines an ant for all ACO implementations
class Ant {
  var previousNode = 0;
  var currentNode = 0;
  List<int> solution = []; // List of nodes id 
  List<List<Task>> schedule = []; // JSP Specific
  HashSet<int> solutionHashSet = HashSet.of([]); // for computation optimisation
  var solutionLength;
}
