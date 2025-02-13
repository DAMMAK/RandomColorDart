/// A library for generating random colors in Flutter with customizable options.
/// Provides functionality to create colors in various formats including hex, RGB, HSL,
/// and Flutter's Color object.
library flutter_randomcolor;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:flutter_randomcolor/src/range.dart';

/// Main class for generating random colors with various customization options.
/// Provides methods to generate colors in different formats and with specific characteristics
/// such as hue, saturation, and brightness.
class RandomColor {
  /// Color dictionary that stores all the predefined color definitions
  /// Maps color types to their respective color definitions
  static Map<ColorType?, DefinedColor> _colorDictionary =
      Map<ColorType?, DefinedColor>();

  /// Random number generator used for color generation
  /// Can be seeded for reproducible results
  static math.Random _random = math.Random();

  /// Generates random colors based on provided options.
  ///
  /// [options] - Configuration options for color generation including:
  ///   - seed: Optional seed for reproducible colors
  ///   - count: Number of colors to generate
  ///   - format: Desired output format (hex, rgb, hsl, etc.)
  ///   - luminosity: Brightness preference
  ///   - colorType: Specific color family to generate from
  ///
  /// Returns either a single color or list of colors depending on the count option.
  static getColor(Options options) {
    __loadColorBounds();
    if (options.seed != null) {
      seed(options.seed!);
    }
    if (options.count < 2) return _pick(options);
    var colors = [];
    for (var i = 0; i < options.count; i++) {
      var _color = _pick(options);
      colors.add(_color);
    }
    return colors;
  }

  /// Converts the generated color to a Flutter Color object.
  ///
  /// [options] - Standard color generation options
  ///
  /// Returns a Flutter Color object that can be directly used in Flutter widgets.
  static Color getColorObject(Options options) {
    var colorString = getColor(options);
    return _convertToColor(colorString);
  }

  /// Converts various color format representations to a Flutter Color object.
  ///
  /// [color] - Can be:
  ///   - Hex string (e.g., "#FF0000")
  ///   - RGB string (e.g., "rgb(255,0,0)")
  ///   - HSL string (e.g., "hsl(0,100%,50%)")
  ///   - List of RGB values
  ///   - Flutter Color object
  ///
  /// Returns a Flutter Color object.
  /// Throws ArgumentError if the color format is not supported.
  static Color _convertToColor(dynamic color) {
    if (color is Color) {
      return color;
    } else if (color is String) {
      if (color.startsWith('#')) {
        return Color(int.parse('0xFF${color.substring(1)}'));
      } else if (color.startsWith('rgb')) {
        var rgbValues = color
            .replaceAll(RegExp(r'[rgba\(\)]'), '')
            .split(',')
            .map((e) => int.parse(e.trim()))
            .toList();
        return Color.fromRGBO(rgbValues[0], rgbValues[1], rgbValues[2],
            rgbValues.length > 3 ? double.parse(rgbValues[3] as String) : 1.0);
      } else if (color.startsWith('hsl')) {
        var hslValues = color
            .replaceAll(RegExp(r'[hsla\(\)%]'), '')
            .split(',')
            .map((e) => double.parse(e.trim()))
            .toList();
        var rgb = _hslToRGB(hslValues[0], hslValues[1], hslValues[2]);
        return Color.fromRGBO(
            rgb[0], rgb[1], rgb[2], hslValues.length > 3 ? hslValues[3] : 1.0);
      }
    } else if (color is List) {
      if (color.length == 3) {
        return Color.fromRGBO(color[0], color[1], color[2], 1.0);
      } else if (color.length == 4) {
        return Color.fromRGBO(color[0], color[1], color[2], color[3]);
      }
    }
    throw ArgumentError('Unsupported color format');
  }

  /// Converts HSL color values to RGB color space.
  ///
  /// [h] - Hue value (0-360)
  /// [s] - Saturation value (0-100)
  /// [l] - Lightness value (0-100)
  ///
  /// Returns a list of [r, g, b] values in the range 0-255.
  static List<int> _hslToRGB(double h, double s, double l) {
    h /= 60;
    s /= 100;
    l /= 100;

    double c = (1 - (2 * l - 1).abs()) * s;
    double x = c * (1 - ((h % 2) - 1).abs());
    double m = l - c / 2;

    List<double> rgb;
    if (h < 1) {
      rgb = [c, x, 0];
    } else if (h < 2) {
      rgb = [x, c, 0];
    } else if (h < 3) {
      rgb = [0, c, x];
    } else if (h < 4) {
      rgb = [0, x, c];
    } else if (h < 5) {
      rgb = [x, 0, c];
    } else {
      rgb = [c, 0, x];
    }

    return rgb.map((e) => ((e + m) * 255).round()).toList();
  }

