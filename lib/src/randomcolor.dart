import 'dart:math' as math;

import 'package:randomcolor/src/colortype.dart';
import 'package:randomcolor/src/luminos.dart';
import 'package:randomcolor/src/options.dart';
import 'package:randomcolor/src/range.dart';

class RandomColor {
  static Map<ColorType, DefinedColor> _colorDictionary =
      Map<ColorType, DefinedColor>();
  static math.Random _random = math.Random(); //seed data

  static getColor(Options options) {
    __loadColorBounds();
    if (options.count == null || options.count < 2) return _pick(options);
    var colors = [];
    for (var i = 0; i < options.count; i++) {
      var _color = _pick(options);
      colors.add(_color);
    }
    return colors;
  }

  static _pick(Options options) {
    int hue;
    int saturation;
    int brightness;
    hue = _pickHue(options.colorType);
    saturation = _pickSaturation(hue, options.luminosity, options.colorType);
    brightness = _pickBrightness(hue, saturation, options.luminosity);
    return _setFormat(hue, saturation, brightness, options);
  }

  static void seed(int seed) {
    if (seed == null) {
      _random = math.Random();
      return;
    }
    _random = math.Random(seed);
  }

  static _defineColor(
      {ColorType colorType, List<int> hueRange, List<List> lowerBounds}) {
    var sMin = lowerBounds[0][0]; // saturation lowerbound
    var sMax = lowerBounds[lowerBounds.length - 1][0]; // saturation upperbound
    var bMin = lowerBounds[lowerBounds.length - 1][1]; // brightness lowerbound
    var bMax = lowerBounds[0][1]; // brightness upperbound

    _colorDictionary[colorType] = DefinedColor(
      hueRange: Range.toRange(hueRange),
      lowerBounds: lowerBounds.map((e) => Point(x: e[0], y: e[1])).toList(),
      brightnessRange: Range(upper: bMax, lower: bMin),
      saturationRange: Range(upper: sMax, lower: sMin),
    );
  }

// Get Hue Range
  static Range _getHueRange(ColorType colorType) {
    DefinedColor color;
    color = _colorDictionary[colorType];
    if (color.hueRange != null) {
      return color.hueRange;
    }
    return Range(lower: 0, upper: 360);
  }

  // Pick Hue
  static _pickHue(ColorType colorType) {
    var hueRange = _getHueRange(colorType);
    if (hueRange == null) return 0;
    var hue = _randomWithin(hueRange);
    // Instead of storing red as two separate ranges,
    // we group them, using negative numbers
    if (hue < 0) hue = 360 + hue;

    return hue;
  }

  // Pick Saturation
  static _pickSaturation(int hue, Luminosity luminosity, ColorType colorType) {
    if (colorType == ColorType.monochrome) return 0;
    if (luminosity == Luminosity.random) return __randomWithin(0, 100);
    Range saturationRange = _getColorInfo(hue).saturationRange;
    var sMin = saturationRange.lower;
    var sMax = saturationRange.upper;
    switch (luminosity) {
      case Luminosity.bright:
        sMin = 55;
        break;
      case Luminosity.dark:
        sMin = sMax - 10;
        break;
      case Luminosity.light:
        sMax = 55;
        break;
    }
    return __randomWithin(sMin, sMax);
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

  static _setFormat(hue, saturation, value, Options options) {
    switch (options.format) {
      case Format.hsvArray:
        return [hue, saturation, value];
        break;
      case Format.hslArray:
        return _hsvToHsl(hue, saturation, value);
        break;
      case Format.hsl:
        var hsl = _hsvToHsl(hue, saturation, value);
        return 'hsl(${hsl[0]}, ${hsl[1].toInt()}%, ${hsl[2].toInt()}%)';
        break;
      case Format.hsla:
        var _hsl = _hsvToHsl(hue, saturation, value);
        var alpha =
            options.alpha ?? math.Random().nextDouble().toStringAsFixed(1);
        return 'hsla(${_hsl[0]}, ${_hsl[1]}%, ${_hsl[2]}%,$alpha)';
        break;
      case Format.rgbArray:
        return _hsvToRGB(hue: hue, saturation: saturation, value: value);
        break;
      case Format.rgb:
        List<int> rgb =
            _hsvToRGB(hue: hue, saturation: saturation, value: value);
        return 'rgb(${rgb.join(',')})';
        break;
      case Format.rgba:
        List<int> rgb =
            _hsvToRGB(hue: hue, saturation: saturation, value: value);
        var alpha =
            options.alpha ?? math.Random().nextDouble().toStringAsFixed(1);
        return 'rgba(${rgb.join(',')},$alpha)';
        break;
      case Format.hex:
        return _hsvToHex(hue, saturation, value);
      default:
        return _hsvToHex(hue, saturation, value);
    }
  }

  static int _getMinimiumBrightness(int hue, int saturation) {
    var lowerBounds = _getColorInfo(hue).lowerBounds;
    for (int i = 0; i < lowerBounds.length - 1; i++) {
      var s1 = lowerBounds[i].x;
      var v1 = lowerBounds[i].y;

      var s2 = lowerBounds[i + 1].x;
      var v2 = lowerBounds[i + 1].y;

      if (saturation >= s1 && saturation <= s2) {
        var m = (v2 - v1) / (s2 - s1);
        var b = v1 - m * s1;
        return (m * saturation + b).toInt();
      }
    }

    return 0;
  }

  // GetColorInfo
  static DefinedColor _getColorInfo(int hue) {
    // Maps red colors to make picking hue easier
    if (hue >= 334 && hue <= 360) {
      hue -= 360;
    }
    var result = _colorDictionary.entries
        .where((element) =>
            element.value.hueRange != null &&
            hue >= element.value.hueRange.lower &&
            hue <= element.value.hueRange.upper)
        .first;

    assert(result.value != null);
    return result.value;
  }

  static int _randomWithin(Range range) {
    return __randomWithin(range.lower, range.upper);
  }

  static int __randomWithin(int lower, int upper) {
    return lower + _random.nextInt(upper - lower);
  }

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

  static _componentToHex(c) {
    print("Hex component => $c");
    var hex = c.toString();
    return hex.length == 1 ? '0' + hex : hex;
  }

  static _hsvToHex(hue, saturation, value) {
    var rgb = _hsvToRGB(hue: hue, saturation: saturation, value: value);
    var hex =
        '#${_componentToHex(rgb[0])}${_componentToHex(rgb[1])}${_componentToHex(rgb[2])}';
    return hex;
  }

  static List<int> _hsvToRGB({hue, saturation, value}) {
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
    var r = 256.0;
    var g = 256.0;
    var b = 256.0;

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
    ;

    var result = [(r * 255).floor(), (g * 255).floor(), (b * 255).floor()];
    return result;
  }

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
  final Range hueRange;
  final Range saturationRange;
  final Range brightnessRange;
  final List<Point> lowerBounds;
  DefinedColor({
    this.brightnessRange,
    this.hueRange,
    this.lowerBounds,
    this.saturationRange,
  });
}

class Point {
  int x;
  int y;
  Point({this.x, this.y});
}
