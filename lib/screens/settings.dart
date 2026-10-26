import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  
  // constructor
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // default budget set to 50
  double _budgetCap = 50.0;
  bool _isSaving = false;

  // write budget cap to local key-value storage (shared_preferences)
  Future<void> _saveBudgetCap() async {
    setState(() {
      _isSaving = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('weekly_budget_cap', _budgetCap);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget saved')),
    );
  }

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
            
            // display current budget 
            const Text(
              'Weekly Budget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            // display current budget value
            const SizedBox(height: 8),
            Text(
              '\$${_budgetCap.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),

            // slider for budget adjustment
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

            // save button 
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                
                // save logic to be created 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget updated')),
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