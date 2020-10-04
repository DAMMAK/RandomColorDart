import 'package:randomcolor/src/colortype.dart';
import 'package:randomcolor/src/luminos.dart';
import 'package:randomcolor/src/options.dart';
import 'package:randomcolor/src/randomcolor.dart';

void main() async {
  var options = Options(format: Format.hsl, colorType: ColorType.blue,luminosity: Luminosity.light);
  var color = RandomColor.getColor(options);
  print(color);
}
