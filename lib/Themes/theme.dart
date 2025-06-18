// app_themes.dart

import 'package:flutter/material.dart';

// --- Custom Theme Extensions ---
@immutable
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

  @override
  String toString() => 'GradientBackground(gradient: $gradient)';
}

@immutable
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
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      selectedItemColor:
          Color.lerp(selectedItemColor, other.selectedItemColor, t)!,
      unselectedItemColor:
          Color.lerp(unselectedItemColor, other.unselectedItemColor, t)!,
    );
  }

  @override
  String toString() =>
      'BottomNavTheme(backgroundColor: $backgroundColor, selectedItemColor: $selectedItemColor, unselectedItemColor: $unselectedItemColor)';
}

@immutable
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

  @override
  String toString() =>
      'CalendarTheme(backgroundColor: $backgroundColor, dayTextColor: $dayTextColor, todayColor: $todayColor, eventColor: $eventColor, borderColor: $borderColor)';
}

// --- AppThemes Class ---
class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF66BB6A), // A gentle, natural green

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF66BB6A),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        textStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, inherit: true),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFFFFFFFF),
      filled: true,
      hintStyle: TextStyle(color: Colors.grey[500]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF66BB6A), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          inherit: true,
          color: Color(0xFF37474F)),
      headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          inherit: true,
          color: Color(0xFF37474F)),
      headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          inherit: true,
          color: Color(0xFF37474F)),
      bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          inherit: true,
          color: Color(0xFF546E7A)),
      bodyMedium: TextStyle(
          fontSize: 16,
          inherit: true,
          color: Color(0xFF546E7A)),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          inherit: true,
          color: Color(0xFF78909C)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF66BB6A),
      unselectedItemColor: Color(0xFF90A4AE),
      elevation: 8,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: MaterialColor(
        0xFF66BB6A, // Primary swatch based on our main green
        <int, Color>{
          50: Color(0xFFE8F5E9),
          100: Color(0xFFC8E6C9),
          200: Color(0xFFA5D6A7),
          300: Color(0xFF81C784),
          400: Color(0xFF66BB6A),
          500: Color(0xFF4CAF50),
          600: Color(0xFF43A047),
          700: Color(0xFF388E3C),
          800: Color(0xFF2E7D32),
          900: Color(0xFF1B5E20),
        },
      ),
      accentColor: const Color(0xFF4FC3F7), // Keeping a soft sky blue for accents
      backgroundColor: const Color(0xFFF9FBFD),
      errorColor: const Color(0xFFEF5350),
      brightness: Brightness.light,
    ).copyWith(
      secondary: const Color(0xFF4FC3F7), // Soft Sky Blue
    ),
    extensions: <ThemeExtension<dynamic>>[
      GradientBackground(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE0F7FA), // Very light Cyan/Aqua
            const Color(0xFFE8F5E9), // Very light Green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      CalendarTheme(
        backgroundColor: Colors.white,
        dayTextColor: const Color(0xFF37474F),
        todayColor: const Color(0xFF66BB6A),
        eventColor: const Color(0xFF4FC3F7),
        borderColor: Colors.grey.shade300,
      ),
      const BottomNavTheme(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF66BB6A),
        unselectedItemColor: Color(0xFF90A4AE),
      ),
    ],
  );

  // --- DARK THEME: Dark Ultramarine + Grey ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF263238), // Deep Blue Grey (almost black for primary)

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A), // Even darker background for app bar
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D47A1), // Dark Ultramarine
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        textStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, inherit: true),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF2C2C2C), // Dark grey fill for input fields
      filled: true,
      hintStyle: TextStyle(color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2), // Dark Ultramarine border on focus
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          inherit: true,
          color: Colors.white), // White for strong contrast
      headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          inherit: true,
          color: Colors.white),
      headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          inherit: true,
          color: Colors.white),
      bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          inherit: true,
          color: Color(0xFFB0BEC5)), // Light Blue Grey for body text
      bodyMedium: TextStyle(fontSize: 16, inherit: true, color: Color(0xFF9E9E9E)), // Medium Grey
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          inherit: true,
          color: Color(0xFF757575)), // Darker Grey for labels
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A), // Matches app bar
      selectedItemColor: Color(0xFF42A5F5), // Brighter Blue (Ultramarine accent) for selected
      unselectedItemColor: Color(0xFF616161), // Darker grey for unselected
      elevation: 8,
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF2C2C2C), // Darker grey for card background
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: MaterialColor( // Custom swatch for Ultramarine
        0xFF0D47A1, // Dark Ultramarine (Primary)
        <int, Color>{
          50: Color(0xFFE3F2FD),
          100: Color(0xFFBBDEFB),
          200: Color(0xFF90CAF9),
          300: Color(0xFF64B5F6),
          400: Color(0xFF42A5F5),
          500: Color(0xFF2196F3),
          600: Color(0xFF1E88E5),
          700: Color(0xFF1976D2),
          800: Color(0xFF1565C0),
          900: Color(0xFF0D47A1), // Main Ultramarine shade
        },
      ),
      accentColor: const Color(0xFF42A5F5), // Brighter Blue (Ultramarine accent)
      backgroundColor: const Color(0xFF121212), // Very dark background
      errorColor: const Color(0xFFEF9A9A), // Standard red for errors (can be adjusted)
      brightness: Brightness.dark,
    ).copyWith(
      secondary: const Color(0xFF42A5F5), // Explicitly set secondary to accent
    ),
    // Theme Extensions
    extensions: <ThemeExtension<dynamic>>[
      GradientBackground(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A), // Dark Grey start
            const Color(0xFF121212), // Even darker Grey end
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      CalendarTheme(
        backgroundColor: const Color(0xFF2C2C2C), // Dark background for calendar
        dayTextColor: Colors.white70,
        todayColor: const Color(0xFF42A5F5), // Ultramarine for 'today'
        eventColor: const Color(0xFF64B5F6), // Slightly lighter Ultramarine for events
        borderColor: Colors.grey.shade700,
      ),
      const BottomNavTheme(
        backgroundColor: Color(0xFF1A1A1A), // Dark grey for bottom nav
        selectedItemColor: Color(0xFF42A5F5), // Bright Ultramarine selected
        unselectedItemColor: Color(0xFF616161), // Dark grey unselected
      ),
    ],
  );
}