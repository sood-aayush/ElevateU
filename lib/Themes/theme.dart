import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 9, 184, 166),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        textStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, inherit: true),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge:
          TextStyle(fontSize: 32, fontWeight: FontWeight.bold, inherit: true),
      headlineMedium:
          TextStyle(fontSize: 24, fontWeight: FontWeight.bold, inherit: true),
      bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          inherit: true,
          color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 16, inherit: true, color: Colors.black87),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          inherit: true,
          color: Colors.black87),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
    ),
    extensions: <ThemeExtension<dynamic>>[
      GradientBackground(
        gradient: LinearGradient(
          colors: [Colors.teal.shade300, Colors.teal.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      CalendarTheme(
        backgroundColor: Colors.white,
        dayTextColor: Colors.black87,
        todayColor: Colors.teal.shade700,
        eventColor: Colors.teal,
        borderColor: Colors.grey.shade300,
      ),
      BottomNavTheme(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey[900],
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E2C),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, inherit: true),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          inherit: true,
          color: Colors.white),
      headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          inherit: true,
          color: Colors.white),
      bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          inherit: true,
          color: Colors.white),
      bodyMedium: TextStyle(fontSize: 16, inherit: true, color: Colors.white70),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          inherit: true,
          color: Colors.white70),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E2C),
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.grey,
    ),
    extensions: <ThemeExtension<dynamic>>[
      GradientBackground(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade900, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      CalendarTheme(
        backgroundColor: Colors.black87,
        dayTextColor: Colors.white70,
        todayColor: Colors.cyan,
        eventColor: Colors.cyanAccent,
        borderColor: Colors.grey.shade800,
      ),
      BottomNavTheme(
        backgroundColor: Color(0xFF1E1E2C),
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
      ),
    ],
  );
}

// Custom Theme Extension for Gradients
class GradientBackground extends ThemeExtension<GradientBackground> {
  final LinearGradient gradient;
  const GradientBackground({required this.gradient});

  @override
  GradientBackground copyWith({LinearGradient? gradient}) {
    return GradientBackground(gradient: gradient ?? this.gradient);
  }

  @override
  GradientBackground lerp(
      covariant ThemeExtension<GradientBackground>? other, double t) {
    if (other is! GradientBackground) return this;
    return GradientBackground(gradient: other.gradient);
  }
}

// Custom Theme Extension for Bottom Navigation Bar Styling
class BottomNavTheme extends ThemeExtension<BottomNavTheme> {
  final Color backgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const BottomNavTheme({
    required this.backgroundColor,
    required this.selectedItemColor,
    required this.unselectedItemColor,
  });

  @override
  BottomNavTheme copyWith(
      {Color? backgroundColor,
      Color? selectedItemColor,
      Color? unselectedItemColor}) {
    return BottomNavTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      unselectedItemColor: unselectedItemColor ?? this.unselectedItemColor,
    );
  }

  @override
  BottomNavTheme lerp(
      covariant ThemeExtension<BottomNavTheme>? other, double t) {
    if (other is! BottomNavTheme) return this;
    return BottomNavTheme(
      backgroundColor: other.backgroundColor,
      selectedItemColor: other.selectedItemColor,
      unselectedItemColor: other.unselectedItemColor,
    );
  }
}

class CalendarTheme extends ThemeExtension<CalendarTheme> {
  final Color backgroundColor;
  final Color dayTextColor;
  final Color todayColor;
  final Color eventColor;
  final Color borderColor;

  const CalendarTheme({
    required this.backgroundColor,
    required this.dayTextColor,
    required this.todayColor,
    required this.eventColor,
    required this.borderColor,
  });

  @override
  CalendarTheme copyWith(
      {Color? backgroundColor,
      Color? dayTextColor,
      Color? todayColor,
      Color? eventColor,
      Color? borderColor}) {
    return CalendarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dayTextColor: dayTextColor ?? this.dayTextColor,
      todayColor: todayColor ?? this.todayColor,
      eventColor: eventColor ?? this.eventColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  CalendarTheme lerp(covariant ThemeExtension<CalendarTheme>? other, double t) {
    if (other is! CalendarTheme) return this;
    return CalendarTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      dayTextColor: Color.lerp(dayTextColor, other.dayTextColor, t)!,
      todayColor: Color.lerp(todayColor, other.todayColor, t)!,
      eventColor: Color.lerp(eventColor, other.eventColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
    );
  }
}
