import 'package:flutter/material.dart';

import "../appStaticData.dart";
import 'PopUp.dart';

class Dropdown extends StatefulWidget {
  Dropdown({Key? key, required this.itemsList, required this.menu}) : super(key: key);

  var itemsList = <String>[];
  late DropMenu menu;

  @override
  State<Dropdown> createState() => _Dropdown(itemsList, menu);
}

class _Dropdown extends State<Dropdown> {
  var itemsList = <String>[];
  late DropMenu menu;
  String dropdownValue = '';

  _Dropdown(itemsList, menu){
    this.itemsList = itemsList;
    this.menu = menu;
    dropdownValue = itemsList[0];
  }

  @override
  Widget build(BuildContext context) {
    if( AppState.selectedProblem != Problem.TSP && menu == DropMenu.algoSlct){
      menu = DropMenu.shortAlgoSlct;
      itemsList = [AppData.acoVariantsList[2]];
      dropdownValue = itemsList[0];
      AppState.selectedAlgo = Algorithm.ACS;
    }
    else if ( AppState.selectedProblem == Problem.TSP && menu == DropMenu.shortAlgoSlct ){
      menu = DropMenu.algoSlct;
      itemsList = AppData.acoVariantsList;
      dropdownValue = itemsList[0];
      AppState.selectedAlgo = Algorithm.AS;
    }

    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: AppData.regularTextStyle,
      underline: Container(
        height: 2,
        color: Colors.teal,
      ),
      onChanged: AppState.performingACO || menu == DropMenu.shortAlgoSlct ?
          null : (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
            if( menu == DropMenu.algoSlct ) {
              AppState.selectedAlgo = Algorithm.values[itemsList.indexOf(newValue)];
              AppState.updateAlgoForms();
            }
            else if( menu == DropMenu.problemSlct ) {
              AppState.selectedProblem = Problem.values[itemsList.indexOf(newValue)];
              if ( AppState.selectedProblem == Problem.edgeDetection ||
                   AppState.selectedProblem == Problem.JSP ) {
                AppState.selectedAlgo = Algorithm.ACS;
              }
              AppState.updateDropDown();
              AppState.updateAlgoForms();
              AppState.updatePbForms();
              AppState.updateButtons();

              AppState.executionInfo = 'Press the button Generate in the section "Problem parameters" and then the button Start in "Algorithm selection" to launch a demonstration.';
              AppState.additionalInfo = '';
              AppState.updateExecutionInfo();
            }
            else if( menu == DropMenu.imagesSample ) {
              AppState.selectedImage.name = newValue;
            }
          });
        },
      items: itemsList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

  }
}