import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/app_container.dart';
import 'features/timer/timer_view_model.dart';
import 'features/history/history_view_model.dart';
import 'features/settings/settings_view_model.dart';
import 'features/shop/shop_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = AppContainer();
  await container.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: container.timerViewModel),
        ChangeNotifierProvider.value(value: container.historyViewModel),
        ChangeNotifierProvider.value(value: container.settingsViewModel),
        ChangeNotifierProvider.value(value: container.shopViewModel),
      ],
      child: const RainDropApp(),
    ),
  );
}
