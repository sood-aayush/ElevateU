import 'package:flutter/material.dart';

class Task {
  final String title;
  final bool isCompleted;
  Task(this.title, {this.isCompleted = false});
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Sample data
  final List<Task> _tasks = [
    Task('Buy groceries', isCompleted: true),
    Task('Walk the dog'),
    Task('Read a chapter', isCompleted: true),
    Task('Workout'),
    Task('Call parents', isCompleted: true),
  ];

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((t) => t.isCompleted).length.toDouble();
    final totalCount = _tasks.length.toDouble();
    final progress = totalCount == 0 ? 0.0 : (completedCount / totalCount);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TasksListScreen(tasks: _tasks),
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
                        valueColor: const AlwaysStoppedAnimation(Colors.green),
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
  }
}

class TasksListScreen extends StatelessWidget {
  final List<Task> tasks;
  const TasksListScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Tasks')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (_, idx) {
          final task = tasks[idx];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: task.isCompleted ? Colors.green.shade100 : Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      task.isCompleted ? Colors.green.shade800 : Colors.black87,
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
