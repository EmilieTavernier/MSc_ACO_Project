import 'package:flutter/material.dart';

import "../appStaticData.dart";
import "PopUp.dart";

//***************************************************************
// Help Button (round "?")
//***************************************************************

// Usual help button (green round "?")
class HelpButton extends StatelessWidget {
  HelpButton({
    Key? key,
    required this.attachedHelp,
  }) : super(key: key);

  var attachedHelp;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        AppState.currentHelp = attachedHelp;
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => HelpPopUp()
        );
      },
      child: Text('?', style: AppData.helpButtonTextStyle),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
      ),
    );
  }
}

// Appbar help button (white round "?")
class IconHelpButton extends StatelessWidget {
  IconHelpButton({
    Key? key,
    required this.attachedHelp,
  }) : super(key: key);

  var attachedHelp;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      hoverColor: Colors.teal[600],
      splashRadius: 20,
      icon: Icon( Icons.help ),
      onPressed: () {
        AppState.currentHelp = attachedHelp;
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => HelpPopUp()
        );
      },
    );
  }
}

// Button in help panels top right corner (list icone)
class IconHomeButton extends StatelessWidget {
  IconHomeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.list,
        color: Colors.teal,
      ),
      splashRadius: 20,

      onPressed: () {
        AppState.currentHelp = AppData.helpIndex;
        AppState.updateHelp();
      },
    );
  }
}

// Button in help panels top right corner ("?" bubble icone)
class IconCreditButton extends StatelessWidget {
  IconCreditButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.contact_support,
        color: Colors.teal,
      ),
      splashRadius: 20,

      onPressed: () {
        AppState.currentHelp = AppData.helpCredits;
        AppState.updateHelp();
      },
    );
  }
}


//***************************************************************
// Rectangular Button
//***************************************************************

class RectangularButton extends StatelessWidget {
  const RectangularButton({
    Key? key, required this.label,
    this.action, required this.formKey
  }) : super(key: key);

  final String label;
  final Function()? action;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
      onPressed: action == null ? null : () {
        // Validate returns true if the form is valid, or false otherwise.
        if (formKey.currentState!.validate()) {
          // If the form is valid, do action
          action!();
        }
      },
      child: Text(label, style: AppData.rectangularBtnStyle),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // <-- Radius
        ),
      ),
    );
  }
}


//***************************************************************
// 'See Also' Button
//***************************************************************

// Buttons at the bottom of help panels in the section "see also"
class RectangularHelpButton extends StatelessWidget {
  RectangularHelpButton({
    Key? key, required this.label, required this.attachedHelp,
  }) : super(key: key);

  final String label;
  final Help attachedHelp;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        AppState.currentHelp = attachedHelp;
        AppState.updateHelp();
      },
      child: Text(label, style: AppData.rectangularBtnStyle),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // <-- Radius
        ),
      ),
    );
  }
}


//***************************************************************
// Control Button (play, pause, start)
//***************************************************************

// Control bar buttons under the demonstration area (STOP, PAUSE, PLAY)
class ControlButton extends StatelessWidget {
  const ControlButton({
    Key? key, required this.icon,
    this.action,
    required this.topRightRadius,
    required this.topLeftRadius,
    required this.bottomRightRadius,
    required this.bottomLeftRadius,
  }) : super(key: key);

  final Icon icon;
  final Function()? action;
  // 0 (no circular radius) or 1 (circular radius)
  final int topRightRadius;
  final int topLeftRadius;
  final int bottomRightRadius;
  final int bottomLeftRadius;

  @override
  Widget build(BuildContext context) {
    const double circularRadius = 8.0;

    return ElevatedButton(
      onPressed: action == null ? null : () {
        action!();
      },
      child: icon,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight:    Radius.circular( circularRadius * topRightRadius    ),
            topLeft:     Radius.circular( circularRadius * topLeftRadius     ),
            bottomRight: Radius.circular( circularRadius * bottomRightRadius ),
            bottomLeft:  Radius.circular( circularRadius * bottomLeftRadius  ),
          ),
        ),
      ),
    );
  }
}

// Control bar speed control dropdown (under the demonstration area)
class ControlDropDown extends StatefulWidget {
  ControlDropDown({
    Key? key,
    required this.topRightRadius,
    required this.topLeftRadius,
    required this.bottomRightRadius,
    required this.bottomLeftRadius,
  }) : super(key: key);

  final int topRightRadius;
  final int topLeftRadius;
  final int bottomRightRadius;
  final int bottomLeftRadius;

  @override
  State<ControlDropDown> createState() => _ControlDropDownState(
    topRightRadius: this.topRightRadius,
    topLeftRadius: this.topLeftRadius,
    bottomRightRadius: this.bottomRightRadius,
    bottomLeftRadius: this.bottomLeftRadius,
  );
}

class _ControlDropDownState extends State<ControlDropDown> {
  // 0 (no circular radius) or 1 (circular radius)
  final int topRightRadius;
  final int topLeftRadius;
  final int bottomRightRadius;
  final int bottomLeftRadius;

  var itemList = ['speed x0.5', 'speed x1.0', 'speed x2.0', 'speed x3.0', 'speed x5.0', 'speed x10.0'];
  String _selectedItem = '';

  _ControlDropDownState({
    required this.topRightRadius,
    required this.topLeftRadius,
    required this.bottomRightRadius,
    required this.bottomLeftRadius,
  }){
    _selectedItem = itemList[2];
  }

  @override
  Widget build(BuildContext context) {
    const double circularRadius = 8.0;

    if(AppState.selectedProblem == Problem.edgeDetection) {
      _selectedItem = itemList[2];
      var value = _selectedItem;
      var duration = 2.0 / double.parse( value.replaceAll(new RegExp(r'[^0-9.]'),'') );
      AppState.speedInMs = (duration * 1000).floor();
    }

    return Container(
      height: 28,
      child: ElevatedButton(
        onPressed: AppState.selectedProblem == Problem.edgeDetection ? null : () {},
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
              hint: Text(_selectedItem, style: AppData.rectangularBtnStyle),
              style: AppData.regularTextStyle,

              items: itemList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),

              onChanged: AppState.selectedProblem == Problem.edgeDetection ? null : (String? value) {
                setState(() {
                  _selectedItem = value!;
                  var duration = 2.0 / double.parse( value.replaceAll(new RegExp(r'[^0-9.]'),'') );
                  AppState.speedInMs = (duration * 1000).floor();
                  // controller.duration = Duration(milliseconds: AppState.speedInMs);
                });
              }
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight:    Radius.circular( circularRadius * topRightRadius    ),
              topLeft:     Radius.circular( circularRadius * topLeftRadius     ),
              bottomRight: Radius.circular( circularRadius * bottomRightRadius ),
              bottomLeft:  Radius.circular( circularRadius * bottomLeftRadius  ),
            ),
          ),
        ),
      ),
    );
  }
}
