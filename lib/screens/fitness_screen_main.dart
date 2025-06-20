// Enhanced FitnessScreen with Firestore + BMI & Recommendations
import 'package:college_project/OMW/techniques.dart';
import 'package:college_project/screens/fitness_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FitnessScreenMain extends StatefulWidget {
  const FitnessScreenMain({super.key});

  @override
  State<FitnessScreenMain> createState() => _FitnessScreenMainState();
}

class _FitnessScreenMainState extends State<FitnessScreenMain> {
  late Future<List<Technique>> _techniquesFuture;
  double? lastBMI;

  // State to hold the selected technique and date/time for display (optional)
  Technique? _selectedTechniqueForDisplay;
  DateTime? _selectedDateTimeForDisplay;

  @override
  void initState() {
    super.initState();
    _techniquesFuture = _fetchTechniquesFromFirestore();
    _loadLastBMI();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(_loadLastBMI);
  }

  Future<void> _loadLastBMI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? storedBMI = prefs.getDouble('lastBMI');
    setState(() {
      lastBMI = storedBMI;
    });
  }

  Future<List<Technique>> _fetchTechniquesFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('fitness').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Technique(
          title: data['title'] ?? 'Untitled',
          description: data['description'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Error fetching fitness techniques: $e");
      return [];
    }
  }

  // --- REUSABLE METHOD TO SAVE DATA TO FIRESTORE ---
  Future<void> _saveActivity(
      Technique technique, DateTime dateTime, String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You need to be logged in to save activities.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activities')
          .add({
        'techniqueTitle': technique.title,
        'timestamp': Timestamp.fromDate(dateTime),
        'category': category, // Use the passed category
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'isCompleted': false, // <--- ADD THIS LINE HERE!
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Scheduled '${technique.title}' for ${DateFormat('yyyy-MM-dd HH:mm').format(dateTime)}")),
      );
      // Update local state for display (optional)
      setState(() {
        _selectedTechniqueForDisplay = technique;
        _selectedDateTimeForDisplay = dateTime;
      });
      print("$category activity saved successfully!");
    } catch (e) {
      print("Error saving $category activity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save activity: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Technique>>(
      future: _techniquesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
                child: Center(child: Text("Error loading techniques"))),
          );
        }

        final techniques = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Custom-Craft Your Ultimate Workout",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => _buildBottomSheet(context, techniques),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                    ),
                    child: const Text("Select"),
                  ),
                  const SizedBox(height: 15),
                  // Optional: Display the last selected item
                  if (_selectedTechniqueForDisplay != null &&
                      _selectedDateTimeForDisplay != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Last Scheduled Fitness Activity:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                  "Technique: ${_selectedTechniqueForDisplay!.title}"),
                              Text(
                                  "Time: ${DateFormat('yyyy-MM-dd – kk:mm').format(_selectedDateTimeForDisplay!)}"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FitnessScreen(techniques: techniques),
                      ),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/Fitness.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          const Positioned(
                            bottom: 10,
                            child: Text(
                              "All The Techniques",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  BMIMeterWidget(
                    bmi: lastBMI,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BMIScreen()),
                      );
                      _loadLastBMI(); // Reload BMI after returning from BMIScreen
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheet(BuildContext context, List<Technique> techniques) {
    String? selectedTechniqueTitle;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Choose a technique:",
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Column(
                  children: techniques.map((technique) {
                    return RadioListTile<String>(
                      title: Text(technique.title),
                      value: technique.title,
                      groupValue: selectedTechniqueTitle,
                      onChanged: (value) {
                        setModalState(() {
                          selectedTechniqueTitle = value;
                        });
                        Navigator.pop(
                            context); // Close technique selection sheet
                        // Pass the entire Technique object to the next sheet
                        _showDateTimeSheet(context, technique);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDateTimeSheet(BuildContext context, Technique technique) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        DateTime? tempSelectedDateTime;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          tempSelectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          setModalState(() {
                            // Update the state of this modal sheet
                          });
                        }
                      }
                    },
                    child: const Text("Pick Date and Time"),
                  ),
                  const SizedBox(height: 20),
                  if (tempSelectedDateTime != null)
                    Text(
                      "Selected: ${DateFormat('yyyy-MM-dd – kk:mm').format(tempSelectedDateTime!)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  else
                    const Text("No date and time selected."),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: tempSelectedDateTime == null
                        ? null // Disable button if no date/time is selected
                        : () {
                            Navigator.pop(context); // Close date/time sheet
                            _saveActivity(technique, tempSelectedDateTime!,
                                'fitness'); // Pass 'fitness' category
                          },
                    child: const Text("Schedule Activity"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String bmiResult = '';
  String bmiCategory = '';
  List<String> recommendations = [];
  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
    );
  }

  void _calculateBMI() async {
    double heightCm = double.tryParse(heightController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0;
    double heightM = heightCm / 100;

    if (heightM > 0 && weight > 0) {
      double bmi = weight / (heightM * heightM);
      setState(() {
        bmiResult = bmi.toStringAsFixed(1);
        _setBMICategory(bmi);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setDouble('lastBMI', bmi);
    }

    FocusScope.of(context).unfocus();
  }

  void _setBMICategory(double bmi) {
    if (bmi < 18.5) {
      bmiCategory = "Underweight";
      recommendations = [
        "Increase calorie intake",
        "Eat protein-rich foods",
        "Strength training exercises"
      ];
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      bmiCategory = "Normal Weight";
      recommendations = [
        "Maintain a balanced diet",
        "Continue regular physical activity"
      ];
    } else if (bmi >= 25.0 && bmi <= 29.9) {
      bmiCategory = "Overweight";
      recommendations = [
        "Reduce sugar intake",
        "Increase cardio workouts",
        "Monitor portion sizes"
      ];
    } else if (bmi > 30) {
      bmiCategory = "Obese";
      recommendations = [
        "Consult a dietitian",
        "Follow structured exercise plans",
        "Monitor daily calorie intake"
      ];
    }
  }

  Widget _buildBMIResult() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Your BMI: $bmiResult",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Category: $bmiCategory",
                style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text("Fitness Tips:",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...recommendations.map(
            (tip) => Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.teal),
                title: Text(tip, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("BMI Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Calculate Your BMI",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildInputField("Height (cm)", heightController),
            const SizedBox(height: 10),
            _buildInputField("Weight (kg)", weightController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateBMI,
              child: const Text("Calculate BMI"),
            ),
            const SizedBox(height: 20),
            if (bmiResult.isNotEmpty) _buildBMIResult(),
            if (recommendations.isNotEmpty) _buildRecommendations(),
          ],
        ),
      ),
    );
  }
}

class BMIMeterWidget extends StatefulWidget {
  final double? bmi;
  final VoidCallback onTap;

  const BMIMeterWidget({
    super.key,
    required this.bmi,
    required this.onTap,
  });

  @override
  State<BMIMeterWidget> createState() => _BMIMeterWidgetState();
}

class _BMIMeterWidgetState extends State<BMIMeterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bmiAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _setupAnimation();
  }

  void _setupAnimation() {
    final end = (widget.bmi ?? 0) / 40;
    _bmiAnimation = Tween<double>(begin: 0, end: end.clamp(0.0, 1.0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BMIMeterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmi != widget.bmi) {
      _controller.reset();
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBMIMeterColor(double bmi) {
    if (bmi < 16) return Colors.red;
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 20) return Colors.yellow;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  @override
  @override
  Widget build(BuildContext context) {
    final hasBMI = widget.bmi != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BMI Tracker",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (hasBMI)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your BMI",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(),
                    ),
                    const SizedBox(height: 4),
                    AnimatedBuilder(
                      animation: _bmiAnimation,
                      builder: (context, child) => LinearProgressIndicator(
                        color: _getBMIMeterColor(widget.bmi!),
                        backgroundColor: Colors.grey.shade300,
                        value: _bmiAnimation.value,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${widget.bmi!.toStringAsFixed(1)} (${_getBMICategory(widget.bmi!)})",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                )
              else
                Text(
                  "Tap to calculate your BMI",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
