class AppConstants {
  AppConstants._();

  static const String appDirectoryName = 'RainDrop';
  static const String storageFilename = 'focus_sessions.json';

  /// 소셜/로그인 기능 활성화 여부 — false면 Firebase Auth/Sync 비활성화
  static const bool socialEnabled = false;

  static const String appVersion = '2.1.1';
  static const String githubReleasesAPI =
      'https://api.github.com/repos/mgm136044/Raindrop/releases/latest';
}
