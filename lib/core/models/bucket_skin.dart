import 'package:flutter/material.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

enum BucketSkin {
  wood,
  dentedIron,
  platinum,
  gold,
  diamond,
  rainbow;

  static BucketSkin fromString(String value) {
    return BucketSkin.values.firstWhere(
      (s) => s.name == value,
      orElse: () => BucketSkin.wood,
    );
  }

  int get requiredBuckets {
    switch (this) {
      case wood:
        return 0;
      case dentedIron:
        return 50;
      case platinum:
        return 150;
      case gold:
        return 250;
      case diamond:
        return 1700;
      case rainbow:
        return 5000;
    }
  }

  bool isUnlocked(int totalBuckets) => totalBuckets >= requiredBuckets;

  String get displayName {
    switch (this) {
      case wood:
        return '나무 양동이';
      case dentedIron:
        return '찌그러진 철 양동이';
      case platinum:
        return '백금 양동이';
      case gold:
        return '금 양동이';
      case diamond:
        return '다이아 양동이';
      case rainbow:
        return '무지개 양동이';
    }
  }

  String get materialDescription {
    switch (this) {
      case wood:
        return '오래된 참나무로 만든 소박한 양동이';
      case dentedIron:
        return '사용감 있는 철로 만든 튼튼한 양동이';
      case platinum:
        return '광택 나는 백금으로 제작된 고급 양동이';
      case gold:
        return '순금으로 도금된 화려한 양동이';
      case diamond:
        return '다이아몬드 결정으로 빛나는 보석 양동이';
      case rainbow:
        return '일곱 빛깔 무지개가 흐르는 전설의 양동이';
    }
  }

  Color get bucketFill {
    switch (this) {
      case wood:
        return const Color.fromRGBO(140, 89, 46, 0.72);
      case dentedIron:
        return const Color.fromRGBO(89, 97, 107, 0.72);
      case platinum:
        return const Color.fromRGBO(217, 222, 230, 0.72);
      case gold:
        return const Color.fromRGBO(217, 173, 51, 0.72);
      case diamond:
        return const Color.fromRGBO(179, 217, 242, 0.72);
      case rainbow:
        return const Color.fromRGBO(230, 204, 242, 0.72);
    }
  }

  Color get bucketStroke {
    switch (this) {
      case wood:
        return const Color.fromRGBO(102, 64, 31, 1);
      case dentedIron:
        return const Color.fromRGBO(115, 122, 133, 1);
      case platinum:
        return const Color.fromRGBO(191, 199, 209, 1);
      case gold:
        return const Color.fromRGBO(191, 148, 26, 1);
      case diamond:
        return const Color.fromRGBO(140, 191, 230, 1);
      case rainbow:
        return const Color.fromRGBO(179, 128, 204, 1);
    }
  }

  Color get bucketHandle {
    switch (this) {
      case wood:
        return const Color.fromRGBO(89, 56, 26, 1);
      case dentedIron:
        return const Color.fromRGBO(128, 133, 140, 1);
      case platinum:
        return const Color.fromRGBO(204, 209, 217, 1);
      case gold:
        return const Color.fromRGBO(204, 158, 38, 1);
      case diamond:
        return const Color.fromRGBO(153, 199, 235, 1);
      case rainbow:
        return const Color.fromRGBO(191, 140, 217, 1);
    }
  }

  Color get bandColor {
    switch (this) {
      case wood:
        return const Color.fromRGBO(77, 46, 20, 1);
      case dentedIron:
        return const Color.fromRGBO(115, 122, 133, 0.4);
      case platinum:
        return const Color.fromRGBO(191, 199, 209, 0.5);
      case gold:
        return const Color.fromRGBO(230, 191, 64, 1);
      case diamond:
        return const Color.fromRGBO(166, 217, 255, 1);
      case rainbow:
        return const Color.fromRGBO(204, 153, 230, 1);
    }
  }

  bool get hasCustomWaterColor {
    switch (this) {
      case wood:
      case dentedIron:
      case platinum:
        return false;
      case gold:
      case diamond:
      case rainbow:
        return true;
    }
  }

  Color get customWaterGradientTop {
    switch (this) {
      case gold:
        return const Color.fromRGBO(255, 217, 89, 1);
      case diamond:
        return const Color.fromRGBO(179, 230, 255, 1);
      case rainbow:
        return const Color.fromRGBO(255, 153, 153, 1);
      default:
        return AppColors.waterGradientTopColor;
    }
  }

  Color get customWaterGradientBottom {
    switch (this) {
      case gold:
        return const Color.fromRGBO(217, 153, 13, 1);
      case diamond:
        return const Color.fromRGBO(102, 166, 242, 1);
      case rainbow:
        return const Color.fromRGBO(128, 77, 230, 1);
      default:
        return AppColors.waterGradientBottomColor;
    }
  }

  Color get customDropGradientTop {
    switch (this) {
      case gold:
        return const Color.fromRGBO(255, 230, 128, 1);
      case diamond:
        return const Color.fromRGBO(204, 242, 255, 1);
      case rainbow:
        return const Color.fromRGBO(255, 179, 179, 1);
      default:
        return AppColors.dropGradientTopColor;
    }
  }

  Color get customDropGradientBottom {
    switch (this) {
      case gold:
        return const Color.fromRGBO(230, 166, 26, 1);
      case diamond:
        return const Color.fromRGBO(128, 179, 255, 1);
      case rainbow:
        return const Color.fromRGBO(153, 89, 242, 1);
      default:
        return AppColors.dropGradientBottomColor;
    }
  }
}
