// https://pub.dev/packages/filepicker_windows (BSD license)
import 'package:filepicker_windows/filepicker_windows.dart';

import '../appStaticData.dart';

Future openFilePicker() async {
  final file = OpenFilePicker()
    ..filterSpecification = {
      'Images (*.PNG; *.png; *JPEG; *jpeg; *JPG; *jpg)':
      '*.PNG; *.png; *JPEG; *jpeg; *JPG; *jpg',
    }
    ..defaultFilterIndex = 0
  //..defaultExtension = 'doc'
    ..title = 'Select a document';

  final result = file.getFile();
  if (result != null) {
    AppState.selectedImage.bytes = result.readAsBytesSync().toList();
    AppState.selectedImage.name = result.path;

    return result.path;
  }
}