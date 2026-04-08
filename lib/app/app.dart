import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/timer/timer_screen.dart';
import '../features/timer/timer_view_model.dart';

class RainDropApp extends StatelessWidget {
  const RainDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RainDrop',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF0071E3),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2997FF),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const TimerScreen(),
    );
  }
}
