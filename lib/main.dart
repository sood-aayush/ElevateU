import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:college_project/Themes/theme.dart';
import 'package:college_project/Themes/theme_provider.dart';
import 'package:college_project/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SafeArea(child: MainScreen()),
    );
  }
}
