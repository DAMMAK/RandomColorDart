# RandomColor for Dart & Flutter

[![CircleCI](https://circleci.com/gh/circleci/circleci-docs.svg?style=svg)](https://circleci.com/gh/DAMMAK/RandomColorDart)
[![Github Code Size](https://img.shields.io/github/languages/code-size/DAMMAK/RandomColorDart)](https://github.com/DAMMAK/RandomColorDart)
[![Github License](https://img.shields.io/github/license/DAMMAK/RandomColorDart)](https://github.com/DAMMAK/RandomColorDart/blob/master/LICENSE)
[![Pub version](https://img.shields.io/pub/v/flutter_randomcolor)](https://pub.dev/packages/flutter_randomcolor)

Generate visually appealing random colors with ease in your Dart and Flutter projects.

![Demo](https://github.com/DAMMAK/RandomColorDart/blob/master/randomcolor.png)

[Interactive Demo](https://randomcolor.dammak.dev/)

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Guide](#usage-guide)
    - [Basic Usage](#basic-usage)
    - [Flutter Integration](#flutter-integration)
    - [Advanced Options](#advanced-options)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Features

- Generate random colors with fine-tuned control
- Specify color types, luminosity, and output formats
- Direct integration with Flutter's `Color` class
- Highly customizable with easy-to-use API
- Consistent results across platforms

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_randomcolor: ^1.0.15
```

Then run:

```bash
$ flutter pub get
```

## Quick Start

```dart
import 'package:flutter_randomcolor/flutter_randomcolor.dart';

// Generate a random color
var color = RandomColor.getColor(Options());

// Generate a Flutter Color object
Color flutterColor = RandomColor.getColorObject(Options());
```

## Usage Guide

### Basic Usage

Generate a random color with default options:

```dart
var color = RandomColor.getColor(Options());
```

### Flutter Integration

Get a `Color` object for direct use in Flutter widgets:

```dart
Color widgetColor = RandomColor.getColorObject(Options(
  colorType: ColorType.blue,
  luminosity: Luminosity.light,
));

// Use in a widget
Container(
  color: widgetColor,
  child: Text('Colored Container'),
)
```

### Advanced Options

Fine-tune your color generation:

```dart
var customColor = RandomColor.getColor(Options(
  colorType: [ColorType.red, ColorType.blue],
  luminosity: Luminosity.dark,
  format: Format.rgba,
  alpha: 0.8,
));
```

## API Reference

### `RandomColor.getColor(Options options)`

Returns a color based on the specified options.

### `RandomColor.getColorObject(Options options)`

Returns a Flutter `Color` object based on the specified options.

### `Options` class

- `colorType`: `ColorType` or `List<ColorType>`
- `luminosity`: `Luminosity`
- `format`: `Format`
- `alpha`: `double` (0.0 to 1.0)
- `count`: `int`

#### ColorType

`random`, `monochrome`, `red`, `orange`, `yellow`, `green`, `blue`, `purple`, `pink`

#### Luminosity

`random`, `dark`, `light`, `bright`

#### Format

`rgba`, `rgb`, `rgbArray`, `hsla`, `hex`, `hsl`, `hsva`, `hsvArray`, `hslArray`

## Examples

```dart
// Bright green color in hex format
var brightGreen = RandomColor.getColor(Options(
  colorType: ColorType.green,
  luminosity: Luminosity.bright,
  format: Format.hex
));

// Array of 5 pastel colors
var pastelColors = RandomColor.getColor(Options(
  luminosity: Luminosity.light,
  count: 5
));

// Dark red or blue with 50% opacity
var transparentDark = RandomColor.getColor(Options(
  colorType: [ColorType.red, ColorType.blue],
  luminosity: Luminosity.dark,
  format: Format.rgba,
  alpha: 0.5
));
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for more details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Original JavaScript implementation by [David Merfield](https://github.com/davidmerfield/randomColor)
- Dart port maintained by [DAMMAK](https://github.com/DAMMAK)

---

<details>
<summary>Available in Other Languages</summary>

- [JavaScript](https://github.com/davidmerfield/randomColor)
- [C#](https://github.com/nathanpjones/randomColorSharped)
- [C++](https://github.com/xuboying/randomcolor-cpp)
- [Go](https://github.com/hansrodtang/randomcolor)
- [Python](https://github.com/kevinwuhoo/randomcolor-py)
- [Swift](https://github.com/onevcat/RandomColorSwift)
- [Objective-C](https://github.com/yageek/randomColor)
- [Java](https://github.com/lzyzsd/AndroidRandomColor)
- [R](https://github.com/ronammar/randomcoloR)
- [Rust](https://github.com/elementh/random_color)

</details>