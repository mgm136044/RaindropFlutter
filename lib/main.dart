import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/app_container.dart';
import 'features/timer/timer_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = AppContainer();
  await container.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: container.timerViewModel),
      ],
      child: const RainDropApp(),
    ),
  );
}
