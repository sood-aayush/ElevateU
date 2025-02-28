import 'package:college_project/academics_screen_main.dart';
import 'package:college_project/fitness_screen.dart';
import 'package:college_project/homescreen.dart';
import 'package:college_project/mental_wellness_screen_main.dart';
import 'package:college_project/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:college_project/OMW/techniques.dart';
import 'package:college_project/Themes/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  // Define a GlobalKey to access the HomeScreen's state.
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  // Initialize your technique lists.
  late final List<Technique> academicsTechniques;
  late final List<Technique> meditationTechniques;

  @override
  void initState() {
    super.initState();

    // Replace these initializations with your actual technique data.
    academicsTechniques = [
      Technique(
        title: "Pomodoro Technique",
        description:
            "A time-management method that improves focus and productivity.\n\n"
            "- Work for 25 minutes, then take a 5-minute break.\n"
            "- After four sessions, take a longer break of 15-30 minutes.",
      ),
      Technique(
        title: "Active Recall",
        description:
            "An evidence-based technique where you quiz yourself to actively retrieve information.\n\n"
            "- Use flashcards or self-quizzing to test your knowledge without looking at notes.",
      ),
      Technique(
        title: "Spaced Repetition",
        description:
            "Revisit material at increasing intervals to strengthen long-term memory.\n\n"
            "- Review content after 1 day, 3 days, 1 week, and so on.",
      ),
      Technique(
        title: "Feynman Technique",
        description:
            "An active learning method that involves teaching a concept to someone else.\n\n"
            "- Simplify complex topics and explain them in your own words as if teaching a beginner.",
      ),
      Technique(
        title: "SQ3R Method",
        description:
            "A reading comprehension technique for efficient studying.\n\n"
            "- Survey: Skim the material.\n"
            "- Question: Formulate questions.\n"
            "- Read: Focus on answering the questions.\n"
            "- Recite: Summarize the key points.\n"
            "- Review: Go over the material.",
      ),
      Technique(
        title: "Mind Mapping",
        description:
            "A visual way of organizing information, making complex ideas easier to understand.\n\n"
            "- Draw a diagram with the main concept in the center, branching out with subtopics.",
      ),
      Technique(
        title: "Leitner System",
        description: "A form of spaced repetition using flashcards.\n\n"
            "- Group flashcards into boxes based on how well you know them.\n"
            "- Review more difficult cards frequently and known ones less often.",
      ),
    ]; // e.g., getAcademicsTechniques();
    meditationTechniques = [
      Technique(
        title: "Beach Visualization",
        description:
            "Imagine a serene beach. Engage your senses: listen to the waves, feel the warmth of the sun, and smell the salt in the air.",
      ),
      Technique(
        title: "Forest Walk Visualization",
        description:
            "Visualize walking through a peaceful forest. Notice the tall trees, feel the crunch of leaves beneath your feet, and breathe in the scents of the woods.",
      ),
      Technique(
        title: "Mountain Meditation",
        description:
            "Picture yourself ascending a mountain. Feel your strength grow with each step as you reach the summit and reflect on your challenges.",
      ),
      Technique(
        title: "4-7-8 Breathing Technique",
        description:
            "Inhale for 4 seconds, hold for 7, and exhale for 8. This technique calms your nervous system.",
      ),
      Technique(
        title: "Box Breathing",
        description:
            "Inhale for 4 seconds, hold for 4, exhale for 4, and hold for 4. This exercise helps restore calm and focus.",
      ),
      Technique(
        title: "Diaphragmatic Breathing",
        description:
            "Breathe deeply into your belly, allowing the breath to fill your abdomen. This promotes relaxation and reduces stress.",
      ),
      Technique(
        title: "Basic Mindful Breathing",
        description:
            "Observe your breath as it flows in and out, bringing awareness to each inhalation and exhalation.",
      ),
      Technique(
        title: "Deep Belly Breathing",
        description:
            "Focus on expanding your belly while breathing deeply, activating your body's relaxation response.",
      ),
      Technique(
        title: "Lion's Breath",
        description:
            "Inhale deeply and exhale with a roaring sound. This playful exercise releases tension and energizes your body.",
      ),
    ]; // e.g., getMeditationTechniques();

    _screens = [
      // Pass the GlobalKey to HomeScreen.
      HomeScreen(key: _homeScreenKey, changeIndex: _changeIndex),
      AcademicsMainScreen(
        techniques: academicsTechniques,
        onEventSelected: _handleEventSelected,
      ),
      MentalWellnessScreenMain(
        techniques: meditationTechniques,
      ),
      const FitnessScreen(),
      const ProfileScreen(),
    ];
  }

  // Callback with the correct signature.
  void _handleEventSelected(String technique, DateTime dateTime) {
    _homeScreenKey.currentState?.addEvent(technique, dateTime);
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

    // Get the theme extensions.
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
