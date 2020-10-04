import 'package:randomcolor/src/colortype.dart';
import 'package:randomcolor/src/luminos.dart';

class Options {
  final ColorType colorType;
  final Luminosity luminosity;
  final Format format;
  final double alpha;
  final int count;

  Options({
    this.colorType,
    this.luminosity,
    this.format,
    this.alpha,
    this.count,
  });
}

enum Format { rgba, rgb, rgbArray, hsla, hex, hsl, hsva, hsvArray, hslArray }
