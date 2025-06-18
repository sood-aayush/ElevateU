import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:college_project/OMW/techniques.dart';
import 'package:college_project/academics_screen.dart';
import 'package:flutter/services.dart';
import 'dart:async'; 

class AcademicsMainScreen extends StatefulWidget {
  final Function(String, DateTime) onEventSelected;

  const AcademicsMainScreen({super.key, required this.onEventSelected});

  @override
  _AcademicsMainScreenState createState() => _AcademicsMainScreenState();
}

class _AcademicsMainScreenState extends State<AcademicsMainScreen> {
  late Future<List<Technique>> _techniquesFuture;

  @override
  void initState() {
    super.initState();
    _techniquesFuture = _fetchTechniquesFromFirestore();
  }

  Future<List<Technique>> _fetchTechniquesFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('academics').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Technique(
        title: data['title'] ?? 'Untitled',
        description: data['description'] ?? '',
      );
    }).toList();
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
            body: Center(child: Text("Error loading techniques")),
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
                  const StudySessionTimer(),
                  const SizedBox(height: 20),
                  const Text(
                    "Select the Effective Study Techniques you want to learn",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    ),
                    child: const Text("Select"),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AcademicsScreen(techniques: techniques),
                      ),
                    ),
                    
                    child:SizedBox(height: MediaQuery.of(context).size.height  *0.25,width:MediaQuery.of(context).size.width *0.85 ,
                        child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/Academics.jpeg',
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
      },
    );
  }

  Widget _buildBottomSheet(BuildContext context, List<Technique> techniques) {
    String? selectedTechnique;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Choose a technique:", style: TextStyle(fontSize: 18)),
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
      builder: (_) => Padding(
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
                    selectedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    widget.onEventSelected(
                      technique.title,
                      selectedDateTime!,
                    );

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

class StudySessionTimer extends StatefulWidget {
  const StudySessionTimer({super.key});

  @override
  State<StudySessionTimer> createState() => _StudySessionTimerState();
}

enum TimerMode { focus, shortBreak, longBreak, initial }

class _StudySessionTimerState extends State<StudySessionTimer> with SingleTickerProviderStateMixin {
  static const int _initialFocusDurationMinutes = 25;
  static const int _initialShortBreakDurationMinutes = 5;
  static const int _initialLongBreakDurationMinutes = 15;
  static const int _focusSessionsBeforeLongBreak = 4;

  int _focusDurationSeconds = _initialFocusDurationMinutes * 60;
  int _shortBreakDurationSeconds = _initialShortBreakDurationMinutes * 60;
  int _longBreakDurationSeconds = _initialLongBreakDurationMinutes * 60;

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  TimerMode _currentMode = TimerMode.initial;
  int _completedFocusSessions = 0;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _focusDurationSeconds;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      if (_currentMode == TimerMode.initial) {
        _currentMode = TimerMode.focus;
        _remainingSeconds = _focusDurationSeconds;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _isRunning = false;
        _handleTimerEnd();
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _focusDurationSeconds;
      _currentMode = TimerMode.initial;
      _completedFocusSessions = 0;
    });
    _animationController.reset();
  }

  void _handleTimerEnd() {
    HapticFeedback.vibrate();
    print('${_currentMode.name} session ended!');

    if (_currentMode == TimerMode.focus) {
      _completedFocusSessions++;
      if (_completedFocusSessions % _focusSessionsBeforeLongBreak == 0) {
        _currentMode = TimerMode.longBreak;
        _remainingSeconds = _longBreakDurationSeconds;
        _showCompletionDialog("Long Break Time!", "You've completed $_completedFocusSessions focus sessions. Take a longer break.");
      } else {
        _currentMode = TimerMode.shortBreak;
        _remainingSeconds = _shortBreakDurationSeconds;
        _showCompletionDialog("Short Break Time!", "Time for a quick break. You've completed $_completedFocusSessions focus sessions.");
      }
    } else {
      _currentMode = TimerMode.focus;
      _remainingSeconds = _focusDurationSeconds;
      _showCompletionDialog("Focus Time!", "Time to get back to work.");
    }

    _startTimer();
  }

  Future<void> _showCompletionDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildDurationSetting(String label, int currentDurationMinutes, ValueChanged<int> onMinutesChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(
          width: 80,
          child: TextField(
            controller: TextEditingController(text: currentDurationMinutes.toString()),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) {
              int? newMinutes = int.tryParse(value);
              if (newMinutes != null && newMinutes > 0) {
                onMinutesChanged(newMinutes);
                if (!_isRunning && label.contains("Focus")) {
                   setState(() {
                     _remainingSeconds = newMinutes * 60;
                   });
                }
              }
            },
          ),
        ),
        Text("min", style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int displaySeconds = _remainingSeconds;
    String modeText = "Ready";
    if (_currentMode == TimerMode.focus) {
      modeText = "Focus Time";
    } else if (_currentMode == TimerMode.shortBreak) {
      modeText = "Short Break";
    } else if (_currentMode == TimerMode.longBreak) {
      modeText = "Long Break";
    }

    return Card(
      // Removed margin here, let parent padding handle it
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for fitting into limited space
          children: [
            Text(
              "Study Session Timer",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(),
            ),
            const SizedBox(height: 15), // Reduced spacing slightly
            Text(
              modeText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _currentMode == TimerMode.focus
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 15), // Reduced spacing
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 150, // Slightly reduced size
                height: 150, // Slightly reduced size
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentMode == TimerMode.focus
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  border: Border.all(
                    color: _currentMode == TimerMode.focus
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.secondary,
                    width: 4,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _formatTime(displaySeconds),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 50, // Reduced font size to fit
                        color: _currentMode == TimerMode.focus
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 15), // Reduced spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.small(
                  heroTag: 'resetBtnStudy', // Unique tag for this context
                  onPressed: _resetTimer,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  child: const Icon(Icons.refresh),
                ),
                FloatingActionButton(
                  heroTag: 'playPauseBtnStudy', // Unique tag
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  backgroundColor: _isRunning ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                FloatingActionButton.small(
                  heroTag: 'skipBtnStudy', // Unique tag
                  onPressed: _isRunning ? () {
                    _timer?.cancel();
                    _isRunning = false;
                    _handleTimerEnd();
                  } : null,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Icon(Icons.skip_next),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "Completed Sessions: $_completedFocusSessions",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Divider(height: 30), // Reduced height
            Text(
              "Timer Settings",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _buildDurationSetting("Focus Duration", _focusDurationSeconds ~/ 60, (minutes) {
              setState(() {
                _focusDurationSeconds = minutes * 60;
              });
            }),
            const SizedBox(height: 10),
            _buildDurationSetting("Short Break", _shortBreakDurationSeconds ~/ 60, (minutes) {
              setState(() {
                _shortBreakDurationSeconds = minutes * 60;
              });
            }),
            const SizedBox(height: 10),
            _buildDurationSetting("Long Break", _longBreakDurationSeconds ~/ 60, (minutes) {
              setState(() {
                _longBreakDurationSeconds = minutes * 60;
              });
            }),
          ],
        ),
      ),
    );
  }
}