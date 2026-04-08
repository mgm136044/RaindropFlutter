class AppSettings {
  int sessionGoalMinutes;
  bool focusCheckEnabled;
  int focusCheckIntervalMinutes;
  bool infinityModeEnabled;
  String selectedSkin;
  bool useCustomWaterColor;
  bool whiteNoiseEnabled;
  double whiteNoiseVolume;
  bool hasSeenOnboarding;
  bool waterColorEvolution;

  int get sessionGoalSeconds => sessionGoalMinutes * 60;

  static const String storageFilename = 'app_settings.json';

  AppSettings({
    this.sessionGoalMinutes = 25,
    this.focusCheckEnabled = false,
    this.focusCheckIntervalMinutes = 5,
    this.infinityModeEnabled = false,
    this.selectedSkin = 'wood',
    this.useCustomWaterColor = false,
    this.whiteNoiseEnabled = false,
    this.whiteNoiseVolume = 0.5,
    this.hasSeenOnboarding = false,
    this.waterColorEvolution = false,
  });

  factory AppSettings.defaults() => AppSettings();

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      sessionGoalMinutes: json['sessionGoalMinutes'] as int? ?? 25,
      focusCheckEnabled: json['focusCheckEnabled'] as bool? ?? false,
      focusCheckIntervalMinutes:
          json['focusCheckIntervalMinutes'] as int? ?? 5,
      infinityModeEnabled: json['infinityModeEnabled'] as bool? ?? false,
      selectedSkin: json['selectedSkin'] as String? ?? 'wood',
      useCustomWaterColor: json['useCustomWaterColor'] as bool? ?? false,
      whiteNoiseEnabled: json['whiteNoiseEnabled'] as bool? ?? false,
      whiteNoiseVolume: (json['whiteNoiseVolume'] as num?)?.toDouble() ?? 0.5,
      hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
      waterColorEvolution: json['waterColorEvolution'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionGoalMinutes': sessionGoalMinutes,
      'focusCheckEnabled': focusCheckEnabled,
      'focusCheckIntervalMinutes': focusCheckIntervalMinutes,
      'infinityModeEnabled': infinityModeEnabled,
      'selectedSkin': selectedSkin,
      'useCustomWaterColor': useCustomWaterColor,
      'whiteNoiseEnabled': whiteNoiseEnabled,
      'whiteNoiseVolume': whiteNoiseVolume,
      'hasSeenOnboarding': hasSeenOnboarding,
      'waterColorEvolution': waterColorEvolution,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          sessionGoalMinutes == other.sessionGoalMinutes &&
          focusCheckEnabled == other.focusCheckEnabled &&
          focusCheckIntervalMinutes == other.focusCheckIntervalMinutes &&
          infinityModeEnabled == other.infinityModeEnabled &&
          selectedSkin == other.selectedSkin &&
          useCustomWaterColor == other.useCustomWaterColor &&
          whiteNoiseEnabled == other.whiteNoiseEnabled &&
          whiteNoiseVolume == other.whiteNoiseVolume &&
          hasSeenOnboarding == other.hasSeenOnboarding &&
          waterColorEvolution == other.waterColorEvolution;

  @override
  int get hashCode => Object.hash(
        sessionGoalMinutes,
        focusCheckEnabled,
        focusCheckIntervalMinutes,
        infinityModeEnabled,
        selectedSkin,
        useCustomWaterColor,
        whiteNoiseEnabled,
        whiteNoiseVolume,
        hasSeenOnboarding,
        waterColorEvolution,
      );
}
