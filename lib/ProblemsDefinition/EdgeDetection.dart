import 'dart:math';
import 'package:image/image.dart' as Img;

import '../appStaticData.dart';

class EdgeDetection {
  var pixels = <Pixel>[];
  int maxIntensityVariation = 0;

  EdgeDetection(){
    if(AppState.selectedImage.bytes.isEmpty) return;

    // Convert the image to gray scale
    Img.Image? image = Img.decodeNamedImage(AppState.selectedImage.bytes, AppState.selectedImage.name);
    if(image == null) return;

    Img.Image grayScaleImg = Img.grayscale(image);
    List<int> processedImg = Img.encodeNamedImage(grayScaleImg, AppState.selectedImage.name)!;
    AppState.selectedImage.bytes = processedImg; //result.readAsBytesSync());

    AppState.selectedImage.width = grayScaleImg.width;
    AppState.selectedImage.height = grayScaleImg.height;

    // Create graph suitable for ACO
    for(int i=0; i<grayScaleImg.length; i++){
      pixels.add(new Pixel());
      int x = i % grayScaleImg.width;
      int y = (i / grayScaleImg.width).floor();

      pixels[i].coordinates = Point(x, y);
      pixels[i].index = i;
      pixels[i].value = grayScaleImg.getPixel(x, y);
    }
    for(int i=0; i<grayScaleImg.length; i++){
      int x = i % grayScaleImg.width;
      int y = (i / grayScaleImg.width).floor();

      // Order is relevant for next intensityVariation computation do not change it
      int v0 = 0, v1 = 0, v2 = 0, v3 = 0, v4 = 0, v5 = 0, v6 = 0, v7 = 0;

      if(x > 0 && y > 0) {
        pixels[i].neighbours.add( pixels[(y - 1) * grayScaleImg.width + (x - 1)]); // [x-1, y-1]
        v0 = pixels[i].neighbours.last.value;
      }
      else v0 = pixels[i].value;
      if(x < grayScaleImg.width - 1 && y < grayScaleImg.height - 1) {
        pixels[i].neighbours.add( pixels[(y+1) * grayScaleImg.width + (x+1)] ); // [x+1, y+1]
        v1 = pixels[i].neighbours.last.value;
      }
      else v1 = pixels[i].value;
      if(x > 0) {
        pixels[i].neighbours.add( pixels[y * grayScaleImg.width + (x-1)] );     // [x-1, y]
        v2 = pixels[i].neighbours.last.value;
      }
      else v2 = pixels[i].value;
      if(x < grayScaleImg.width - 1) {
        pixels[i].neighbours.add( pixels[y * grayScaleImg.width + (x+1)] );     // [x+1, y]
        v3 = pixels[i].neighbours.last.value;
      }
      else v3 = pixels[i].value;
      if(x > 0 && y < grayScaleImg.height - 1) {
        pixels[i].neighbours.add( pixels[(y+1) * grayScaleImg.width + (x-1)] ); // [x-1, y+1]
        v4 = pixels[i].neighbours.last.value;
      }
      else v4 = pixels[i].value;
      if(x < grayScaleImg.width - 1 && y > 0) {
        pixels[i].neighbours.add( pixels[(y-1) * grayScaleImg.width + (x+1)] ); // [x+1, y-1]
        v5 = pixels[i].neighbours.last.value;
      }
      else v5 = pixels[i].value;
      if(y > 0) {
        pixels[i].neighbours.add( pixels[(y-1) * grayScaleImg.width + x] );     // [x, y-1]
        v6 = pixels[i].neighbours.last.value;
      }
      else v6 = pixels[i].value;
      if(y < grayScaleImg.height - 1) {
        pixels[i].neighbours.add( pixels[(y + 1) * grayScaleImg.width + x] ); // [x, y+1]
        v7 = pixels[i].neighbours.last.value;
      }
      else v7 = pixels[i].value;
      Pixel p = pixels[i];

      pixels[i].intensityVariation =
        (v0 - v1).abs() +
        (v2 - v3).abs() +
        (v4 - v5).abs() +
        (v6 - v7).abs();

      if(pixels[i].intensityVariation > maxIntensityVariation)
        maxIntensityVariation = pixels[i].intensityVariation;
    }
  }
}

class Pixel {
  late Point coordinates;
  late int index;
  late int value;
  late int intensityVariation;
  double pheromoneValue = 0.0;
  var neighbours = <Pixel>[];

  //Point coordinates = Point(0,0);
  //int value = 0;
  //int intensityVariation = 0;
}