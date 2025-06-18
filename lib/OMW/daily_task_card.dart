import 'package:flutter/material.dart';

class DailyTaskCard extends StatelessWidget {
  final int taskCount;

  const DailyTaskCard({super.key, required this.taskCount});

  Color _getBadgeColor(int count) {
    if (count <= 2) return Colors.green;
    if (count <= 5) return Colors.orange;
    return Colors.red;
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
                    _getHeadline(taskCount),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getSubtext(taskCount),
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
                color: _getBadgeColor(taskCount).withOpacity(0.1),
                border: Border.all(color: _getBadgeColor(taskCount), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "$taskCount",
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

            // Texts
          ],
        ),
      ),
    );
  }
}