  /// Generates a single random color based on provided options.
  ///
  /// [options] - Color generation options
  ///
  /// Returns a color in the format specified in options.
  static _pick(Options options) {
    int hue = _pickHue(options.colorType);
    int saturation =
        _pickSaturation(hue, options.luminosity, options.colorType);
    int brightness = _pickBrightness(hue, saturation, options.luminosity);
    return _setFormat(hue, saturation, brightness, options);
  }

  /// Sets the random number generator seed for reproducible colors.
  ///
  /// [seed] - Integer seed value
  static void seed(int seed) {
    _random = math.Random(seed);
  }

  /// Defines color characteristics and boundaries for a specific color type.
  ///
  /// [colorType] - The type of color being defined
  /// [hueRange] - Valid range of hue values for this color
  /// [lowerBounds] - List of saturation and brightness boundaries
  static _defineColor(
      {ColorType? colorType,
      List<int>? hueRange,
      required List<List> lowerBounds}) {
    var sMin = lowerBounds[0][0];
    var sMax = lowerBounds[lowerBounds.length - 1][0];
    var bMin = lowerBounds[lowerBounds.length - 1][1];
    var bMax = lowerBounds[0][1];

    _colorDictionary[colorType] = DefinedColor(
      hueRange: hueRange != null ? Range.toRange(hueRange) : null,
      lowerBounds: lowerBounds.map((e) => Point(x: e[0], y: e[1])).toList(),
      brightnessRange: Range(upper: bMax, lower: bMin),
      saturationRange: Range(upper: sMax, lower: sMin),
    );
  }

  /// Gets the valid hue range for a given color type.
  ///
  /// [colorType] - Single color type or list of color types
  ///
  /// Returns a Range object containing valid hue values.
  static Range? _getHueRange(dynamic colorType) {
    List<Range?> ranges = [];
    if (colorType is ColorType) {
      var color = _colorDictionary[colorType];
      if (color != null) {
        return color.hueRange;
      }
    }
    if (colorType is List<ColorType>) {
      colorType.forEach((ColorType element) {
        if (element == ColorType.random) {
          ranges.add(Range(lower: 0, upper: 360));
        } else {
          ranges.add(_colorDictionary[element]!.hueRange);
        }
      });
    }
    if (ranges.isEmpty) {
      return Range(lower: 0, upper: 360);
    } else if (ranges.length == 1) {
      return ranges[0];
    } else {
      return ranges[_randomWithin(Range(lower: 0, upper: ranges.length - 1))];
    }
  }

  /// Selects a random hue value within the valid range for a color type.
  ///
  /// [colorType] - The type of color to generate
  ///
  /// Returns an integer hue value.
  static _pickHue(dynamic colorType) {
    var hueRange = _getHueRange(colorType);
    if (hueRange == null) return 0;
    var hue = _randomWithin(hueRange);
    if (hue < 0) hue = 360 + hue;
    return hue;
  }

  /// Selects appropriate saturation value based on hue and luminosity.
  ///
  /// [hue] - Selected hue value
  /// [luminosity] - Desired brightness level
  /// [colorType] - Type of color being generated
  ///
  /// Returns an integer saturation value.
  static _pickSaturation(int hue, Luminosity luminosity, dynamic colorType) {
    if (colorType == ColorType.monochrome) return 0;
    if (luminosity == Luminosity.random) return __randomWithin(0, 100);
    Range saturationRange = _getColorInfo(hue).saturationRange!;
    var sMin = saturationRange.lower;
    var sMax = saturationRange.upper;
    var luminosBright = () {
      sMin = 55;
    };
    var luminosDark = () {
      sMin = sMax! - 10;
    };
    var luminoslight = () {
      sMax = 55;
    };
    switch (luminosity) {
      case Luminosity.bright:
        luminosBright();
        break;
      case Luminosity.dark:
        luminosDark();
        break;
      case Luminosity.light:
        luminoslight();
        break;
      case Luminosity.random:
        var r = math.Random().nextInt(2);
        if (r == 0) {
          luminosBright();
        } else if (r == 1) {
          luminosDark();
        } else {
          luminoslight();
        }
    }
    return __randomWithin(sMin!, sMax!);
  }

