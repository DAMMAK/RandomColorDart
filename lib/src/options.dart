import 'package:flutter_randomcolor/flutter_randomcolor.dart';

class Options {
  final dynamic colorType;
  final Luminosity luminosity;
  final Format format;
  final double? alpha;
  final int count;
  final int? seed;

  Options({
    this.colorType = ColorType.random,
    this.luminosity = Luminosity.random,
    this.format = Format.rgb,
    this.alpha,
    this.count = 1,
    this.seed,
  });
}

enum Format { rgba, rgb, rgbArray, hsla, hex, hsl, hsva, hsvArray, hslArray }
