import 'dart:async';
import 'package:college_project/OMW/techniques.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_project/screens/mental_wellness_screen.dart';

class MentalWellnessScreenMain extends StatefulWidget {
  const MentalWellnessScreenMain({super.key});

  @override
  State<MentalWellnessScreenMain> createState() =>
      _MentalWellnessScreenMainState();
}

class _MentalWellnessScreenMainState extends State<MentalWellnessScreenMain> {
  List<Technique> meditationTechniques = []; // Changed to List<Technique>
  bool isLoading = true;

  // State to hold the selected technique and date/time for display (optional)
  Technique? _selectedTechniqueForDisplay;
  DateTime? _selectedDateTimeForDisplay;

  @override
  void initState() {
    super.initState();
    _fetchTechniques();
  }

  Future<void> _fetchTechniques() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('meditation').get();
      setState(() {
        meditationTechniques = snapshot.docs
            .map((doc) => Technique.fromFirestore(doc.data()))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching meditation techniques: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load techniques: $e")),
      );
    }
  }

  // --- REUSABLE METHOD TO SAVE DATA TO FIRESTORE (same as before) ---
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
      // Update local state for display
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const BreathingMindfulnessCard(),
                    const SizedBox(height: 40),
                    const Text(
                      "Mental clarity starts with a choice.",
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
                                  "Last Scheduled Mental Wellness Activity:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
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
                          builder: (context) => MentalWellnessScreen(
                            techniques: meditationTechniques,
                          ),
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
                                'assets/Wellness.jpg',
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
                  ],
                ),
        ),
      ),
    );
  }

  void _showTechniqueSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        String? selectedTechniqueTitle; // Local state for the modal

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
                      children: meditationTechniques.map((technique) {
                        return RadioListTile<String>(
                          title: Text(technique.title), // Use technique.title
                          value: technique.title,
                          groupValue: selectedTechniqueTitle,
                          onChanged: (value) {
                            setModalState(() {
                              selectedTechniqueTitle = value;
                            });
                            Navigator.pop(
                                context); // Close technique selection sheet
                            _showDateTimeSheet(context,
                                technique); // Pass the Technique object
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
      },
    );
  }

  void _showDateTimeSheet(BuildContext context, Technique technique) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        DateTime? tempSelectedDateTime; // Local state for the modal

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Select Date and Time for '${technique.title}'", // Use technique.title
                      style: const TextStyle(fontSize: 18)),
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
                          tempSelectedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          setModalState(() {
                            // Update the state of this modal sheet to show the selected date/time
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
                                'mentalWellness'); // Pass 'mentalWellness' category
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
      duration:
          const Duration(seconds: 4), // Total duration for one breath cycle
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
      _currentPromptIndex =
          (_currentPromptIndex + 1) % _mindfulnessPrompts.length;
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
                    _isBreathingActive ? _breathingInstruction : 'Relax',
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
              icon: Icon(_isBreathingActive
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill),
              label: Text(_isBreathingActive
                  ? 'Pause Exercise'
                  : 'Start Breathing Exercise'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBreathingActive
                    ? Colors.orange.shade700 // A contrasting color for pause
                    : isLightMode
                        ? primaryColor
                        : accentColor, // Theme's accent for start
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
                    color: isLightMode
                        ? Colors.grey.shade200
                        : Colors.grey.shade700,
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
