import 'package:flutter/material.dart';

class Technique {
  final String title;
  final String description;

  Technique({required this.title, required this.description});
}

final List<Technique> academicsTechniques = [
  Technique(
    title: "Pomodoro Technique",
    description:
        "A time-management method that improves focus and productivity.\n\n"
        "- Work for 25 minutes, then take a 5-minute break.\n"
        "- After four sessions, take a longer break of 15-30 minutes.",
  ),
  Technique(
    title: "Active Recall",
    description:
        "An evidence-based technique where you quiz yourself to actively retrieve information.\n\n"
        "- Use flashcards or self-quizzing to test your knowledge without looking at notes.",
  ),
  Technique(
    title: "Spaced Repetition",
    description:
        "Revisit material at increasing intervals to strengthen long-term memory.\n\n"
        "- Review content after 1 day, 3 days, 1 week, and so on.",
  ),
  Technique(
    title: "Feynman Technique",
    description:
        "An active learning method that involves teaching a concept to someone else.\n\n"
        "- Simplify complex topics and explain them in your own words as if teaching a beginner.",
  ),
  Technique(
    title: "SQ3R Method",
    description: "A reading comprehension technique for efficient studying.\n\n"
        "- Survey: Skim the material.\n"
        "- Question: Formulate questions.\n"
        "- Read: Focus on answering the questions.\n"
        "- Recite: Summarize the key points.\n"
        "- Review: Go over the material.",
  ),
  Technique(
    title: "Mind Mapping",
    description:
        "A visual way of organizing information, making complex ideas easier to understand.\n\n"
        "- Draw a diagram with the main concept in the center, branching out with subtopics.",
  ),
  Technique(
    title: "Leitner System",
    description: "A form of spaced repetition using flashcards.\n\n"
        "- Group flashcards into boxes based on how well you know them.\n"
        "- Review more difficult cards frequently and known ones less often.",
  ),
];
final List<Technique> meditationTechniques = [
  Technique(
    title: "Beach Visualization",
    description:
        "Imagine a serene beach. Engage your senses: listen to the waves, feel the warmth of the sun, and smell the salt in the air.",
  ),
  Technique(
    title: "Forest Walk Visualization",
    description:
        "Visualize walking through a peaceful forest. Notice the tall trees, feel the crunch of leaves beneath your feet, and breathe in the scents of the woods.",
  ),
  Technique(
    title: "Mountain Meditation",
    description:
        "Picture yourself ascending a mountain. Feel your strength grow with each step as you reach the summit and reflect on your challenges.",
  ),
  Technique(
    title: "4-7-8 Breathing Technique",
    description:
        "Inhale for 4 seconds, hold for 7, and exhale for 8. This technique calms your nervous system.",
  ),
  Technique(
    title: "Box Breathing",
    description:
        "Inhale for 4 seconds, hold for 4, exhale for 4, and hold for 4. This exercise helps restore calm and focus.",
  ),
  Technique(
    title: "Diaphragmatic Breathing",
    description:
        "Breathe deeply into your belly, allowing the breath to fill your abdomen. This promotes relaxation and reduces stress.",
  ),
  Technique(
    title: "Basic Mindful Breathing",
    description:
        "Observe your breath as it flows in and out, bringing awareness to each inhalation and exhalation.",
  ),
  Technique(
    title: "Deep Belly Breathing",
    description:
        "Focus on expanding your belly while breathing deeply, activating your body's relaxation response.",
  ),
  Technique(
    title: "Lion's Breath",
    description:
        "Inhale deeply and exhale with a roaring sound. This playful exercise releases tension and energizes your body.",
  ),
];

final List<Technique> fitnessTechniques = [
  Technique(
    title: "High-Intensity Interval Training (HIIT)",
    description:
        "Engage in short bursts of intense exercise followed by brief rest periods. This method boosts metabolism and improves cardiovascular fitness.",
  ),
  Technique(
    title: "Strength Training",
    description:
        "Utilize resistance exercises like weightlifting to build muscle mass and enhance overall strength.",
  ),
  Technique(
    title: "Flexibility and Balance Workouts",
    description:
        "Incorporate activities such as yoga or Pilates to improve flexibility, balance, and core strength.",
  ),
  Technique(
    title: "Aerobic Exercise",
    description:
        "Participate in sustained, rhythmic activities like running, cycling, or swimming to enhance cardiovascular endurance.",
  ),
  Technique(
    title: "Functional Training",
    description:
        "Perform exercises that mimic everyday movements to improve overall functionality and reduce injury risk.",
  ),
  Technique(
    title: "Mobility Training",
    description:
        "Focus on exercises that enhance joint range of motion and overall movement quality.",
  ),
  Technique(
    title: "Balance Training",
    description:
        "Engage in activities that improve your ability to control and stabilize your body, such as standing on one leg or yoga poses.",
  ),
  Technique(
    title: "Stretching",
    description:
        "Incorporate regular stretching routines to maintain flexibility and prevent injuries.",
  ),
  Technique(
    title: "Agility Training",
    description:
        "Perform exercises that improve your ability to move quickly and change direction efficiently.",
  ),
  Technique(
    title: "Cardiovascular Workouts",
    description:
        "Engage in activities that raise your heart rate, such as brisk walking, running, or cycling, to improve heart health.",
  ),
];
