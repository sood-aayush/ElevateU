import 'package:flutter/material.dart';
import 'package:college_project/Themes/theme.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String bmiResult = '';
  String bmiCategory = '';
  List<String> recommendations = [];

  @override
  Widget build(BuildContext context) {
    // Get colors from theme
    final theme = Theme.of(context).extension<CalendarTheme>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Tracker"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<GradientBackground>()?.gradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Calculate Your BMI",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // Input Fields
              _buildInputField("Height (cm)", heightController),
              const SizedBox(height: 10),
              _buildInputField("Weight (kg)", weightController),
              const SizedBox(height: 20),

              // Calculate Button
              ElevatedButton(
                onPressed: _calculateBMI,
                child: const Text("Calculate BMI"),
              ),
              const SizedBox(height: 20),

              // BMI Result Display
              if (bmiResult.isNotEmpty) _buildBMIResult(),

              // Recommendations
              if (recommendations.isNotEmpty) _buildRecommendations(),
            ],
          ),
        ),
      ),
    );
  }

  // Input Field Widget
  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
    );
  }

  // BMI Calculation Logic
  void _calculateBMI() {
    double heightCm = double.tryParse(heightController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0;
    double heightM = heightCm / 100;

    if (heightM > 0 && weight > 0) {
      double bmi = weight / (heightM * heightM);
      setState(() {
        bmiResult = bmi.toStringAsFixed(1);
        _setBMICategory(bmi);
      });
    }
  }

  // Determines BMI Category & Recommendations
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
    } else {
      bmiCategory = "Obese";
      recommendations = [
        "Consult a dietitian",
        "Follow structured exercise plans",
        "Monitor daily calorie intake"
      ];
    }
  }

  // Displays BMI Result & Category
  Widget _buildBMIResult() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Your BMI: $bmiResult",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Category: $bmiCategory",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // Displays Personalized Fitness Recommendations
  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            "Fitness Tips:",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...recommendations.map(
            (tip) => Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.white.withOpacity(0.2),
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
}
