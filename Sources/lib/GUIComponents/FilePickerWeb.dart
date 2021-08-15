// https://pub.dev/packages/file_picker (MIT license):
import 'package:file_picker/file_picker.dart';

import '../appStaticData.dart';

Future openFilePicker() async {
  var picked =
  await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:  ['PNG', 'png', 'JPEG', 'jpeg', 'JPG', 'jpg']
  );
  if (picked != null) {
    // https://stackoverflow.com/questions/65420592/flutter-web-file-picker-throws-invalid-arguments-path-must-not-be-null-e
    //AppState.selectedImage = Image.memory(picked.files.single.bytes!);
    AppState.selectedImage.bytes = picked.files.single.bytes!.toList();
    AppState.selectedImage.name = picked.files.single.name;

    // Remark: File path is not supported on web device
    return picked.files.single.name;
  }
}