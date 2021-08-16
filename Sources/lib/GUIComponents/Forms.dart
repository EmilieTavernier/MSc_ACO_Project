import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import "../appStaticData.dart";
import "Textfields.dart";
import "Buttons.dart";
import "Dropdowns.dart";

// By default we import the file picker for web
import "FilePickerWeb.dart"
// but if it is compiled on io or desktop we use windows file picker
    if (dart.library.io) "FilePickerWindows.dart";
// Can't do conditional import for windows (or desktop) specifically
// but io do the trick here (workaround)
// however, this solution limits cross platform portability to only web and windows

// ****************************************************************
// PROBLEM FORM
// ****************************************************************

class ProblemParamForm extends StatefulWidget {
  @override
  ProblemParamFormState createState() {
    return ProblemParamFormState();
  }
}

class ProblemParamFormState extends State<ProblemParamForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  final nbCitiesCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final jspDescriptionCtrl = TextEditingController();
  final nbJobCtrl = TextEditingController();

  FileSource? _fileSource = FileSource.sample;
  List<String> imagesSamplePaths = [];
  List<String> imagesSampleNames = [];

  @override
  Widget build(BuildContext context) {
    if (imagesSamplePaths.isEmpty) _initImages();

    var hintText = 'Image name';

    // Build a Form widget using the _formKey created above.
    return ValueListenableBuilder<int>(
      builder: (BuildContext context, int value, Widget? child) {
        nbCitiesCtrl.text = '10';
        if(jobsField.isEmpty) {
          nbJobCtrl.text = '3';
          updateJobsList(3);
        }
        return Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Problem parameters',
              style: AppData.sectionTitleStyle,
            ),

            // TSP related
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppState.selectedProblem != Problem.TSP
                    ? []
                    : [
                        SizedBox(height: 10.0),
                        CustomTextField(
                            width: 50,
                            controller: nbCitiesCtrl,
                            labelOut: 'Number of cities',
                            regex: RegExp(r'[0-9]'),
                            max: 99),
                      ]),

            // JSP related
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppState.selectedProblem != Problem.JSP
                    ? []
                    : [
                        SizedBox(height: 10.0),
                        CustomTextField(
                          width: 50,
                          controller: nbJobCtrl,
                          labelOut: 'Number of jobs (max 5)',
                          regex: RegExp(r'[1-5]'),
                          min: 1,
                          max: 5,
                          onChanged: (str) {
                            if(nbJobCtrl.text.isNotEmpty){
                              var nbJobs = int.parse(nbJobCtrl.text);
                              if(nbJobs > 5){
                                nbJobs = 5;
                                nbJobCtrl.text = '5';
                              }
                              updateJobsList(nbJobs);
                              AppState.updatePbForms();
                            }
                          }
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Jobs description '),
                            HelpButton(attachedHelp: AppData.helpJobDescription),
                          ]
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: jobsField,
                        )
                      ]),

            // Edge detection related
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppState.selectedProblem != Problem.edgeDetection
                    ? []
                    : [
                        SizedBox(height: 10.0),
                        Text('Choose image from: '),
                        Row(children: [
                          Radio<FileSource>(
                              value: FileSource.sample,
                              groupValue: _fileSource,
                              onChanged: (FileSource? value) {
                                setState(() {
                                  _fileSource = value;
                                  AppState.selectedSource = value;
                                  AppState.selectedImage.name = imagesSampleNames[0];
                                  AppState.updatePbForms();
                                  AppState.updateButtons();
                                });
                              }),
                          Text(
                            'Pre-selected sample',
                            style: AppData.defaultTextStyle,
                          ),
                        ]),
                        Row(children: [
                          Radio<FileSource>(
                            value: FileSource.computer,
                            groupValue: _fileSource,
                            onChanged: (FileSource? value) {
                              setState(() {
                                _fileSource = value;
                                AppState.selectedSource = value;
                                imageCtrl.text = hintText;
                                AppState.updatePbForms();
                                AppState.updateButtons();
                              });
                            },
                          ),
                          Text(
                            'File system',
                            style: AppData.defaultTextStyle,
                          ),
                        ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ValueListenableBuilder<int>(
                              builder: (BuildContext context, int value,
                                  Widget? child) {
                                if (AppState.selectedSource ==
                                    FileSource.computer) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 30,
                                        width: 230,
                                        child: TextFormField(
                                          enabled: false,
                                          controller: imageCtrl,
                                          //AppState.selectedImage ? AppState.selectedImage.path : '',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context).disabledColor,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: hintText,
                                            contentPadding: EdgeInsets.only(bottom: 15),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else
                                  return Dropdown(
                                    itemsList: imagesSampleNames,
                                    menu: DropMenu.imagesSample,
                                  );
                              },
                              valueListenable: AppState.pbFormsNotifier,
                            ),
                            ValueListenableBuilder<int>(
                              builder: (BuildContext context, int value, Widget? child) {
                                if (AppState.selectedSource == FileSource.computer) {
                                  return ElevatedButton(
                                    onPressed: AppState.performingACO ? null : () async {
                                      var filePath = await openFilePicker();
                                      if(filePath != null )
                                        imageCtrl.text = filePath.split('\\').last;
                                    },
                                    child: Icon(Icons.drive_folder_upload),
                                  );
                                }
                                else return SizedBox(
                                  width: 0,
                                  height: 0,
                                );
                              },
                              valueListenable: AppState.buttonsNotifier,
                            ),
                          ],
                        )
                      ]),

            SizedBox(height: 10.0),
            ValueListenableBuilder<int>(
              builder: (BuildContext context, int value, Widget? child) {
                return RectangularButton(
                    label: 'Generate',
                    action: AppState.performingACO
                        ? null
                        : () {
                            print('generate ${AppState.selectedProblem}');
                            if (AppState.selectedProblem == Problem.TSP)
                              AppState.generateProblem(nbCities: int.parse(nbCitiesCtrl.text));
                            else if (AppState.selectedProblem == Problem.JSP) {
                              List<String> str = [];
                              for(int i=0; i<jobsCtrl.length; i++)
                                str.add(jobsCtrl[i].text);
                              AppState.generateProblem(jobsDescription: str);
                            } else if (AppState.selectedProblem == Problem.edgeDetection) {
                              if (AppState.selectedSource == FileSource.sample)
                                _loadImage();
                              else
                                AppState.generateProblem();
                            }
                          },
                    formKey: _formKey);
              },
              valueListenable: AppState.buttonsNotifier,
            ),
          ]),
        );
      },
      valueListenable: AppState.pbFormsNotifier,
    );
  }

  // Edge detection specific method to load selected image (only if image is from app sample, no need if the user passed by the file picker)
  _loadImage() async {
    var name = AppState.selectedImage.name;
    var path = imagesSamplePaths[imagesSampleNames.indexOf(name)];
    ByteData bytes = await rootBundle.load(path);
    final buffer = bytes.buffer;
    AppState.selectedImage.bytes =
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes).toList();
    AppState.selectedImage.name = name; // useless

    AppState.generateProblem();
  }

  // Edge detection specific method to initialise an image if placeholder is empty
  Future _initImages() async {
    // >> To get paths you need these 2 lines
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('edgeDetectionSampleImages/'))
        .toList();

    setState(() {
      imagesSamplePaths = imagePaths;
      imagesSampleNames =
          imagePaths.map((path) => path.split('/').last).toList();
    });
  }

  // JSP Specific method to update job description fields
  void updateJobsList(nbJobs){
    var defaultJobsDescription = ['(0,3);(1,2);(2,2)', '(0,2);(2,1);(1,4)', '(1,4);(2,3)']; // Pre-filled default job description

    if (nbJobs > jobsField.length) { // add fields to match number of job input field value
      while (jobsField.length < nbJobs) { 
        jobsCtrl.add(TextEditingController());

        if(jobsField.length < 3) // If we have three fields, use default pre-filled values
          jobsCtrl.last.text = defaultJobsDescription[jobsField.length];

        jobsField.add( 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                CustomTextField(
                  width: 200,
                  labelOut: 'Job ${jobsCtrl.length}',
                  controller: jobsCtrl.last,
                  regex: RegExp(r'[0-9;,\(\)]'),
                  max: 99,
                ),
              ],
            )
        );
      }
    }
    else { // Remove fields to match number of job input field value
      while (jobsField.length > nbJobs) {
        jobsCtrl.removeLast();
        jobsField.removeLast();
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nbCitiesCtrl.dispose();
    super.dispose();
  }
}

