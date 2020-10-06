# Random Color

A dart package for generating attractive random colors.

This is a Dart port of David Merfield randomColor Javascript utility

[![Demo](https://github.com/DAMMAK/RandomColorDart/blob/master/randomcolor.png)](http://www.strangeplanet.fr/work/RandomColor.php)

## Installing

```dart
dependencies:
  randomcolor: ^1.0.2

```

## How to use

```dart
var options = Options(format: Format.hex, colorType: ColorType.green);
var color = RandomColor.getColor(options);
```

## Options

You can pass an option to influence the type of color it produces. The options object accepts the following properties

**colorType -** This control the type of color to be generated. colortype is a enum data type of the following:- `random`, `monochrome`, `red`, `orange`, `yellow`, `green`, `blue`, `purple`, `pink`

**luminosity -** This control the luminosity of the generated color. luminosity is a enum data type of the following:- `random`, `dark`, `light`, `bright`

**format -** This control the format of the generated color, it tells the output format of the color. format is a enum data type of the following:- `rgba`, `rgb`, `rgbArray`, `hsla`, `hex`, `hsl`, `hsva`, `hsvArray`, `hslArray`.

**alpha -** This control the opacity of the generated color, it is a decimal between `0` to `1`. it is only neccessary on `rgba`, `hsla`.

**count -** This control the length of the generated color. it is only neccessary when generating color that is greater than 1

# Examples

```dart
// Return a single blue color in rgba format
Options options = Options(format: Format.rgba, colorType: ColorType.blue);
var color = RandomColor.getColor(options);

// Return an array of ten green colors in hex format
Options options = Options(format: Format.rgba, colorType: ColorType.blue, count:10);
var color = RandomColor.getColor(options);

// Return a single color of light red in hsl format
Options options = Options(format: Format.hsl, colorType: ColorType.red, luminosity: Luminosity.light);
var color = RandomColor.getColor(options);

// Return a bright color in rgb
Options options = Options(format: Format.rgb, luminosity: Luminosity.bright);
var color = RandomColor.getColor(options);

// Return a dark color with a specific alpha
Options options = Options(luminosity: Luminosity.dark, alpha: 0.3);
var color = RandomColor.getColor(options);

// Return a light hsl color with a random alpha
Options options = Options(format: Format.hsla, luminosity: Luminosity.light);
var color = RandomColor.getColor(options);
```

### Other languages

RandomColor is available in JavaScript, C#, C++, Go, Python, Swift, Objective-C, Java, R and Rust.
