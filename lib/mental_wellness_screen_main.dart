import 'dart:async';
import 'package:college_project/OMW/techniques.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/mental_wellness_screen.dart';

class MentalWellnessScreenMain extends StatefulWidget {
  const MentalWellnessScreenMain({super.key});

  @override
  State<MentalWellnessScreenMain> createState() => _MentalWellnessScreenMainState();
}

class _MentalWellnessScreenMainState extends State<MentalWellnessScreenMain> {
  List<Map<String, dynamic>> meditationTechniques = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTechniques();
  }

  Future<void> _fetchTechniques() async {
    final snapshot = await FirebaseFirestore.instance.collection('meditation').get();
    setState(() {
      meditationTechniques = snapshot.docs.map((doc) => doc.data()).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BreathingMindfulnessCard(),
                  const SizedBox(height: 40),
                    const Text(
                      "Select the Mindfulness and Meditation Techniques you want to learn",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () => _showTechniqueSelectionSheet(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      ),
                      child: const Text("Select"),
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MentalWellnessScreen(
  techniques: meditationTechniques
      .map((tech) => Technique(
            title: tech['title'] ?? '',
            description: tech['description'] ?? '',
          ))
      .toList(),
),
                        ),
                      ),
                      
                      child:SizedBox(height: MediaQuery.of(context).size.height  *0.25,width:MediaQuery.of(context).size.width *0.85,
                      child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/Wellness.jpg',
                          ),
                        ),
                        const Text(
                          "All The Techniques",
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
                  ],
                ),
        ),
      ),
    );
  }

  void _showTechniqueSelectionSheet(BuildContext context) {
    String? selectedTechnique;

    showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose a technique:", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Column(
                children: meditationTechniques.map((technique) {
                  return RadioListTile<String>(
                    title: Text(technique['title'] ?? ''),
                    value: technique['title'],
                    groupValue: selectedTechnique,
                    onChanged: (value) {
                      selectedTechnique = value;
                      Navigator.pop(context);
                      _showDateTimeSheet(context, technique['title']);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateTimeSheet(BuildContext context, String title) {
    DateTime? selectedDateTime;

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Date and Time for '$title'", style: const TextStyle(fontSize: 18)),
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
              Text("Selected: ${DateFormat('yyyy-MM-dd – kk:mm').format(selectedDateTime!)}"),
          ],
        ),
      ),
    );
  }
}

class BreathingMindfulnessCard extends StatefulWidget {
  const BreathingMindfulnessCard({super.key});

  @override
  State<BreathingMindfulnessCard> createState() =>
      _BreathingMindfulnessCardState();
}

class _BreathingMindfulnessCardState extends State<BreathingMindfulnessCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  Timer? _breathingTimer;
  int _secondsRemaining = 0;
  bool _isBreathingActive = false;
  String _breathingInstruction = 'Tap to Start';
  final List<String> _breathingPhases = ['Inhale...', 'Hold...', 'Exhale...'];
  int _currentPhaseIndex = 0;

  // Mindfulness Prompts
  final List<String> _mindfulnessPrompts = [
    "What five things can you hear right now?",
    "Notice the sensation of your feet on the ground.",
    "What's one thing you are grateful for today?",
    "Observe your breath, without changing it.",
    "Scan your body for any areas of tension, and gently release them.",
  ];
  String _currentMindfulnessPrompt = '';
  int _currentPromptIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentMindfulnessPrompt = _mindfulnessPrompts[_currentPromptIndex];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Total duration for one breath cycle
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && _isBreathingActive) {
          _animationController.reverse();
          _updateBreathingInstruction('Exhale...'); // Start exhale
        } else if (status == AnimationStatus.dismissed && _isBreathingActive) {
          _animationController.forward();
          _updateBreathingInstruction('Inhale...'); // Start inhale
        }
      });

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _updateBreathingInstruction(String instruction) {
    setState(() {
      _breathingInstruction = instruction;
    });
  }

  void _toggleBreathingExercise() {
    setState(() {
      _isBreathingActive = !_isBreathingActive;
      if (_isBreathingActive) {
        _secondsRemaining = 60; // Default 1 minute exercise
        _startBreathingTimer();
        _animationController.forward();
        _updateBreathingInstruction('Inhale...');
      } else {
        _stopBreathingTimer();
        _animationController.stop();
        _animationController.reset();
        _breathingInstruction = 'Paused';
      }
    });
  }

  void _startBreathingTimer() {
    _breathingTimer?.cancel(); // Cancel any existing timer
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _stopBreathingTimer();
          _animationController.stop();
          _animationController.reset();
          _isBreathingActive = false;
          _breathingInstruction = 'Exercise Complete!';
        }
      });
    });
  }

  void _stopBreathingTimer() {
    _breathingTimer?.cancel();
  }

  void _cycleMindfulnessPrompt() {
    setState(() {
      _currentPromptIndex = (_currentPromptIndex + 1) % _mindfulnessPrompts.length;
      _currentMindfulnessPrompt = _mindfulnessPrompts[_currentPromptIndex];
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _breathingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;
    final primaryColor = theme.primaryColor;
    final accentColor = theme.colorScheme.secondary; // Your ultramarine accent

    return Card(
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      margin: theme.cardTheme.margin,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Breathing & Mindfulness',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isLightMode ? Colors.black87 : Colors.white70,
              ),
            ),
            const SizedBox(height: 16),

            // --- Breathing Exercise Section ---
            Text(
              'Guided Breathing',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isLightMode ? Colors.black54 : Colors.white60,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isBreathingActive
                            ? accentColor.withOpacity(0.5) // Pulsating accent
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),
                  Text(
                    _isBreathingActive
                        ? _breathingInstruction
                        : 'Relax',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _isBreathingActive ? _formatTime(_secondsRemaining) : '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLightMode ? Colors.grey[700] : Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _toggleBreathingExercise,
              icon: Icon(
                  _isBreathingActive ? Icons.pause_circle_filled : Icons.play_circle_fill),
              label: Text(_isBreathingActive ? 'Pause Exercise' : 'Start Breathing Exercise'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBreathingActive
                    ? Colors.orange.shade700 // A contrasting color for pause
                    : isLightMode ? primaryColor : accentColor, // Theme's accent for start
                foregroundColor: Colors.white,
              ),
            ),

            const Divider(height: 40, thickness: 1, indent: 20, endIndent: 20),

            // --- Mindfulness Prompt Section ---
            Text(
              'Mindfulness Prompt',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isLightMode ? Colors.black54 : Colors.white60,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _cycleMindfulnessPrompt,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isLightMode ? Colors.grey[50] : Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isLightMode ? Colors.grey.shade200 : Colors.grey.shade700,
                  ),
                ),
                child: Text(
                  _currentMindfulnessPrompt,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isLightMode ? Colors.black87 : Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cycleMindfulnessPrompt,
              icon: const Icon(Icons.casino), // Or Icons.lightbulb_outline
              label: const Text('New Prompt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLightMode
                    ? Colors.blueGrey.shade400
                    : Colors.grey.shade700, // A neutral button for new prompt
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}