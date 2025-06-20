import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/OMW/daily_task_card.dart';
import 'package:college_project/OMW/progress_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            const DailyTaskCard(),
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Current Activities")),
        body: const Center(
          child: Text("Please log in to view your activities."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Scheduled Activities"),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .doc(user.uid)
              .collection('activities')
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print("Error fetching activities: ${snapshot.error}");
              return Center(
                  child: Text("Error loading activities: ${snapshot.error}"));
            }

            final List<Map<String, dynamic>> allActivities = [];
            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                allActivities.add({
                  'id': doc
                      .id, // KEEPING DOC ID IS CRITICAL FOR LATER DELETE/UPDATE
                  'techniqueTitle': data['techniqueTitle'],
                  'timestamp': (data['timestamp'] as Timestamp).toDate(),
                  'category': data['category'],
                  'isCompleted':
                      data['isCompleted'] ?? false, // ADDING THIS FIELD
                });
              }
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // --- REMOVED DAILYTASKCARD FROM HERE ---
                  // It caused an infinite loop as DailyTaskCard navigates to CurrentStats.
                  // DailyTaskCard should live on your main dashboard/home screen,
                  // and that screen will be responsible for providing its task count.
                  const SizedBox(height: 20), // Add some spacing instead
                  const ProgressScreen(),
                  const SizedBox(height: 20),
                  CalendarWidget(events: allActivities), // Pass ALL activities
                  if (allActivities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "No activities scheduled yet.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
