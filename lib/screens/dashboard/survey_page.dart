import 'package:flutter/material.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  // 1. Define your question and choices here
  final String _surveyQuestion = "What brand of oil did you use? ";
  
  final List<String> _options = [
    "Golden Fiesta",
    "Jolly/Jolly Heart Mate",
    "Marca Leon",
    "Baguio Oil",
    "Minola",
    "Hapi Fiesta",
    "Doña Elena",
    "Frito Plus",

    "Bote-bote",
    "Mixed",
  ];

  String? _selectedValue; // To store the user's choice

  void _submitSurvey() {
    if (_selectedValue == null) {
      // Show error if they haven't picked anything
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an option before submitting.")),
      );
      return;
    }

    // Firebase stuff 
    // _selectedValue is the user choice


    // Idk firebase stuff

    // Show thanks and go back to home/dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you for your feedback!"), backgroundColor: Colors.green),
    );
    Navigator.pop(context); // Goes back to the Dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quick Survey"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.poll, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            
            // The Question
            Text(
              _surveyQuestion,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 24),

            // The Dropdown Choice
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select an option",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              value: _selectedValue,
              items: _options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedValue = newValue;
                });
              },
            ),

            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitSurvey,
                child: const Text("Submit Feedback", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}