import 'package:flutter/material.dart';

import "../appStaticData.dart";
import "Buttons.dart";

class ControlBar extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      builder: (BuildContext context, int value, Widget? child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ControlButton(
              icon: Icon(Icons.stop),
              action:
              AppState.performingACO ? AppState.stop : null, topRightRadius: 0,
              topLeftRadius: 1,
              bottomRightRadius: 0,
              bottomLeftRadius: 1
            ),
            ControlButton(
              icon: Icon(Icons.pause),
              action: (AppState.performingACO && !AppState.paused) ? AppState.pause : null,
              topRightRadius: 0,
              topLeftRadius: 0,
              bottomRightRadius: 0,
              bottomLeftRadius: 0
            ),
            ControlButton(
              icon: Icon(Icons.play_arrow),
              action: (AppState.performingACO && AppState.paused) ? AppState.play : null,
              topRightRadius: 0,
              topLeftRadius: 0,
              bottomRightRadius: 0,
              bottomLeftRadius: 0
            ),
            ControlDropDown(
              topRightRadius: 1,
              topLeftRadius: 0,
              bottomRightRadius: 1,
              bottomLeftRadius: 0
            ),
          ],
        );
      },
      valueListenable: AppState.buttonsNotifier
    );
  }
}