// ****************************************************************
// AS FORM
// ****************************************************************

class ACOParamForm extends StatefulWidget {
  @override
  ACOParamFormState createState() {
    return ACOParamFormState();
  }
}

class ACOParamFormState extends State<ACOParamForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  final nbAntsCtrl = TextEditingController();
  final nbIterationsCtrl = TextEditingController();
  final pheromoneInitCtrl = TextEditingController();
  final evaporationRateCtrl = TextEditingController();
  final alphaCtrl = TextEditingController();
  final betaCtrl = TextEditingController();
  final qCtrl = TextEditingController();

  // MMAS specific
  final pheromoneMaxCtrl = TextEditingController();
  final pheromoneMinCtrl = TextEditingController();
  BestAnt? _bestAnt = BestAnt.globalBest;

  // ACS specific
  final q0Ctrl = TextEditingController();
  final pheromoneDecayCtrl = TextEditingController();

  // Edge detection specific
  final nbConstructionStepCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return ValueListenableBuilder<int>(
      builder: (BuildContext context, int value, Widget? child) {
        // Pre-filled default input values (choose in regards to performances and demonstration clarity)
        nbAntsCtrl.text = '20';
        nbIterationsCtrl.text = '10';
        nbConstructionStepCtrl.text = '40';
        pheromoneInitCtrl.text = '0.1';
        evaporationRateCtrl.text = '0.5';
        alphaCtrl.text = '1';
        betaCtrl.text = '1';
        qCtrl.text = '1';
        pheromoneMaxCtrl.text = '10';
        pheromoneMinCtrl.text = '0.5';
        q0Ctrl.text = '0.1';
        pheromoneDecayCtrl.text = '0.5';
        if(AppState.selectedProblem == Problem.JSP) { // for JSP
          nbAntsCtrl.text = '5';
        }
        if (AppState.selectedProblem == Problem.edgeDetection) { // for Edge detection
          nbAntsCtrl.text = '512';
          nbIterationsCtrl.text = '20';
          nbConstructionStepCtrl.text = '40';
          pheromoneInitCtrl.text = '0.1';
          alphaCtrl.text = '1';
          betaCtrl.text = '1';
          pheromoneDecayCtrl.text = '0.05';
          evaporationRateCtrl.text = '0.1';
        }

        return Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Algorithm parameters',
              style: AppData.sectionTitleStyle,
            ),
            SizedBox(height: 10.0),
            CustomTextField(
                width: 50,
                controller: nbAntsCtrl,
                labelOut: 'Number of ants',
                regex: RegExp(r'[0-9]'),
                max: 999),
            SizedBox(height: 10.0),
            CustomTextField(
                width: 50,
                controller: nbIterationsCtrl,
                labelOut: 'Number of iterations',
                regex: RegExp(r'[0-9]'),
                max: 999),

            // Edge Detection specific
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppState.selectedProblem != Problem.edgeDetection
                    ? []
                    : [
                        SizedBox(height: 10.0),
                        CustomTextField(
                            width: 50,
                            controller: nbConstructionStepCtrl,
                            labelOut: 'Number of construction steps',
                            regex: RegExp(r'[0-9]'),
                            max: 999),
                      ]),

            // MMAS & ACS specific
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppState.selectedAlgo != Algorithm.MMAS &&
                        (AppState.selectedAlgo != Algorithm.ACS ||
                            AppState.selectedProblem == Problem.edgeDetection)
                    ? []
                    : [
                        SizedBox(height: 10.0),
                        Text('Pheromone update by: '),
                        Row(children: [
                          Radio<BestAnt>(
                              value: BestAnt.globalBest,
                              groupValue: _bestAnt,
                              onChanged: (BestAnt? value) {
                                setState(() {
                                  _bestAnt = value;
                                });
                              }),
                          Text(
                            'global best',
                            style: AppData.defaultTextStyle,
                          ),
                          SizedBox(width: 60.0),
                          Radio<BestAnt>(
                            value: BestAnt.iterationBest,
                            groupValue: _bestAnt,
                            onChanged: (BestAnt? value) {
                              setState(() {
                                _bestAnt = value;
                              });
                            },
                          ),
                          Text(
                            'iteration best',
                            style: AppData.defaultTextStyle,
                          ),
                        ]),
                      ]),

            // MMAS specific
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppState.selectedAlgo != Algorithm.MMAS
                    ? []
                    : [
                        SizedBox(height: 10.0),
                        CustomTextField(
                            width: 50,
                            controller: pheromoneMaxCtrl,
                            labelOut: 'Pheromone upper bound',
                            regex: RegExp(r'[0-9.]'),
                            max: 99),
                        SizedBox(height: 10.0),
                        CustomTextField(
                            width: 50,
                            controller: pheromoneMinCtrl,
                            labelOut: 'Pheromone lower bound',
                            regex: RegExp(r'[0-9.]'),
                            max: 99),
                      ]),

            // ACS specific
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppState.selectedAlgo != Algorithm.ACS &&
                        AppState.selectedProblem != Problem.edgeDetection &&
                        AppState.selectedProblem != Problem.JSP
                    ? []
                    : [
                        SizedBox(height: 10.0),
                        CustomTextField(
                            width: 50,
                            controller: pheromoneDecayCtrl,
                            labelOut: 'Pheromone decay',
                            regex: RegExp(r'[0-9.]'),
                            max: 1,
                            min: 0.01),
                        if (AppState.selectedProblem != Problem.edgeDetection)
                          SizedBox(height: 10.0),
                        if (AppState.selectedProblem != Problem.edgeDetection)
                          CustomTextField(
                            width: 50,
                            controller: q0Ctrl,
                            labelOut: 'q0',
                            regex: RegExp(r'[0-9.]'),
                            max: 1,
                          ),
                      ]),

            // AS, ASC common fields
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppState.selectedAlgo == Algorithm.MMAS
                    ? []
                    : [
                        SizedBox(height: 10.0),
                        CustomTextField(
                          width: 50,
                          controller: pheromoneInitCtrl,
                          labelOut: 'Pheromone initial value',
                          regex: RegExp(r'[0-9.]'),
                          max: 99,
                        ),
                      ]),

            // AS, MMAS and ASC common fields
            SizedBox(height: 10.0),
            CustomTextField(
                width: 50,
                controller: evaporationRateCtrl,
                labelOut: 'Evaporation rate',
                regex: RegExp(r'[0-9.]'),
                max: 0.99),
            SizedBox(height: 10.0),
            CustomTextField(
                width: 50,
                controller: alphaCtrl,
                labelOut: 'alpha',
                regex: RegExp(r'[0-9.]'),
                max: 99),
            SizedBox(height: 10.0),
            CustomTextField(
                width: 50,
                controller: betaCtrl,
                labelOut: 'beta',
                regex: RegExp(r'[0-9.]'),
                max: 99),

            // AS specific
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppState.selectedAlgo != Algorithm.AS
                    ? []
                    : [
                        SizedBox(height: 10.0),
                        CustomTextField(
                            width: 50,
                            controller: qCtrl,
                            labelOut: 'Q',
                            regex: RegExp(r'[0-9.]'),
                            max: 99),
                      ]),

            SizedBox(height: 10.0),
            Row(children: [
              ValueListenableBuilder<int>(
                builder: (BuildContext context, int value, Widget? child) {
                  return RectangularButton(
                      label: 'Start',
                      // If we are currently performing a demonstration, the button is disabled
                      action: AppState.performingACO
                          ? null
                          : () {
                              /*
                            print('validator return: ${_formKey.currentState!.validate()}');
                            if(!_formKey.currentState!.validate()){
                              showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => AlertInput()
                              );
                            }
                            else {
                            */
                              AppState.selectedBest = _bestAnt;

                              // If algorithm is MMAS or ASC: Q = 1
                              // else if algorithm is AS: Q = user input
                              var Q = AppState.selectedAlgo != Algorithm.AS
                                  ? '1'
                                  : qCtrl.text;

                              AppState.launchDemonstration(
                                  int.parse(nbAntsCtrl.text),
                                  int.parse(nbIterationsCtrl.text),
                                  AppState.selectedProblem ==
                                          Problem.edgeDetection
                                      ? int.parse(nbConstructionStepCtrl.text)
                                      : 0,
                                  double.parse(pheromoneInitCtrl.text),
                                  double.parse(evaporationRateCtrl.text),
                                  double.parse(alphaCtrl.text),
                                  double.parse(betaCtrl.text),
                                  double.parse(Q),
                                  AppState.selectedAlgo == Algorithm.MMAS
                                      ? double.parse(pheromoneMaxCtrl.text)
                                      : null,
                                  AppState.selectedAlgo == Algorithm.MMAS
                                      ? double.parse(pheromoneMinCtrl.text)
                                      : null,
                                  AppState.selectedAlgo == Algorithm.ACS
                                      ? double.parse(pheromoneDecayCtrl.text)
                                      : null,
                                  AppState.selectedAlgo == Algorithm.ACS
                                      ? double.parse(q0Ctrl.text)
                                      : null);
                              //}
                            },
                      formKey: _formKey);
                },
                valueListenable: AppState.buttonsNotifier,
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // reinitialized fields value
                  AppState.updateAlgoForms();
                },
                child: Text('Reinitialize', style: AppData.rectangularBtnStyle),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // <-- Radius
                  ),
                ),
              ),
            ]),
          ]),
        );
      },
      valueListenable: AppState.algoFormsNotifier,
    );
  }
}
