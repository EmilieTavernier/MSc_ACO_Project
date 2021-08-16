import 'dart:math';

// This class holds the definition of JSP problem
class JSP {
  var jobs = <Job>[];
  var nbMaxTasks = 0; // Max number of tasks composing a job
  var maxMachine = 0; // Max machine number.

  // Constructor accept user input parameters (list of jobs description)
  // A job description a list of tasks defined as follow: (task1_machine, task1_duration);(t2_machine, t2_duration)...
  // Example: (0,4);(2,5);(2;1)
  JSP(List<String> jobsDescription){
    if(jobsDescription.isEmpty) return;
    //print('jobsDescription: $jobsDescription');

    RegExp exp = new RegExp(r"\d+"); // Regex to match integers

    // Define departure node (dummy job)
    Job start = new Job();
    start.tasks.add(new Task(-1, 0, Point(0, (jobsDescription.length+1)/2), 0));
    jobs.add(start);

    // DEFINE JOBS AND THEIR TASKS
    for(int i=0; i<jobsDescription.length; i++){
      Job job = new Job();
      var tasksDescription = exp.allMatches(jobsDescription[i]).toList();

      for(int j=0; j<tasksDescription.length; j+=2){
        // j+=2 -> integer at j = machine; integer a j+1 = duration
        int machine = int.parse(tasksDescription[j].group(0)!);
        int duration = int.parse(tasksDescription[j+1].group(0)!);
        int id = jobs.length * 100 + job.tasks.length;
        // Example: Job 2 task 1 id is 201
        // This allow a maximum of 99 tasks (limited to 9 in job description input field)

        job.tasks.add(new Task(machine, duration, Point(j/2+1, i+1), id));
        if(machine > maxMachine) maxMachine = machine;
      }
      if(job.tasks.length > nbMaxTasks) nbMaxTasks = job.tasks.length;
      jobs.add(job);
    }

    // DEFINE SUCCESSORS
    for(int k=1; k<jobs.length; k++){
      jobs[0].tasks[0].successors.add(jobs[k].tasks[0]);
    }
    for(int i=1; i<jobs.length; i++){
      for(int j=0; j<jobs[i].tasks.length; j++){
        if(j<jobs[i].tasks.length-1) {
          // same job successors
          jobs[i].tasks[j].successors.add(jobs[i].tasks[j + 1]);
        }
        for(int k=1; k<jobs.length; k++){
          for(int m=0; m<jobs[k].tasks.length; m++) {
            if (i != k ) {
              // cross job successors
              jobs[i].tasks[j].successors.add(jobs[k].tasks[m]);
            }
          }
        }
      }
    }
  }
}

// Definition of a job...
class Job {
  // .. is just a list of tasks
  var tasks = <Task>[];
}

// Definition of a task
class Task {
  late int machine;
  late int duration;
  late Point coordinates; // for visual representation
  late var id; 
  // ID example: Job 2 task 1 ID is 201
  // This allows a maximum of 99 tasks (limited to 9 in job description input field)

  List<Task> successors = [];
  List<double> pheromonesConcentration = []; // Pheromones on edge (Task-successor)

  // Constructor 
  Task(machine, duration, coordinates, id){
    this.machine = machine;
    this.duration = duration;
    this.coordinates = coordinates;
    this.id = id;
  }
}
