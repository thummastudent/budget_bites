import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Make sure to import main.dart to access MyApp

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _budgetKey = 'weekly_budget_cap';
  static const String _darkModeKey = 'is_dark_mode';

  double _budgetCap = 50.0;
  bool _isDarkMode = false;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCap = prefs.getDouble(_budgetKey) ?? 50.0;
    final savedDarkMode = prefs.getBool(_darkModeKey) ?? false;

    if (!mounted) return;
    
    setState(() {
      _budgetCap = savedCap;
      _isDarkMode = savedDarkMode;
      _isLoading = false;
    });
  }
    
  Future<void> _saveSettings() async {  
    setState(() {
      _isSaving = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, _budgetCap);
    await prefs.setBool(_darkModeKey, _isDarkMode);

    // Apply the theme change globally across the app
    MyApp.of(context)?.setThemeMode(_isDarkMode);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                    divisions: 38,
                    label: '\$${_budgetCap.toStringAsFixed(0)}',
                    onChanged: (double value) {
                      setState(() {
                        _budgetCap = value;
                      });
                    },
                  ),
                  
                  const Divider(height: 32),

                  SwitchListTile(
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    value: _isDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      // Optional: Update theme instantly on toggle without waiting for save
                      MyApp.of(context)?.setThemeMode(value);
                    },
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}