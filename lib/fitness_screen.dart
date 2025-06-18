import 'package:flutter/material.dart';

import 'package:college_project/OMW/techniques.dart';
import 'package:college_project/Themes/theme.dart';

class FitnessScreen extends StatefulWidget {
  final List<Technique> techniques;
  const FitnessScreen({super.key, required this.techniques});
  @override
  _FitnessScreenState createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen>
    with TickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _visible = true;
        _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                "Techniques",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...widget.techniques.map((technique) => AnimatedTechniqueCard(
                  technique: technique, controller: _controller)),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedTechniqueCard extends StatelessWidget {
  final Technique technique;
  final AnimationController controller;

  const AnimatedTechniqueCard({
    super.key,
    required this.technique,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: controller,
          child: child,
        );
      },
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