  /// Selects appropriate brightness value based on color properties.
  ///
  /// [hue] - Selected hue value
  /// [saturation] - Selected saturation value
  /// [luminosity] - Desired brightness level
  ///
  /// Returns an integer brightness value.
  static _pickBrightness(int hue, int saturation, Luminosity luminosity) {
    var bMin = _getMinimiumBrightness(hue, saturation);
    var bMax = 100;
    switch (luminosity) {
      case Luminosity.dark:
        bMax = bMin + 20;
        break;
      case Luminosity.light:
        bMin = (bMin + bMax) ~/ 2;
        break;
      case Luminosity.random:
        bMax = 100;
        bMin = 0;
        break;
      default:
    }
    return _randomWithin(Range(lower: bMin, upper: bMax));
  }

  /// Converts color values to the specified output format.
  ///
  /// [hue] - Hue value
  /// [saturation] - Saturation value
  /// [value] - Brightness value
  /// [options] - Options containing desired output format
  ///
  /// Returns color in the specified format (hex, rgb, hsl, etc.).
  static _setFormat(hue, saturation, value, Options options) {
    switch (options.format) {
      case Format.hsvArray:
        return [hue, saturation, value];
      case Format.hslArray:
        return _hsvToHsl(hue, saturation, value);
      case Format.hsl:
        var hsl = _hsvToHsl(hue, saturation, value);
        return 'hsl(${hsl[0]}, ${hsl[1].toInt()}%, ${hsl[2].toInt()}%)';
      case Format.hsla:
        var _hsl = _hsvToHsl(hue, saturation, value);
        var alpha =
            options.alpha ?? math.Random().nextDouble().toStringAsFixed(1);
        return 'hsla(${_hsl[0]}, ${_hsl[1]}%, ${_hsl[2]}%,$alpha)';
      case Format.rgbArray:
        return _hsvToRGB(hue: hue, saturation: saturation, value: value);
      case Format.rgb:
        List<int> rgb =
            _hsvToRGB(hue: hue, saturation: saturation, value: value);
        return 'rgb(${rgb.join(',')})';
      case Format.rgba:
        List<int> rgb =
            _hsvToRGB(hue: hue, saturation: saturation, value: value);
        var alpha =
            options.alpha ?? math.Random().nextDouble().toStringAsFixed(1);
        return 'rgba(${rgb.join(',')},$alpha)';
      case Format.hex:
        return _hsvToHex(hue, saturation, value);
      default:
        return _hsvToHex(hue, saturation, value);
    }
  }

  /// Calculates minimum brightness value for given hue and saturation.
  ///
  /// [hue] - Hue value
  /// [saturation] - Saturation value
  ///
  /// Returns integer minimum brightness value.
  static int _getMinimiumBrightness(int hue, int saturation) {
    var lowerBounds = _getColorInfo(hue).lowerBounds!;
    for (int i = 0; i < lowerBounds.length - 1; i++) {
      var s1 = lowerBounds[i].x!;
      var v1 = lowerBounds[i].y;
      var s2 = lowerBounds[i + 1].x;
      var v2 = lowerBounds[i + 1].y;

      if (saturation >= s1 && saturation <= s2!) {
        var m = (v2! - v1!) / (s2 - s1);
        var b = v1 - m * s1;
        return (m * saturation + b).toInt();
      }
    }
    return 0;
  }

  /// Retrieves color information for a given hue value.
  ///
  /// [hue] - Hue value to look up
  ///
  /// Returns DefinedColor object containing
  /// Retrieves color information for a given hue value.
  ///
  /// [hue] - Hue value to look up
  ///
  /// Returns DefinedColor object containing color boundaries and ranges.
  static DefinedColor _getColorInfo(int hue) {
    if (hue >= 334 && hue <= 360) {
      hue -= 360;
    }
    var result = _colorDictionary.entries
        .where((element) =>
            element.value.hueRange != null &&
            hue >= element.value.hueRange!.lower! &&
            hue <= element.value.hueRange!.upper!)
        .first;

    return result.value;
  }

  /// Generates a random number within a specified range.
  ///
  /// [range] - Range object with upper and lower bounds
  ///
  /// Returns random integer within the specified range.
  static int _randomWithin(Range range) {
    return __randomWithin(range.lower!, range.upper!);
  }

  /// Generates a random number within specified boundaries using golden ratio.
  ///
  /// [lower] - Lower boundary (inclusive)
  /// [upper] - Upper boundary (inclusive)
  ///
  /// Returns random integer within the specified boundaries.
  static int __randomWithin(int lower, int upper) {
    var goldenratio = 0.618033988749895;
    var _r = _random.nextDouble();
    _r += goldenratio;
    _r %= 1;
    return (lower + _r * (upper + 1 - lower)).floor();
  }

