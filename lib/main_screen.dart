import 'package:college_project/academics_screen_main.dart';
import 'package:college_project/fitness_screen.dart';
import 'package:college_project/homescreen.dart';
import 'package:college_project/mental_wellness_screen_main.dart';
import 'package:college_project/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:college_project/techniques.dart';
import 'package:college_project/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(changeIndex: _changeIndex),
      AcademicsMainScreen(
        techniques: academicsTechniques,
      ),
      MentalWellnessScreenMain(
        techniques: meditationTechniques,
      ),
      const FitnessScreen(),
      const ProfileScreen(),
    ];
  }

  void _changeIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE, MMM d').format(now);

    // Get the theme extensions
    final gradient =
        Theme.of(context).extension<GradientBackground>()!.gradient;
    final bottomNavTheme = Theme.of(context).extension<BottomNavTheme>()!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _changeIndex,
        backgroundColor: bottomNavTheme.backgroundColor, // Themed Background
        selectedItemColor:
            bottomNavTheme.selectedItemColor, // Themed Selected Item
        unselectedItemColor:
            bottomNavTheme.unselectedItemColor, // Themed Unselected Item
        selectedIconTheme: const IconThemeData(size: 30),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Academics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Wellness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Fitness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        enableFeedback: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: gradient, // Apply the theme-based gradient background
        ),
        child: SafeArea(child: _screens[_currentIndex]),
      ),
    );
  }
}
