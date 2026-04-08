import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:raindrop_flutter/core/models/focus_session.dart';
import 'package:raindrop_flutter/core/models/timer_state.dart';
import 'package:raindrop_flutter/core/repositories/focus_session_repository.dart';
import 'package:raindrop_flutter/core/repositories/settings_repository.dart';
import 'package:raindrop_flutter/core/repositories/shop_repository.dart';
import 'package:raindrop_flutter/core/services/date_service.dart';
import 'package:raindrop_flutter/core/services/timer_service.dart';
import 'package:raindrop_flutter/core/utils/time_formatter.dart';

/// Timer ViewModel -- ChangeNotifier port of TimerViewModel.swift (320 LOC).
/// Manages timer lifecycle, progress, infinity mode with cycle draining,
/// overflow animation, and water level state.
class TimerViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------
  final TimerService _timerService;
  final FocusSessionRepository _sessionRepository;
  final DateService _dateService;
  final SettingsRepository _settingsRepository;
  final ShopRepository _shopRepository;

  TimerViewModel({
    required TimerService timerService,
    required FocusSessionRepository sessionRepository,
    required DateService dateService,
    required SettingsRepository settingsRepository,
    required ShopRepository shopRepository,
  })  : _timerService = timerService,
        _sessionRepository = sessionRepository,
        _dateService = dateService,
        _settingsRepository = settingsRepository,
        _shopRepository = shopRepository {
    _loadSettings();
    _loadTodayTotal();
  }

  // ---------------------------------------------------------------------------
  // Published state
  // ---------------------------------------------------------------------------
  TimerState _timerState = TimerState.idle;
  int _elapsedSeconds = 0;
  int _todayTotalSeconds = 0;
  double _currentProgress = 0;
  bool _isDraining = false;
  FocusSession? _lastCompletedSession;
  String? _latestError;
  int _sessionGoalSeconds = 25 * 60;
  bool _isInfinityMode = false;
  int _cycleCount = 0;
  bool _isCycleDraining = false;
  int _lastCycleCount = 0;
  bool _isOverflowing = false;

  // Private
  DateTime? _sessionStartTime;
  int _activeGoalSeconds = 0;
  bool _activeInfinityMode = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  TimerState get timerState => _timerState;
  int get elapsedSeconds => _elapsedSeconds;
  int get todayTotalSeconds => _todayTotalSeconds;
  double get currentProgress => _currentProgress;
  bool get isDraining => _isDraining;
  FocusSession? get lastCompletedSession => _lastCompletedSession;
  String? get latestError => _latestError;
  int get sessionGoalSeconds => _sessionGoalSeconds;
  bool get isInfinityMode => _isInfinityMode;
  int get cycleCount => _cycleCount;
  bool get isCycleDraining => _isCycleDraining;
  int get lastCycleCount => _lastCycleCount;
  bool get isOverflowing => _isOverflowing;

  String get timerText => TimeFormatter.clockString(_elapsedSeconds);
  String get todayTotalText => TimeFormatter.clockString(_todayTotalSeconds);

  String get goalText {
    if (_isInfinityMode) return '무한 모드 - 순환마다 코인 적립';
    return '${_sessionGoalSeconds ~/ 60}분 집중 시 양동이 가득';
  }

  String? get cycleText {
    if (!_isInfinityMode) return null;
    if (_timerState != TimerState.running &&
        _timerState != TimerState.paused) {
      return null;
    }
    return '${_cycleCount + 1}번째 순환 중';
  }

  bool get isRunning => _timerState == TimerState.running;
  bool get canStart =>
      _timerState == TimerState.idle ||
      _timerState == TimerState.completed;
  bool get canPause => _timerState == TimerState.running;
  bool get canResume => _timerState == TimerState.paused;
  bool get canStop =>
      _timerState == TimerState.running ||
      _timerState == TimerState.paused;

  String get waterLevelDescription {
    if (_currentProgress < 0.05) return '바닥';
    if (_currentProgress < 0.3) return '조금';
    if (_currentProgress < 0.55) return '반쯤';
    if (_currentProgress < 0.85) return '많이';
    if (_currentProgress < 1.0) return '거의 가득';
    return '가득!';
  }

  // ---------------------------------------------------------------------------
  // Timer lifecycle
  // ---------------------------------------------------------------------------
  void start() {
    if (!canStart) return;
    _latestError = null;
    _lastCompletedSession = null;
    _elapsedSeconds = 0;
    _currentProgress = 0;
    _cycleCount = 0;
    _isCycleDraining = false;
    _activeGoalSeconds = _sessionGoalSeconds;
    _activeInfinityMode = _isInfinityMode;
    _sessionStartTime = DateTime.now();
    _timerState = TimerState.running;
    _startTimerTicks();
    notifyListeners();
  }

  void pause() {
    if (!canPause) return;
    _timerService.stop();
    _timerState = TimerState.paused;
    notifyListeners();
  }

  void resume() {
    if (!canResume) return;
    _timerState = TimerState.running;
    _startTimerTicks();
    notifyListeners();
  }

  void stop() {
    if (!canStop) return;
    _timerService.stop();

    final endTime = DateTime.now();
    final elapsed = _elapsedSeconds;
    _lastCycleCount = _cycleCount;

    if (_sessionStartTime != null && elapsed > 0) {
      final dateKey = _dateService.dateKey(_sessionStartTime!);
      final session = FocusSession(
        startTime: _sessionStartTime!,
        endTime: endTime,
        durationSeconds: elapsed,
        dateKey: dateKey,
        goalSeconds: _activeInfinityMode ? null : _activeGoalSeconds,
      );

      _sessionRepository.save(session).then((_) {
        _lastCompletedSession = session;
        _loadTodayTotal();
        notifyListeners();
      }).catchError((_) {
        _latestError = '기록 저장에 실패했습니다.';
        notifyListeners();
      });
    }

    _timerState = TimerState.completed;
    _sessionStartTime = null;
    _elapsedSeconds = 0;
    _cycleCount = 0;
    _isCycleDraining = false;
    _isDraining = true;
    triggerOverflow();
    notifyListeners();
  }

  void finishDraining() {
    _currentProgress = 0;
    _isDraining = false;
    _clearOverflow();
    notifyListeners();
  }

  void finishCycleDraining() {
    _cycleCount += 1;
    final goal = _activeGoalSeconds;
    if (goal > 0) {
      final elapsedInCycle = _elapsedSeconds % goal;
      _currentProgress = elapsedInCycle / goal;
    }
    _isCycleDraining = false;
    _clearOverflow();
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _timerService.stop();
    super.dispose();
  }

  void triggerOverflow() {
    _isOverflowing = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      if (_disposed) return;
      _isOverflowing = false;
      notifyListeners();
    });
  }

  void resetCompletionStateIfNeeded() {
    _lastCompletedSession = null;
    if (_timerState == TimerState.completed) {
      _timerState = TimerState.idle;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------
  void _clearOverflow() {
    _isOverflowing = false;
  }

  void _startTimerTicks() {
    _timerService.start(() {
      _elapsedSeconds += 1;

      if (_activeInfinityMode) {
        final goal = _activeGoalSeconds;
        if (goal <= 0) return;
        final elapsedInCycle = _elapsedSeconds % goal;

        if (elapsedInCycle == 0 && !_isCycleDraining) {
          _currentProgress = 1.0;
          _isCycleDraining = true;
          triggerOverflow();
        } else if (!_isCycleDraining) {
          _currentProgress = elapsedInCycle / goal;
        }
      } else {
        _currentProgress =
            (_elapsedSeconds / _activeGoalSeconds).clamp(0.0, 1.0);
      }
      notifyListeners();
    });
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsRepository.load();
      _sessionGoalSeconds = settings.sessionGoalSeconds;
      _isInfinityMode = settings.infinityModeEnabled;
      notifyListeners();
    } catch (_) {
      // Use defaults
    }
  }

  Future<void> _loadTodayTotal() async {
    try {
      final todayKey = _dateService.dateKey(DateTime.now());
      final sessions = await _sessionRepository.fetchByDateKey(todayKey);
      _todayTotalSeconds =
          sessions.fold(0, (sum, s) => sum + s.durationSeconds);
      notifyListeners();
    } catch (_) {
      _latestError = '기록을 불러오지 못했습니다.';
      notifyListeners();
    }
  }

}
