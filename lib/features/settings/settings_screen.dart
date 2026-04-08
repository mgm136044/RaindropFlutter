import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:raindrop_flutter/core/models/bucket_skin.dart';
import 'package:raindrop_flutter/core/utils/time_formatter.dart';
import 'package:raindrop_flutter/features/onboarding/onboarding_view.dart';
import 'package:raindrop_flutter/features/settings/patch_notes_view.dart';
import 'package:raindrop_flutter/features/settings/settings_view_model.dart';
import 'package:raindrop_flutter/features/shop/shop_view_model.dart';
import 'package:raindrop_flutter/shared/components/glass_container.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  final int totalBuckets;

  const SettingsScreen({super.key, this.totalBuckets = 0});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _goalController = TextEditingController();
  final _intervalController = TextEditingController();
  final _goalFocus = FocusNode();
  final _intervalFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _goalFocus.addListener(_onGoalFocusChange);
    _intervalFocus.addListener(_onIntervalFocusChange);
  }

  @override
  void dispose() {
    _goalController.dispose();
    _intervalController.dispose();
    _goalFocus.removeListener(_onGoalFocusChange);
    _intervalFocus.removeListener(_onIntervalFocusChange);
    _goalFocus.dispose();
    _intervalFocus.dispose();
    super.dispose();
  }

  void _onGoalFocusChange() {
    if (!_goalFocus.hasFocus) _clampAndSaveGoal();
  }

  void _onIntervalFocusChange() {
    if (!_intervalFocus.hasFocus) _clampAndSaveInterval();
  }

  void _clampAndSaveGoal() {
    final vm = context.read<SettingsViewModel>();
    final value = int.tryParse(_goalController.text) ?? vm.settings.sessionGoalMinutes;
    vm.settings.sessionGoalMinutes = value.clamp(25, 120);
    _goalController.text = vm.settings.sessionGoalMinutes.toString();
    vm.save();
  }

  void _clampAndSaveInterval() {
    final vm = context.read<SettingsViewModel>();
    final value = int.tryParse(_intervalController.text) ?? vm.settings.focusCheckIntervalMinutes;
    vm.settings.focusCheckIntervalMinutes = value.clamp(1, 60);
    _intervalController.text = vm.settings.focusCheckIntervalMinutes.toString();
    vm.save();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        _goalController.text = vm.settings.sessionGoalMinutes.toString();
        _intervalController.text =
            vm.settings.focusCheckIntervalMinutes.toString();

        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildFocusGoalSection(context, vm),
                    const SizedBox(height: 12),
                    _buildFocusCheckSection(context, vm),
                    const SizedBox(height: 12),
                    _buildGrowthSection(context),
                    const SizedBox(height: 12),
                    _buildSkinSection(context, vm),
                    const SizedBox(height: 12),
                    _buildOtherSection(context),
                    if (vm.latestError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        vm.latestError!,
                        style: TextStyle(color: AppColors.danger(context)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '설정',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText(context),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('완료',
                  style: TextStyle(color: AppColors.accent(context))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // -- Focus Goal Section --

  Widget _buildFocusGoalSection(BuildContext context, SettingsViewModel vm) {
    return _sectionCard('집중 목표', [
      SwitchListTile(
        title: const Text('무한 모드 (\u221E)'),
        value: vm.settings.infinityModeEnabled,
        onChanged: (val) {
          vm.settings.infinityModeEnabled = val;
          vm.save();
        },
      ),
      ListTile(
        title: const Text('양동이 채움 목표 시간'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vm.settings.infinityModeEnabled)
              const Text(
                '\u221E',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              )
            else
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _goalController,
                  focusNode: _goalFocus,
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _clampAndSaveGoal(),
                ),
              ),
            const SizedBox(width: 4),
            Text('분',
                style:
                    TextStyle(color: AppColors.secondaryText(context))),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Text(
          vm.settings.infinityModeEnabled
              ? '${vm.settings.sessionGoalMinutes}분마다 양동이가 순환됩니다. 순환마다 양동이 코인 1개가 적립됩니다.'
              : '25 ~ 120분',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.tertiaryText(context),
          ),
        ),
      ),
    ]);
  }

  // -- Focus Check Section --

  Widget _buildFocusCheckSection(BuildContext context, SettingsViewModel vm) {
    return _sectionCard('집중 감시 알림', [
      SwitchListTile(
        title: const Text('집중 확인 알림'),
        value: vm.settings.focusCheckEnabled,
        onChanged: (val) {
          vm.settings.focusCheckEnabled = val;
          vm.save();
        },
      ),
      if (vm.settings.focusCheckEnabled) ...[
        ListTile(
          title: const Text('알림 간격'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _intervalController,
                  focusNode: _intervalFocus,
                  textAlign: TextAlign.end,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _clampAndSaveInterval(),
                ),
              ),
              const SizedBox(width: 4),
              Text('분',
                  style:
                      TextStyle(color: AppColors.secondaryText(context))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            '1 ~ 60분',
            style: TextStyle(
                fontSize: 12, color: AppColors.tertiaryText(context)),
          ),
        ),
      ],
    ]);
  }

  // -- Growth Section --

  Widget _buildGrowthSection(BuildContext context) {
    final shopVM = context.watch<ShopViewModel>();

    return _sectionCard('성장 현황', [
      ListTile(
        title: const Text('환경'),
        trailing: Text(
          '${shopVM.currentEnvironmentStage.emoji} ${shopVM.currentEnvironmentStage.displayName}',
          style: TextStyle(color: AppColors.accent(context)),
        ),
      ),
      if (shopVM.minutesToNextStage != null)
        ListTile(
          title: const Text('다음 단계까지'),
          trailing: Text(
            '${shopVM.minutesToNextStage}분',
            style: TextStyle(color: AppColors.secondaryText(context)),
          ),
        ),
      ListTile(
        title: const Text('날씨'),
        trailing: Text(
          '${shopVM.currentWeather.emoji} ${shopVM.currentWeather.displayName}',
          style: TextStyle(color: AppColors.secondaryText(context)),
        ),
      ),
      ListTile(
        title: const Text('연속 집중일수'),
        trailing: Text(
          '${shopVM.shopState.consecutiveFocusDays}일',
          style: TextStyle(color: AppColors.accent(context)),
        ),
      ),
      ListTile(
        title: const Text('총 집중 시간'),
        trailing: Text(
          TimeFormatter.compactDuration(
              shopVM.shopState.totalFocusMinutes * 60),
          style: TextStyle(color: AppColors.secondaryText(context)),
        ),
      ),
    ]);
  }

  // -- Skin Section --

  Widget _buildSkinSection(BuildContext context, SettingsViewModel vm) {
    final currentSkin = BucketSkin.fromString(vm.settings.selectedSkin);

    return _sectionCard('환경 선택', [
      ...BucketSkin.values.map((skin) {
        final unlocked = skin.isUnlocked(widget.totalBuckets);
        final isSelected = currentSkin == skin;

        return InkWell(
          onTap: unlocked
              ? () {
                  vm.settings.selectedSkin = skin.name;
                  vm.save();
                }
              : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.accent(context)
                      : AppColors.secondaryText(context),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            skin.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: unlocked
                                  ? AppColors.primaryText(context)
                                  : AppColors.secondaryText(context),
                            ),
                          ),
                          if (!unlocked) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.lock,
                                size: 11,
                                color:
                                    AppColors.secondaryText(context)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        unlocked
                            ? skin.materialDescription
                            : '\u{1FAA3} ${skin.requiredBuckets}번 채움 시 해금',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.tertiaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: skin.bucketFill,
                    border: Border.all(color: skin.bucketStroke, width: 2),
                  ),
                  child: Opacity(
                    opacity: unlocked ? 1.0 : 0.4,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      const Divider(height: 1),
      SwitchListTile(
        title: const Text('물 색상 자연 진화'),
        value: vm.settings.waterColorEvolution,
        onChanged: (val) {
          vm.settings.waterColorEvolution = val;
          vm.save();
        },
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          '집중 시간이 쌓일수록 물의 색이 깊어집니다.',
          style: TextStyle(
              fontSize: 12, color: AppColors.tertiaryText(context)),
        ),
      ),
      if (!vm.settings.waterColorEvolution &&
          currentSkin.hasCustomWaterColor) ...[
        SwitchListTile(
          title: const Text('스킨 색 물 사용'),
          value: vm.settings.useCustomWaterColor,
          onChanged: (val) {
            vm.settings.useCustomWaterColor = val;
            vm.save();
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            '물과 물방울의 색을 스킨 색상에 맞춥니다.',
            style: TextStyle(
                fontSize: 12, color: AppColors.tertiaryText(context)),
          ),
        ),
      ],
    ]);
  }

  // -- Other Section --

  Widget _buildOtherSection(BuildContext context) {
    return _sectionCard('기타', [
      ListTile(
        title: const Text('패치노트'),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const Dialog(
              child: PatchNotesView(),
            ),
          );
        },
      ),
      ListTile(
        title: const Text('온보딩 다시 보기'),
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: OnboardingView(
                onComplete: () => Navigator.pop(context),
              ),
            ),
          );
        },
      ),
    ]);
  }
}
