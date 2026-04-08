import 'package:flutter/material.dart';

enum HistoryTab { monthly, weekly, sessions }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryTab _selectedTab = HistoryTab.monthly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '히스토리',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('완료'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<HistoryTab>(
        segments: const [
          ButtonSegment(value: HistoryTab.monthly, label: Text('월간')),
          ButtonSegment(value: HistoryTab.weekly, label: Text('주간')),
          ButtonSegment(value: HistoryTab.sessions, label: Text('세션 기록')),
        ],
        selected: {_selectedTab},
        onSelectionChanged: (set) => setState(() => _selectedTab = set.first),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case HistoryTab.monthly:
        return const Center(child: Text('월간 밀도 캘린더'));
      case HistoryTab.weekly:
        return const Center(child: Text('주간 밀도 뷰'));
      case HistoryTab.sessions:
        return const Center(child: Text('세션 기록 리스트'));
    }
  }
}
