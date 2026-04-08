import 'dart:ui';

class WaterColors {
  final Color top;
  final Color bottom;

  const WaterColors({required this.top, required this.bottom});
}

class WaterColorProgression {
  WaterColorProgression._();

  static WaterColors colors(int totalMinutes) {
    if (totalMinutes < 300) {
      return const WaterColors(
        top: Color.fromRGBO(115, 191, 242, 1.0),
        bottom: Color.fromRGBO(51, 128, 217, 1.0),
      );
    } else if (totalMinutes < 1500) {
      return const WaterColors(
        top: Color.fromRGBO(77, 166, 230, 1.0),
        bottom: Color.fromRGBO(26, 102, 204, 1.0),
      );
    } else if (totalMinutes < 5000) {
      return const WaterColors(
        top: Color.fromRGBO(51, 153, 217, 1.0),
        bottom: Color.fromRGBO(13, 89, 191, 1.0),
      );
    } else if (totalMinutes < 15000) {
      return const WaterColors(
        top: Color.fromRGBO(38, 140, 191, 1.0),
        bottom: Color.fromRGBO(13, 77, 166, 1.0),
      );
    } else {
      return const WaterColors(
        top: Color.fromRGBO(26, 102, 179, 1.0),
        bottom: Color.fromRGBO(8, 51, 140, 1.0),
      );
    }
  }
}
