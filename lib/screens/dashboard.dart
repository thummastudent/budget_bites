import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/meal.dart';
import 'meal_form.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Meal> _allDashboardMeals = [];
  List<Meal> _filteredDashboardMeals = [];
  String _selectedCuisine = 'All';
  bool _isLoading = true;

  // list of cuisines for filtering meals on dashboard - need to include ALL button
  final List<String> _cuisines = [
    'All',
    'American',
    'Italian',
    'Mexican',
    'Asian',
    'Mediterranean',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final mealMaps = await DatabaseHelper.instance.getAllMeals();
    final meals = mealMaps.map((map) => Meal.fromMap(map)).toList();

    if (!mounted) return;
    setState(() {
      _allDashboardMeals = meals;
      _applyDashboardFilter();
      _isLoading = false;
    });
  }

  void _applyDashboardFilter() {
    if (_selectedCuisine == 'All') {
      _filteredDashboardMeals = List.from(_allDashboardMeals);
    } else {
      _filteredDashboardMeals = _allDashboardMeals
          .where((meal) => meal.cuisine.toLowerCase() == _selectedCuisine.toLowerCase())
          .toList();
    }
  }

  Future<void> _openMealEditor([Meal? meal]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => MealForm(meal: meal),
      ),
    );

    if (result == true) {
      await _loadDashboardData();
    }
  }

  // confirming deletion of a meal and then deleting it from the database
  Future<bool> _confirmAndDeleteMeal(Meal meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text('Are you sure you want to delete "${meal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && meal.id != null) {
      await DatabaseHelper.instance.deleteMeal(meal.id!);
      await _loadDashboardData();
      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${meal.name}"'),
          duration: const Duration(seconds: 2),
        ),
      );
      return true;
    }
    return false;
  }

// main dashboard UI - list of meals, cuisine filter and add button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
        centerTitle: true,
      ),
      
      // if loading, show loading, else show the list of meals
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // cuisine filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCuisine,
                    items: _cuisines.map((String cuisine) {
                      return DropdownMenuItem<String>(
                        value: cuisine,
                        child: Text(cuisine),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCuisine = newValue;
                          _applyDashboardFilter();
                        });
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _filteredDashboardMeals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                              // if no meals are logged, show a message to the user, tell them to add a meal
                              const SizedBox(height: 12),
                              Text(
                                _allDashboardMeals.isEmpty
                                    ? 'No meals logged'
                                    : 'No $_selectedCuisine meals found',
                                style: const TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              if (_allDashboardMeals.isEmpty)
                                const Text('Tap + below to log your first meal.'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredDashboardMeals.length,
                          itemBuilder: (context, index) {
                            final meal = _filteredDashboardMeals[index];
                            return Dismissible(
                              key: ValueKey(meal.id ?? index),
                              direction: DismissDirection.startToEnd,
                              confirmDismiss: (_) => _confirmAndDeleteMeal(meal),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20.0),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: DashboardCard(
                                meal: meal,
                                onEdit: () => _openMealEditor(meal),
                                onDelete: () => _confirmAndDeleteMeal(meal),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: () => _openMealEditor(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Add Meal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DashboardCard({
    super.key,
    required this.meal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priceString = '\$${(meal.estimatedPriceMinor / 100).toStringAsFixed(2)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: ListTile(
        leading: const Icon(Icons.fastfood, size: 30),
        title: Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${meal.cuisine} • ${meal.venueNote.isEmpty ? "No venue note" : meal.venueNote}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(priceString, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}