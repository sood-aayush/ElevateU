import 'package:flutter/material.dart';
import 'package:college_project/homescreen.dart'; // Ensure this import path is correct for CurrentStats
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

// Change from StatelessWidget to StatefulWidget
class DailyTaskCard extends StatefulWidget {
  const DailyTaskCard({super.key}); // Remove taskCount from constructor

  @override
  State<DailyTaskCard> createState() => _DailyTaskCardState();
}

class _DailyTaskCardState extends State<DailyTaskCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // These methods now internally use the taskCount from the stream
  Color _getBadgeColor(int count) {
    if (count == 0) return Colors.green; // If 0 tasks, it's green (all done!)
    if (count <= 2) return Colors.blue; // A few left
    if (count <= 5) return Colors.orange; // Moderate tasks
    return Colors.red; // Many tasks
  }

  String _getHeadline(int count) {
    if (count == 0) return "Hurray! No tasks left 🎉";
    if (count <= 2) return "You're almost done!";
    if (count <= 5) return "Keep going, you're getting there!";
    return "Busy day ahead!";
  }

  String _getSubtext(int count) {
    if (count == 0) return "Take a break or plan tomorrow's goals.";
    if (count <= 2) return "A few more tasks to wrap up.";
    if (count <= 5) return "You can do this — one step at a time.";
    return "Prioritize and power through!";
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      // Handle case where user is not logged in
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Login to see your tasks!",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Your daily tasks will appear here once you're signed in.",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[700], fontSize: 15),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.account_circle, size: 48, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    // Get today's date range for the query
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime tomorrowStart = DateTime(now.year, now.month, now.day + 1);

    return StreamBuilder<QuerySnapshot>(
      // Query for activities for the current user, today's date, and not completed
      stream: _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .where('timestamp', isGreaterThanOrEqualTo: todayStart)
          .where('timestamp', isLessThan: tomorrowStart)
          .where('isCompleted', isEqualTo: false) // Only get incomplete tasks
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }

        if (snapshot.hasError) {
          print(
              "Error fetching daily tasks for DailyTaskCard: ${snapshot.error}");
          return Text("Error: ${snapshot.error}"); // Show error
        }

        // Calculate taskCount from the number of incomplete documents
        final int taskCount = snapshot.data?.docs.length ?? 0;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const CurrentStats()), // Navigate to CurrentStats
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getHeadline(taskCount), // Use live taskCount
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getSubtext(taskCount), // Use live taskCount
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[700], fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  // Calendar icon with badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getBadgeColor(taskCount)
                          .withOpacity(0.1), // Use live taskCount
                      border: Border.all(
                          color: _getBadgeColor(taskCount),
                          width: 2), // Use live taskCount
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "$taskCount", // Display live taskCount
                        style: TextStyle(
                          color: _getBadgeColor(taskCount),
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_right_rounded),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
