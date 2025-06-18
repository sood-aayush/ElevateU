import 'package:college_project/OMW/daily_task_card.dart';
import 'package:college_project/OMW/progress_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:college_project/OMW/calendar_widget.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) changeIndex;
  const HomeScreen({super.key, required this.changeIndex});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CurrentStats()),
              ),
              child: const DailyTaskCard(taskCount: 6),
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
                child: InkWell(
                  onTap: () {
                    widget.changeIndex(1);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/Academics.jpeg',
                        ),
                      ),
                      const Text(
                        "Academics",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                child: InkWell(
                  onTap: () {
                    widget.changeIndex(2);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/Wellness.jpg',
                        ),
                      ),
                      const Text(
                        "Wellness",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                child: InkWell(
                  onTap: () {
                    widget.changeIndex(3);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/Fitness.jpg',
                        ),
                      ),
                      const Text(
                        "Fitness",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class CurrentStats extends StatefulWidget {
  const CurrentStats({super.key});

  @override
  State<CurrentStats> createState() => _CurrentStatsState();
}

class _CurrentStatsState extends State<CurrentStats> {
  List<Map<String, dynamic>> events = [];

  void addEvent(String technique, DateTime dateTime) {
    setState(() {
      events.add({
        'title': technique,
        'dateTime': dateTime,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Events"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ProgressScreen(),
            CalendarWidget(events: events),
          ],
        ),
      ),
    );
  }
}
