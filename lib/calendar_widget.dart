import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:college_project/theme.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  CalendarWidgetState createState() => CalendarWidgetState();
}

class CalendarWidgetState extends State<CalendarWidget> {
  final int month = DateTime.now().month;
  final int year = DateTime.now().year;
  Map<DateTime, List<String>> events = {};

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String curMonth = DateFormat('MMMM yyyy').format(now);

    // Get colors from theme
    final theme = Theme.of(context).extension<CalendarTheme>()!;

    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.35, // Increased height
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.backgroundColor, // Theme-based background
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
                      return const SizedBox(); // Empty space before 1st day
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
    bool isToday = DateUtils.isSameDay(date, DateTime.now());
    bool hasEvent = events.containsKey(date);

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
            if (hasEvent)
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
    showDialog(
      context: context,
      builder: (context) {
        List<String> dayEvents = events[date] ?? [];
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            DateFormat.yMMMMd().format(date),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: dayEvents.isNotEmpty
                ? dayEvents
                    .map((event) => Text(event,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color)))
                    .toList()
                : [
                    Text("No Events",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color))
                  ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
