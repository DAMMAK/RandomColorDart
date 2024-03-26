library flutter_randomcolor;

import 'dart:math' as math;

import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:flutter_randomcolor/src/range.dart';

class RandomColor {
  // color dictionary that save all the colors
  static Map<ColorType?, DefinedColor> _colorDictionary =
      Map<ColorType?, DefinedColor>();
  // ignore: unused_field
  static math.Random _random = math.Random(); //seed data

// get random colors based on options provided
  static getColor(Options options) {
    __loadColorBounds();
    // check if count is not provided or less than 2 then return a single color
    if (options.count < 2) return _pick(options);
    var colors = [];
    // if color count is more than 1 return an array of color
    for (var i = 0; i < options.count; i++) {
      var _color = _pick(options);
      colors.add(_color);
    }
    return colors;
  }

  // get the color based on provided option and return a single color
  static _pick(Options options) {
    int hue;
    int saturation;
    int brightness;
    hue = _pickHue(options.colorType);
    saturation = _pickSaturation(hue, options.luminosity, options.colorType);
    brightness = _pickBrightness(hue, saturation, options.luminosity);
    return _setFormat(hue, saturation, brightness, options);
  }

  // generate a random value
  static void seed(int seed) {
    _random = math.Random(seed);
  }

  // define the color based on provided hue and lowerBounds
  static _defineColor(
      {ColorType? colorType,
      List<int>? hueRange,
      required List<List> lowerBounds}) {
    var sMin = lowerBounds[0][0]; // saturation lowerbound
    var sMax = lowerBounds[lowerBounds.length - 1][0]; // saturation upperbound
    var bMin = lowerBounds[lowerBounds.length - 1][1]; // brightness lowerbound
    var bMax = lowerBounds[0][1]; // brightness upperbound

    _colorDictionary[colorType] = DefinedColor(
      //only assign is hueRange is not null
      hueRange: hueRange != null ? Range.toRange(hueRange) : null,
      lowerBounds: lowerBounds.map((e) => Point(x: e[0], y: e[1])).toList(),
      brightnessRange: Range(upper: bMax, lower: bMin),
      saturationRange: Range(upper: sMax, lower: sMin),
    );
  }

// Get Hue Range
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
    if (ranges.length == 0) {
      return Range(lower: 0, upper: 360);
    } else if (ranges.length == 1) {
      return ranges[0];
    } else {
      return ranges[_randomWithin(Range(lower: 0, upper: ranges.length - 1))];
    }
    // DefinedColor color;
    // color = _colorDictionary[colorType];
    // if (color.hueRange != null) {
    //   return color.hueRange;
    // }
    // return Range(lower: 0, upper: 360);
  }

  // Pick Hue using a specific colorType
  static _pickHue(dynamic colorType) {
    var hueRange = _getHueRange(colorType);
    if (hueRange == null) return 0;
    var hue = _randomWithin(hueRange);
    // Instead of storing red as two separate ranges,
    // we group them, using negative numbers
    if (hue < 0) hue = 360 + hue;

    return hue;
  }

  // Pick Saturation
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

  // Pick Brightness
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

  // return a color format e.g rgba, hex, hsl.
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
        // if no format is provided then return a hex color format
        return _hsvToHex(hue, saturation, value);
    }
  }

  // get minimium brightness by providing the hue and satuation
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

  // GetColorInfo usng hue
  static DefinedColor _getColorInfo(int hue) {
    // Maps red colors to make picking hue easier
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

  static int _randomWithin(Range range) {
    return __randomWithin(range.lower!, range.upper!);
  }

  // generate a random number withing a boundry i.e (lower-upper)
  static int __randomWithin(int lower, int upper) {
    var goldenratio = 0.618033988749895;
    var _r = math.Random().nextDouble();
    _r += goldenratio;
    _r %= 1;
    return (lower + _r * (upper + 1 - lower)).floor();
    //return lower + _random.nextInt(upper - lower);
  }

  //convert hsl to hsl color format
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

  static _componentToHex(int c) {
    var hex = c.toRadixString(16);
    return hex.length == 1 ? '0' + hex : hex;
  }

  // convert hsv to hex color format
  static _hsvToHex(hue, saturation, value) {
    var rgb = _hsvToRGB(hue: hue, saturation: saturation, value: value);
    var hex =
        '#${_componentToHex(rgb[0])}${_componentToHex(rgb[1])}${_componentToHex(rgb[2])}';
    return hex;
  }

  //convert hsv to RGB color format
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

  // define and load color to be used
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

    _defineColor(
      colorType: ColorType.orange,
      hueRange: [19, 46],
      lowerBounds: [
        [20, 100],
        [30, 93],
        [40, 88],
        [50, 86],
        [60, 85],
        [70, 70],
        [100, 70]
      ],
    );

    _defineColor(
      colorType: ColorType.yellow,
      hueRange: [46, 62],
      lowerBounds: [
        [25, 100],
        [40, 94],
        [50, 89],
        [60, 86],
        [70, 84],
        [80, 82],
        [90, 80],
        [100, 75]
      ],
    );

    _defineColor(
      colorType: ColorType.green,
      hueRange: [62, 178],
      lowerBounds: [
        [30, 100],
        [40, 90],
        [50, 85],
        [60, 81],
        [70, 74],
        [80, 64],
        [90, 50],
        [100, 40]
      ],
    );

    _defineColor(
      colorType: ColorType.blue,
      hueRange: [178, 257],
      lowerBounds: [
        [20, 100],
        [30, 86],
        [40, 80],
        [50, 74],
        [60, 60],
        [70, 52],
        [80, 44],
        [90, 39],
        [100, 35]
      ],
    );

    _defineColor(
      colorType: ColorType.purple,
      hueRange: [257, 282],
      lowerBounds: [
        [20, 100],
        [30, 87],
        [40, 79],
        [50, 70],
        [60, 65],
        [70, 59],
        [80, 52],
        [90, 45],
        [100, 42]
      ],
    );

    _defineColor(
      colorType: ColorType.purple,
      hueRange: [257, 282],
      lowerBounds: [
        [20, 100],
        [30, 87],
        [40, 79],
        [50, 70],
        [60, 65],
        [70, 59],
        [80, 52],
        [90, 45],
        [100, 42]
      ],
    );

    _defineColor(
      colorType: ColorType.pink,
      hueRange: [282, 334],
      lowerBounds: [
        [20, 100],
        [30, 90],
        [40, 86],
        [60, 84],
        [80, 80],
        [90, 75],
        [100, 73]
      ],
    );
  }
}

class DefinedColor {
  final Range? hueRange;
  final Range? saturationRange;
  final Range? brightnessRange;
  final List<Point>? lowerBounds;
  DefinedColor({
    this.brightnessRange,
    this.hueRange,
    this.lowerBounds,
    this.saturationRange,
  });
}

class Point {
  int? x;
  int? y;
  Point({this.x, this.y});
}
