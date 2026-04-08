enum EnvironmentStage {
  barren(0),
  grass(1),
  flowers(2),
  trees(3),
  forest(4),
  lake(5);

  final int value;
  const EnvironmentStage(this.value);

  int get requiredTotalMinutes {
    switch (this) {
      case EnvironmentStage.barren:
        return 0;
      case EnvironmentStage.grass:
        return 300;
      case EnvironmentStage.flowers:
        return 1500;
      case EnvironmentStage.trees:
        return 5000;
      case EnvironmentStage.forest:
        return 15000;
      case EnvironmentStage.lake:
        return 40000;
    }
  }

  String get displayName {
    switch (this) {
      case EnvironmentStage.barren:
        return '맨땅';
      case EnvironmentStage.grass:
        return '풀밭';
      case EnvironmentStage.flowers:
        return '꽃밭';
      case EnvironmentStage.trees:
        return '나무';
      case EnvironmentStage.forest:
        return '숲';
      case EnvironmentStage.lake:
        return '호수';
    }
  }

  String get emoji {
    switch (this) {
      case EnvironmentStage.barren:
        return '\uD83C\uDFDC\uFE0F';
      case EnvironmentStage.grass:
        return '\uD83C\uDF31';
      case EnvironmentStage.flowers:
        return '\uD83C\uDF38';
      case EnvironmentStage.trees:
        return '\uD83C\uDF33';
      case EnvironmentStage.forest:
        return '\uD83C\uDF32';
      case EnvironmentStage.lake:
        return '\uD83C\uDFDE\uFE0F';
    }
  }

  String get description {
    switch (this) {
      case EnvironmentStage.barren:
        return '집중을 시작하면 세계가 변합니다';
      case EnvironmentStage.grass:
        return '작은 풀이 자라기 시작했어요';
      case EnvironmentStage.flowers:
        return '꽃들이 피어나고 있어요';
      case EnvironmentStage.trees:
        return '나무가 자라고 있어요';
      case EnvironmentStage.forest:
        return '울창한 숲이 되었어요';
      case EnvironmentStage.lake:
        return '고요한 호수가 생겼어요';
    }
  }

  EnvironmentStage? get nextStage {
    final nextValue = value + 1;
    if (nextValue >= EnvironmentStage.values.length) return null;
    return EnvironmentStage.values[nextValue];
  }

  static EnvironmentStage stage(int totalMinutes) {
    for (final s in EnvironmentStage.values.reversed) {
      if (totalMinutes >= s.requiredTotalMinutes) {
        return s;
      }
    }
    return EnvironmentStage.barren;
  }
}
