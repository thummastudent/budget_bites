import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Budget cap stored in dollars for UI display (default: $50)
  double _budgetCap = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Budget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_budgetCap.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),
            Slider(
              value: _budgetCap,
              min: 10.0,
              max: 200.0,
              divisions: 38, // $5 increments
              label: '\$${_budgetCap.toStringAsFixed(0)}',
              onChanged: (double value) {
                setState(() {
                  _budgetCap = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save logic will be wired in Criterion 3
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget cap updated!')),
                );
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}