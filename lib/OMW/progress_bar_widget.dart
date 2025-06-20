import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:intl/intl.dart'; // For date formatting (if needed for debugging or display)

// Your existing Task class
class Task {
  final String title;
  final bool isCompleted;
  final String
      id; // Add ID to Task, useful if you wanted to toggle/delete from TasksListScreen later

  Task(this.title, {this.isCompleted = false, required this.id});

  // Factory constructor to create a Task from a Firestore DocumentSnapshot
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      data['techniqueTitle'] ?? 'No Title', // Default if title is missing
      isCompleted: data['isCompleted'] ??
          false, // Default if completion status is missing
      id: doc.id, // Store the document ID
    );
  }
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Please log in to see your daily progress.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Get today's date, normalized to start of day (midnight)
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime tomorrowStart = DateTime(now.year, now.month, now.day + 1);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .where('timestamp', isGreaterThanOrEqualTo: todayStart)
          .where('timestamp', isLessThan: tomorrowStart)
          .orderBy('timestamp',
              descending: false) // Order by time for consistency
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print(
              "Error fetching daily activities for ProgressScreen: ${snapshot.error}");
          return Center(
              child: Text("Error loading progress: ${snapshot.error}"));
        }

        // If no data, display a message
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "No activities scheduled for today.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Today's Progress: 0%",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 10,
                          child: LinearProgressIndicator(
                            value: 0.0,
                            backgroundColor: Colors.grey.shade300,
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Map Firestore documents to Task objects
        final List<Task> dailyTasks = snapshot.data!.docs.map((doc) {
          return Task.fromFirestore(doc);
        }).toList();

        // Calculate progress
        final completedCount =
            dailyTasks.where((t) => t.isCompleted).length.toDouble();
        final totalCount = dailyTasks.length.toDouble();
        final progress = totalCount == 0 ? 0.0 : (completedCount / totalCount);

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TasksListScreen(
                        tasks: dailyTasks), // Pass the live tasks
                  ),
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Progress: ${(progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 10,
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Your existing TasksListScreen class (no major changes needed here for now)
class TasksListScreen extends StatelessWidget {
  final List<Task> tasks;
  const TasksListScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('All Daily Activities')), // Changed title
      body: tasks.isEmpty
          ? const Center(child: Text("No activities for today!"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (_, idx) {
                final task = tasks[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: task.isCompleted
                      ? Colors.green.shade100
                      : Theme.of(context).cardColor, // Use theme card color
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null, // Strikethrough if completed
                        color: task.isCompleted
                            ? Colors.green.shade800
                            : Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color, // Adjust color based on theme
                      ),
                    ),
                    trailing: task.isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
