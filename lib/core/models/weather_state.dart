enum WeatherCondition {
  cloudy(0),
  drizzle(1),
  rain(2),
  rainbow(3);

  final int value;
  const WeatherCondition(this.value);

  int get requiredConsecutiveDays {
    switch (this) {
      case WeatherCondition.cloudy:
        return 1;
      case WeatherCondition.drizzle:
        return 3;
      case WeatherCondition.rain:
        return 7;
      case WeatherCondition.rainbow:
        return 14;
    }
  }

  String get displayName {
    switch (this) {
      case WeatherCondition.cloudy:
        return '흐림';
      case WeatherCondition.drizzle:
        return '이슬비';
      case WeatherCondition.rain:
        return '비';
      case WeatherCondition.rainbow:
        return '무지개';
    }
  }

  String get emoji {
    switch (this) {
      case WeatherCondition.cloudy:
        return '\u2601\uFE0F';
      case WeatherCondition.drizzle:
        return '\uD83C\uDF26\uFE0F';
      case WeatherCondition.rain:
        return '\uD83C\uDF27\uFE0F';
      case WeatherCondition.rainbow:
        return '\uD83C\uDF08';
    }
  }

  static WeatherCondition condition(int consecutiveDays) {
    for (final c in WeatherCondition.values.reversed) {
      if (consecutiveDays >= c.requiredConsecutiveDays) {
        return c;
      }
    }
    return WeatherCondition.cloudy;
  }
}
