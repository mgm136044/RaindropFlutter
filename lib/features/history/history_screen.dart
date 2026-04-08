import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raindrop_flutter/core/models/bucket_skin.dart';
import 'package:raindrop_flutter/core/utils/time_formatter.dart';
import 'package:raindrop_flutter/features/history/calendar_heatmap.dart';
import 'package:raindrop_flutter/features/history/history_view_model.dart';
import 'package:raindrop_flutter/features/history/weekly_density_view.dart';
import 'package:raindrop_flutter/shared/components/glass_container.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

enum HistoryTab { monthly, weekly, sessions }

class HistoryScreen extends StatefulWidget {
  final BucketSkin skin;

  const HistoryScreen({super.key, this.skin = BucketSkin.wood});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryTab _selectedTab = HistoryTab.monthly;

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context, viewModel),
              if (viewModel.isEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildEmptyState(context, viewModel),
                  ),
                )
              else
                Expanded(child: _buildTabContent(context, viewModel)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, HistoryViewModel viewModel) {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '히스토리',
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
                  child: Text(
                    '완료',
                    style: TextStyle(color: AppColors.accent(context)),
                  ),
                ),
              ),
            ],
          ),
          if (!viewModel.isEmpty) ...[
            const SizedBox(height: 10),
            SegmentedButton<HistoryTab>(
              segments: const [
                ButtonSegment(value: HistoryTab.monthly, label: Text('월간')),
                ButtonSegment(value: HistoryTab.weekly, label: Text('주간')),
                ButtonSegment(
                    value: HistoryTab.sessions, label: Text('세션 기록')),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (set) =>
                  setState(() => _selectedTab = set.first),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, HistoryViewModel viewModel) {
    return SingleChildScrollView(
      child: switch (_selectedTab) {
        HistoryTab.monthly => Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: CalendarHeatmapView(
              dailyData: viewModel.dailyTotals,
              dateService: viewModel.dateService,
              dailyBucketCounts: viewModel.dailyBucketCounts,
              skin: widget.skin,
            ),
          ),
        HistoryTab.weekly => Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: WeeklyDensityView(
              dailyData: viewModel.dailyTotals,
              dailyBucketCounts: viewModel.dailyBucketCounts,
              dateService: viewModel.dateService,
              skin: widget.skin,
            ),
          ),
        HistoryTab.sessions => _buildHistoryList(context, viewModel),
      },
    );
  }

  Widget _buildHistoryList(BuildContext context, HistoryViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Column(
        children: viewModel.summaries.map((summary) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.panelBackground(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        summary.displayDate,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        TimeFormatter.clockString(summary.totalSeconds),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...summary.sessions.map((session) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            viewModel.timeRangeText(session),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            TimeFormatter.clockString(session.durationSeconds),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HistoryViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.water_drop,
            size: 44,
            color: AppColors.accent(context),
          ),
          const SizedBox(height: 18),
          const Text(
            '아직 저장된 집중 기록이 없습니다.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Text(
            '첫 세션을 완료하면 여기에서 날짜별 기록을 볼 수 있습니다.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText(context),
            ),
          ),
          if (viewModel.latestError != null) ...[
            const SizedBox(height: 12),
            Text(
              viewModel.latestError!,
              style: TextStyle(color: AppColors.danger(context)),
            ),
          ],
        ],
      ),
    );
  }
}