  /// Converts HSV color values to HSL format.
  ///
  /// [hue] - Hue value
  /// [saturation] - Saturation value
  /// [value] - Value (brightness)
  ///
  /// Returns list containing [hue, saturation, lightness] values.
  static List<int> _hsvToHsl(hue, saturation, value) {
    var s = saturation / 100;
    var v = value / 100;
    var k = (2 - s) * v;
    int su =
        double.parse(((s * v / (k < 1 ? k : 2 - k) * 10000) / 100).toString())
            .round();
    return [
      hue,
      su,
      (k / 2 * 100).toInt(),
    ];
  }

  /// Converts a color component to hexadecimal format.
  ///
  /// [c] - Color component value (0-255)
  ///
  /// Returns two-character hexadecimal string.
  static _componentToHex(int c) {
    var hex = c.toRadixString(16);
    return hex.length == 1 ? '0' + hex : hex;
  }

  /// Converts HSV color values to hexadecimal format.
  ///
  /// [hue] - Hue value
  /// [saturation] - Saturation value
  /// [value] - Value (brightness)
  ///
  /// Returns color as hexadecimal string (e.g., "#FF0000").
  static _hsvToHex(hue, saturation, value) {
    var rgb = _hsvToRGB(hue: hue, saturation: saturation, value: value);
    var hex =
        '#${_componentToHex(rgb[0])}${_componentToHex(rgb[1])}${_componentToHex(rgb[2])}';
    return hex;
  }

  /// Converts HSV color values to RGB format.
  ///
  /// [hue] - Hue value (0-360)
  /// [saturation] - Saturation value (0-100)
  /// [value] - Value/brightness (0-100)
  ///
  /// Returns list of [r, g, b] values in range 0-255.
  static List<int> _hsvToRGB(
      {required hue, required saturation, required value}) {
    var h = hue.toDouble();
    if (h == 0) {
      h = 1;
    }
    if (h == 360) {
      h = 359;
    }
    h /= 360;
    var s = saturation / 100.0;
    var v = value / 100.0;
    var i = (h * 6).floor();
    var f = h * 6 - i;
    var p = v * (1 - s);
    var q = v * (1 - f * s);
    var t = v * (1 - (1 - f) * s);
    double? r = 256.0;
    double? g = 256.0;
    double? b = 256.0;

    switch (i) {
      case 0:
        r = v;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = v;
        b = p;
        break;
      case 2:
        r = p;
        g = v;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = v;
        break;
      case 4:
        r = t;
        g = p;
        b = v;
        break;
      case 5:
        r = v;
        g = p;
        b = q;
        break;
      default:
    }

    var result = [(r! * 255).floor(), (g! * 255).floor(), (b! * 255).floor()];
    return result;
  }

  /// Initializes the color dictionary with predefined color ranges and boundaries.
  /// Sets up color definitions for monochrome, red, orange, yellow, green, blue,
  /// purple, and pink colors with their respective hue ranges and brightness/saturation bounds.
  static void __loadColorBounds() {
    _defineColor(
      colorType: ColorType.monochrome,
      hueRange: null,
      lowerBounds: [
        [0, 0],
        [100, 0],
      ],
    );
    _defineColor(
      colorType: ColorType.red,
      hueRange: [-26, 18],
      lowerBounds: [
        [20, 100],
        [30, 92],
        [40, 89],
        [50, 85],
        [60, 78],
        [70, 70],
        [80, 60],
        [90, 55],
        [100, 50]
      ],
    );

    // ... (rest of the color definitions)
  }
}

/// Represents a defined color with its properties and valid ranges.
/// Used to store color information in the color dictionary.
class DefinedColor {
  /// Valid range of hue values for this color
  final Range? hueRange;

  /// Valid range of saturation values
  final Range? saturationRange;

  /// Valid range of brightness values
  final Range? brightnessRange;

  /// List of points defining the lower bounds of valid values
  final List<Point>? lowerBounds;

  /// Creates a new DefinedColor with the specified ranges and bounds.
  DefinedColor({
    this.brightnessRange,
    this.hueRange,
    this.lowerBounds,
    this.saturationRange,
  });
}

/// Represents a point with x and y coordinates.
/// Used to define color boundaries in the color space.
class Point {
  /// X coordinate, typically representing saturation
  int? x;

  /// Y coordinate, typically representing brightness/value
  int? y;

  /// Creates a new Point with the specified coordinates.
  Point({this.x, this.y});
}
