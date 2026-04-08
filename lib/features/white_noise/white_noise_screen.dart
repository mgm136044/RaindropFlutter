import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raindrop_flutter/features/settings/settings_view_model.dart';
import 'package:raindrop_flutter/shared/components/glass_container.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

class WhiteNoiseScreen extends StatelessWidget {
  const WhiteNoiseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildMainSection(context, vm),
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
            '백색소음',
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

  Widget _buildMainSection(BuildContext context, SettingsViewModel vm) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('빗소리 백색소음'),
            value: vm.settings.whiteNoiseEnabled,
            onChanged: (val) {
              vm.settings.whiteNoiseEnabled = val;
              vm.save();
            },
          ),
          if (vm.settings.whiteNoiseEnabled) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('볼륨'),
                  Expanded(
                    child: Slider(
                      value: vm.settings.whiteNoiseVolume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      onChanged: (val) {
                        vm.settings.whiteNoiseVolume = val;
                        vm.save();
                      },
                    ),
                  ),
                ],
              ),
            ),
            // WebView placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.secondaryText(context)
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 32,
                        color: AppColors.secondaryText(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'WebView 플레이어',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                      Text(
                        '(플랫폼 플러그인 필요)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.tertiaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                '위 플레이어에서 재생 버튼을 눌러주세요. 인터넷 연결이 필요합니다.\n'
                '재생 버튼이 보이지 않으면 플레이어를 우클릭하여 \'페이지 리로드\'를 선택하세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tertiaryText(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
