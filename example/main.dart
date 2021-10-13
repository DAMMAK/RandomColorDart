import 'package:flutter_randomcolor/flutter_randomcolor.dart';

void main() async {
  var options = Options(
      format: Format.hsl,
      count: 100,
      colorType: ColorType.blue,
      luminosity: Luminosity.light);
  var color = RandomColor.getColor(options);
  print(color);
}
