import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class Colorly {
  List<String> sources = ['asset', 'network', 'memory'];

  String source = "asset";

  Colorly from( String source /*imageProviderSource*/) {
    assert(
      sources.contains(source), 
      "Source '$source' is not supported as a provider!"
    );

    this.source = /**/ source;

    return this;
  }

  Colorly fromAsset () {  // creating image from assets
    source = 'asset';
    return this;
  }
  
  Colorly fromNetwork() { // creating image from network
    source = 'network';
    return this;
  }

  Colorly fromMemory() {  // creating image from memory
    source = 'memory';
    return this;
  }

  Future<dynamic> get(dynamic imageSource) async /* */ {
    ImageProvider? imageProvider;
    Color color(
      Color? color
    ) => color ?? Color (0XFF000000);  //default color

    switch(source){
      case 'asset':
          imageProvider = ( AssetImage  (imageSource) );
        break;
      case 'network':
          imageProvider = ( NetworkImage(imageSource) );
        break;
      case 'memory':
          imageProvider = ( MemoryImage (imageSource) );
        break;
    }

    PaletteGenerator palette = await PaletteGenerator
    .fromImageProvider(
      imageProvider!
    );

    Map swatches = {
      'primary' : palette.dominantColor?.color, //sw: 1

      'secondary' : palette.mutedColor?.color , //sw: 2
      'secondaryDark' : palette.darkMutedColor?.color,
      'secondaryLight' : palette.lightMutedColor?.color,

      'vibrant' : palette.vibrantColor?.color , //sw: 3
      'vibrantDark' : palette.darkVibrantColor?.color,
      'vibrantLight' : palette.lightVibrantColor?.color,
    };

    /*
    * Iterate through all swatches and cast null colors
    * In the case color is null. It fallbacks to: BLACK
    */
    swatches.updateAll((key, value) => (color(value)));

    return swatches;

  }

}