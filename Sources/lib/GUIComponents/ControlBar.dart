import 'package:flutter/material.dart';

import "../appStaticData.dart";
import "Buttons.dart";

// Control bar definition (stop, pause, play and speed control buttons under the demonstration area)
class ControlBar extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      builder: (BuildContext context, int value, Widget? child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ControlButton( // STOP
              icon: Icon(Icons.stop),
              action:
              AppState.performingACO ? AppState.stop : null, topRightRadius: 0,
              topLeftRadius: 1,
              bottomRightRadius: 0,
              bottomLeftRadius: 1
            ),
            ControlButton( // PAUSE
              icon: Icon(Icons.pause),
              action: (AppState.performingACO && !AppState.paused) ? AppState.pause : null,
              topRightRadius: 0,
              topLeftRadius: 0,
              bottomRightRadius: 0,
              bottomLeftRadius: 0
            ),
            ControlButton( // PLAY
              icon: Icon(Icons.play_arrow),
              action: (AppState.performingACO && AppState.paused) ? AppState.play : null,
              topRightRadius: 0,
              topLeftRadius: 0,
              bottomRightRadius: 0,
              bottomLeftRadius: 0
            ),
            ControlDropDown( // SPEED CONTROL
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
