import '../core/storage/json_file_store.dart';
import '../core/repositories/focus_session_repository.dart';
import '../core/repositories/settings_repository.dart';
import '../core/repositories/shop_repository.dart';
import '../core/services/timer_service.dart';
import '../core/services/date_service.dart';
import '../features/timer/timer_view_model.dart';
import '../features/history/history_view_model.dart';
import '../features/settings/settings_view_model.dart';
import '../features/shop/shop_view_model.dart';

/// DI Container — mirrors Swift AppContainer
class AppContainer {
  late final JsonFileStore fileStore;
  late final DateService dateService;
  late final FocusSessionRepository sessionRepository;
  late final SettingsRepository settingsRepository;
  late final ShopRepository shopRepository;
  late final TimerService timerService;
  late final TimerViewModel timerViewModel;
  late final HistoryViewModel historyViewModel;
  late final SettingsViewModel settingsViewModel;
  late final ShopViewModel shopViewModel;

  Future<void> initialize() async {
    fileStore = JsonFileStore();
    dateService = DateService();
    sessionRepository = FocusSessionRepository(fileStore: fileStore);
    settingsRepository = SettingsRepository(fileStore: fileStore);
    shopRepository = ShopRepository(fileStore: fileStore);
    timerService = TimerService();

    shopViewModel = ShopViewModel(repository: shopRepository);

    timerViewModel = TimerViewModel(
      timerService: timerService,
      sessionRepository: sessionRepository,
      dateService: dateService,
      settingsRepository: settingsRepository,
      shopRepository: shopRepository,
    );

    historyViewModel = HistoryViewModel(
      repository: sessionRepository,
      dateService: dateService,
    );

    settingsViewModel = SettingsViewModel(
      repository: settingsRepository,
    );
  }
}
