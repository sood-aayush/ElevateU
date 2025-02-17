import 'package:college_project/academics_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:college_project/main_screen.dart';
import 'package:college_project/techniques.dart';

class AcademicsMainScreen extends StatelessWidget {
  final List<Technique> techniques;
  const AcademicsMainScreen({super.key, required this.techniques});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Select the Effective Study Techniques you want to learn",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return _buildBottomSheet(context);
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text("Select"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AcademicsScreen(
                      techniques: techniques,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text("All the techniques"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    String? selectedTechnique;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Choose a technique:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Column(
              children: techniques.map((technique) {
                return RadioListTile<String>(
                  title: Text(technique.title),
                  value: technique.title,
                  groupValue: selectedTechnique,
                  onChanged: (value) {
                    selectedTechnique = value;
                    Navigator.pop(context);
                    _showDateTimeSheet(context, technique);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateTimeSheet(BuildContext context, Technique technique) {
    DateTime? selectedDateTime;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Date and Time for '${technique.title}'",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      print("Selected Date and Time: $selectedDateTime");
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text("Pick Date and Time"),
              ),
              const SizedBox(height: 20),
              if (selectedDateTime != null)
                Text(
                  "Selected: ${DateFormat('yyyy-MM-dd – kk:mm').format(selectedDateTime!)}",
                ),
            ],
          ),
        );
      },
    );
  }
}
