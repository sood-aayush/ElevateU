import 'package:flutter/material.dart';

import 'package:college_project/calendar_widget.dart';
import 'package:college_project/theme.dart';
import 'package:college_project/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) changeIndex;
  const HomeScreen({super.key, required this.changeIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CalendarWidget(),
            const Card(
                //percentage widget
                ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            const Text(
              'What do you want to work on',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset('assets/Academics.jpeg'))),
                    Text("Academics")
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    changeIndex(2);
                  },
                  icon: const Icon(
                    Icons.self_improvement,
                  ),
                  label: const Text(
                    'Wellness',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    changeIndex(3);
                  },
                  icon: const Icon(
                    Icons.fitness_center,
                  ),
                  label: const Text(
                    'Fitness',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
