import 'package:randomcolor/src/colortype.dart';
import 'package:randomcolor/src/options.dart';
import 'package:randomcolor/src/randomcolor.dart';

void main() async {
  var options = Options(format: Format.rgba, colorType: ColorType.blue);
  var color = RandomColor.getColor(options);
  print(color);
}
