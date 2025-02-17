import 'package:flutter/material.dart';
import 'package:college_project/theme.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  _FitnessScreenState createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _visible = false;

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
                "Workouts",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ..._getWorkoutRoutines().map((workout) => AnimatedWorkoutCard(
                    workout: workout,
                    controller: _controller,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  List<Workout> _getWorkoutRoutines() {
    return [
      Workout(
          title: "Full Body Workout",
          description: "A balanced full-body routine."),
      Workout(
          title: "Cardio Blast",
          description: "Improve stamina with high-energy cardio."),
      Workout(
          title: "Strength Training",
          description: "Build muscle with weight exercises."),
      Workout(
          title: "Flexibility & Mobility",
          description: "Enhance movement and flexibility."),
    ];
  }
}

class Workout {
  final String title;
  final String description;

  Workout({required this.title, required this.description});
}

class AnimatedWorkoutCard extends StatelessWidget {
  final Workout workout;
  final AnimationController controller;

  const AnimatedWorkoutCard({
    super.key,
    required this.workout,
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
                workout.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                workout.description,
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
