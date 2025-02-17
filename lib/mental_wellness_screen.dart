import 'package:flutter/material.dart';
import 'package:college_project/mental_wellness_screen_main.dart';
import 'package:college_project/main_screen.dart';
import 'package:college_project/techniques.dart';
import 'package:college_project/theme.dart';

class MentalWellnessScreen extends StatefulWidget {
  final List<Technique> techniques;
  const MentalWellnessScreen({super.key, required this.techniques});
  @override
  _MentalWellnessScreenState createState() => _MentalWellnessScreenState();
}

class _MentalWellnessScreenState extends State<MentalWellnessScreen> {
  late List<bool> _visibleCards;

  @override
  void initState() {
    super.initState();
    _visibleCards = List.generate(widget.techniques.length, (index) => false);

    Future.delayed(const Duration(milliseconds: 100), () {
      for (int i = 0; i < _visibleCards.length; i++) {
        Future.delayed(Duration(milliseconds: i * 300), () {
          setState(() {
            _visibleCards[i] = true;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              Theme.of(context).extension<GradientBackground>()?.gradient ??
                  LinearGradient(
                    // Fallback gradient if theme extension fails
                    colors: [Colors.teal.shade300, Colors.teal.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView(
            children: [
              const Text(
                "Mindfulness and Meditation",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Guided Meditations Section
              const Text(
                "Guided Meditations",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._buildCardSection(0, 3),

              const SizedBox(height: 20),

              // Breathing Exercises Section
              const Text(
                "Breathing Exercises",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._buildCardSection(3, 6),

              const SizedBox(height: 20),

              // Mindfulness Techniques Section
              const Text(
                "Mindfulness Techniques",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._buildCardSection(6, 9),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build a section of animated cards
  List<Widget> _buildCardSection(int start, int end) {
    return List.generate(end - start, (index) {
      int techniqueIndex = start + index;
      return AnimatedTechniqueCard(
        technique: widget.techniques[techniqueIndex],
        isVisible: _visibleCards[techniqueIndex],
        index: techniqueIndex,
      );
    });
  }
}

// Reusable widget for the animated technique card
class AnimatedTechniqueCard extends StatelessWidget {
  final Technique technique;
  final bool isVisible;
  final int index;

  const AnimatedTechniqueCard({
    super.key,
    required this.technique,
    required this.isVisible,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                technique.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                technique.description,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
