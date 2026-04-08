import 'package:flutter/material.dart';

class OnboardingView extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingView({super.key, required this.onComplete});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _currentScene = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 520,
      height: 450,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Scene indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentScene >= index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
          // Scene content
          Expanded(child: _buildScene()),
        ],
      ),
    );
  }

  Widget _buildScene() {
    switch (_currentScene) {
      case 0:
        return _buildBucketScene();
      case 1:
        return _buildFillScene();
      case 2:
        return _buildGrowthScene();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBucketScene() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.water_drop, size: 80, color: Colors.blue),
        const SizedBox(height: 24),
        const Text('이것이 당신의 하루입니다',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => _currentScene = 1),
          child: const Text('다음'),
        ),
      ],
    );
  }

  Widget _buildFillScene() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.hourglass_bottom, size: 80, color: Colors.blue),
        const SizedBox(height: 24),
        const Text('집중이 쌓이면 양동이가 채워집니다',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => setState(() => _currentScene = 2),
          child: const Text('다음'),
        ),
      ],
    );
  }

  Widget _buildGrowthScene() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🌱🌸🌳🌲🏞️', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 24),
        const Text('매일의 집중이 당신만의 세계를 만듭니다',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: widget.onComplete,
          child: const Text('시작하기'),
        ),
      ],
    );
  }
}
