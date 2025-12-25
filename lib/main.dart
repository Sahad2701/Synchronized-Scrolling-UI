import 'package:flutter/material.dart';
import 'package:synchronized_scroll_mobile_ui/theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SynchronizedScrollApp());
}

class SynchronizedScrollApp extends StatelessWidget {
  const SynchronizedScrollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synchronized Scroll UI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
