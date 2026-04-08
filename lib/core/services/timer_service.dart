import 'dart:async';

class TimerService {
  Timer? _timer;

  void start(void Function() tick) {
    stop();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      tick();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isRunning => _timer?.isActive ?? false;
}
