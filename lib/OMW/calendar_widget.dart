import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:college_project/Themes/theme.dart'; // Ensure this import path is correct
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarWidget extends StatefulWidget {
  final List<Map<String, dynamic>> events;

  const CalendarWidget({super.key, required this.events});

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final int month = DateTime.now().month;
  final int year = DateTime.now().year;
  late Map<DateTime, List<Map<String, dynamic>>> eventsMap;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _buildEventsMap();
  }

  @override
  void didUpdateWidget(covariant CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.events != oldWidget.events) {
      _buildEventsMap();
    }
  }

  void _buildEventsMap() {
    eventsMap = {};
    for (var event in widget.events) {
      // Ensure 'timestamp' is a DateTime, if it's a Timestamp, convert it
      final dynamic timestampData = event['timestamp'];
      final DateTime eventDateTime = timestampData is Timestamp
          ? timestampData.toDate()
          : timestampData; // Assuming it's already DateTime if not Timestamp

      DateTime normalizedDate =
          DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day);

      if (!eventsMap.containsKey(normalizedDate)) {
        eventsMap[normalizedDate] = [];
      }
      eventsMap[normalizedDate]!.add(event);
    }
  }

  Future<void> _toggleActivityCompletion(
      String activityId, bool isCompleted) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must be logged in to modify activities.")),
      );
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .doc(activityId)
          .update({'isCompleted': !isCompleted}); // Toggle the state

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Activity ${!isCompleted ? 'marked as completed' : 'reopened'}! 🎉")),
      );

      // --- NEW: Update local eventsMap and rebuild CalendarWidget State ---
      // Find the activity in eventsMap and update its completion status
      setState(() {
        // Call setState for CalendarWidgetState
        for (var date in eventsMap.keys) {
          int index =
              eventsMap[date]!.indexWhere((event) => event['id'] == activityId);
          if (index != -1) {
            eventsMap[date]![index]['isCompleted'] = !isCompleted;
            break; // Found and updated, exit loop
          }
        }
      });
      // The dialog will also rebuild via its StatefulBuilder now.
      // --- END NEW ---
    } catch (e) {
      print("Error toggling completion for $activityId: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update activity: $e")),
      );
    }
  }

  Future<void> _deleteActivity(String activityId) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must be logged in to delete activities.")),
      );
      return;
    }

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
            "Are you sure you want to permanently delete this activity?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmDelete != true) {
      return; // User cancelled deletion
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .doc(activityId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activity deleted successfully!")),
      );

      // --- NEW: Update local eventsMap and rebuild CalendarWidget State after deletion ---
      setState(() {
        // Call setState for CalendarWidgetState
        for (var date in eventsMap.keys) {
          eventsMap[date]!.removeWhere((event) => event['id'] == activityId);
        }
        // If a date becomes empty, you might want to remove it from the map
        // eventsMap.removeWhere((key, value) => value.isEmpty); // Optional
      });
      // --- END NEW ---

      Navigator.of(context)
          .pop(); // Close the event details dialog after deletion
    } catch (e) {
      print("Error deleting activity $activityId: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete activity: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String curMonth = DateFormat('MMMM').format(now);

    final theme = Theme.of(context).extension<CalendarTheme>()!;

    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.backgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '📅 $curMonth',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.dayTextColor,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: _daysInMonth(month, year) +
                      _firstWeekdayOffset(month, year),
                  itemBuilder: (context, index) {
                    int day = index - _firstWeekdayOffset(month, year) + 1;
                    if (day > 0 && day <= _daysInMonth(month, year)) {
                      DateTime date = DateTime(year, month, day);
                      return _buildDayCell(date, theme);
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _daysInMonth(int month, int year) => DateTime(year, month + 1, 0).day;

  int _firstWeekdayOffset(int month, int year) =>
      DateTime(year, month, 1).weekday - 1;

  Widget _buildDayCell(DateTime date, CalendarTheme theme) {
    DateTime today = DateTime.now();
    bool isToday = DateUtils.isSameDay(date, today);
    bool hasEvent = eventsMap.containsKey(date) &&
        eventsMap[date]!.isNotEmpty; // Check if the list is not empty

    // Check if there's at least one incomplete event for the day to show the dot
    bool hasIncompleteEvent = hasEvent &&
        eventsMap[date]!.any((event) => !(event['isCompleted'] ?? false));

    return GestureDetector(
      onTap: () => _showEventsForDate(date),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isToday ? theme.todayColor.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: theme.dayTextColor,
              ),
            ),
            if (hasIncompleteEvent) // Only show dot if there's an incomplete event
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.eventColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEventsForDate(DateTime date) {
    // We will now pass a copy or reference the original eventsMap
    // and rely on the StatefulBuilder to rebuild the dialog content.
    List<Map<String, dynamic>> dayEvents = eventsMap[date] ?? [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Use dialogContext to avoid conflict with outer context
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).scaffoldBackgroundColor,
          title: Text(
            "Activities for ${DateFormat.yMMMMd().format(date)}",
            style: TextStyle(
                color: Theme.of(dialogContext).textTheme.bodyLarge!.color,
                fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            // <--- KEY CHANGE: StatefulBuilder here
            builder: (BuildContext innerContext, StateSetter innerSetState) {
              // Re-fetch dayEvents to ensure they reflect the latest state
              // This is crucial for the dialog to update itself
              dayEvents = eventsMap[date] ??
                  []; // Use the updated eventsMap from CalendarWidgetState

              return dayEvents.isEmpty
                  ? Text("No activities scheduled for this day.",
                      style: TextStyle(
                          color: Theme.of(innerContext)
                              .textTheme
                              .bodyMedium!
                              .color))
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: dayEvents.length,
                        itemBuilder: (innerContext, index) {
                          final event = dayEvents[index];
                          final DateTime eventTime =
                              event['timestamp'] is Timestamp
                                  ? (event['timestamp'] as Timestamp).toDate()
                                  : event['timestamp'];
                          final String category = event['category'];
                          final bool isCompleted =
                              event['isCompleted'] ?? false;
                          final String activityId = event['id'];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            color: isCompleted ? Colors.grey[200] : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['techniqueTitle'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: Theme.of(innerContext)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Category: ${category[0].toUpperCase()}${category.substring(1)}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Time: ${DateFormat('hh:mm a').format(eventTime)}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () async {
                                          await _toggleActivityCompletion(
                                              activityId, isCompleted);
                                          // After updating in Firestore and parent's eventsMap,
                                          // trigger a rebuild of the dialog content
                                          innerSetState(() {
                                            // This will cause the StatefulBuilder to rebuild,
                                            // re-evaluating `dayEvents` and re-rendering the list.
                                          });
                                        },
                                        icon: Icon(
                                          isCompleted
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          color: isCompleted
                                              ? Colors.green
                                              : Theme.of(innerContext)
                                                  .primaryColor,
                                        ),
                                        label: Text(isCompleted
                                            ? "Reopen"
                                            : "Complete"),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () async {
                                          await _deleteActivity(activityId);
                                          // If deletion was successful, the dialog would have been popped.
                                          // If it wasn't popped (e.g., user cancelled), nothing changes here.
                                          // We still need to call innerSetState just in case to reflect
                                          // any changes in `dayEvents` if the deletion logic changes.
                                          innerSetState(() {});
                                        },
                                        icon: const Icon(Icons.delete_forever,
                                            color: Colors.red),
                                        label: const Text("Delete",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
