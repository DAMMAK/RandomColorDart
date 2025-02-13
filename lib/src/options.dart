import 'package:flutter_randomcolor/flutter_randomcolor.dart';

/// Represents the configuration options for generating random colors.
class Options {
  /// Defines the type of color to generate.
  ///
  /// Defaults to [ColorType.random], which allows any type of color to be generated.
  final dynamic colorType;

  /// Specifies the luminosity level of the generated color.
  ///
  /// Defaults to [Luminosity.random], which means the luminosity can be any value.
  final Luminosity luminosity;

  /// Determines the format in which the generated color is returned.
  ///
  /// Defaults to [Format.rgb]. Other possible formats include RGBA, HSL, HEX, etc.
  final Format format;

  /// Specifies the alpha (transparency) value for the generated color.
  ///
  /// If set, it should be between 0.0 (fully transparent) and 1.0 (fully opaque).
  /// If not specified, the alpha value is determined by the chosen format.
  final double? alpha;

  /// Defines the number of colors to generate.
  ///
  /// Defaults to 1, meaning a single color will be generated.
  final int count;

  /// Optional seed value to generate deterministic random colors.
  ///
  /// If specified, the same seed will produce the same color output each time.
  final int? seed;

  /// Creates an instance of [Options] to configure random color generation.
  ///
  /// - [colorType]: Specifies the type of color (default: [ColorType.random]).
  /// - [luminosity]: Determines brightness level of the color (default: [Luminosity.random]).
  /// - [format]: Defines the output format of the color (default: [Format.rgb]).
  /// - [alpha]: Optional transparency level for the color.
  /// - [count]: Number of colors to generate (default: 1).
  /// - [seed]: Optional seed for reproducible colors.
  Options({
    this.colorType = ColorType.random,
    this.luminosity = Luminosity.random,
    this.format = Format.rgb,
    this.alpha,
    this.count = 1,
    this.seed,
  });
}

/// Defines the available output formats for generated colors.
enum Format {
  /// RGBA format (Red, Green, Blue, Alpha)
  rgba,

  /// RGB format (Red, Green, Blue)
  rgb,

  /// RGB as an array of integer values
  rgbArray,

  /// HSLA format (Hue, Saturation, Lightness, Alpha)
  hsla,

  /// HEX format (Hexadecimal color code)
  hex,

  /// HSL format (Hue, Saturation, Lightness)
  hsl,

  /// HSVA format (Hue, Saturation, Value, Alpha)
  hsva,

  /// HSV as an array of integer values
  hsvArray,

  /// HSL as an array of integer values
  hslArray,
}
