import 'package:flutter/material.dart';
import 'package:budget_bites/database/database_helper.dart';
import 'package:budget_bites/models/meal.dart';

class MealForm extends StatefulWidget {
  final Meal? meal; // Null when adding; non-null when editing

  const MealForm({super.key, this.meal});

  @override
  State<MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<MealForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _venueController;
  late TextEditingController _priceController;

  final List<String> _cuisines = [
    'American',
    'Mexican',
    'Italian',
    'Asian',
    'Indian',
    'Mediterranean',
    'Cafe / Bakery',
    'Other',
  ];
  String _selectedCuisine = 'American';

  bool _isSaving = false;

  bool get _isEditing => widget.meal != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal?.name ?? '');
    _venueController =
        TextEditingController(text: widget.meal?.venueNote ?? '');

    //
    if (widget.meal != null) {
      final initialPrice =
          (widget.meal!.estimatedPriceMinor / 100).toStringAsFixed(2);
      _priceController = TextEditingController(text: initialPrice);
    } else {
      _priceController = TextEditingController();
    }

    if (widget.meal != null && _cuisines.contains(widget.meal!.cuisine)) {
      _selectedCuisine = widget.meal!.cuisine;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Converts decimal input string into integer minor units (cents)
  int _parsePriceToMinorUnits(String value) {
    final cleaned = value.trim().replaceAll(r'$', '');
    final doubleAmount = double.tryParse(cleaned) ?? 0.0;
    return (doubleAmount * 100).round();
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Disable button to prevent double-tap race conditions
    setState(() {
      _isSaving = true;
    });

    final mealData = {
      DatabaseHelper.columnMealName: _nameController.text.trim(),
      DatabaseHelper.columnMealCuisine: _selectedCuisine,
      DatabaseHelper.columnMealEstimatedPriceMinor:
          _parsePriceToMinorUnits(_priceController.text),
      DatabaseHelper.columnMealVenueNote: _venueController.text.trim(),
    };

    try {
      if (_isEditing) {
        await DatabaseHelper.instance.updateMeal(widget.meal!.id!, mealData);
      } else {
        await DatabaseHelper.instance.insertMeal(mealData);
      }

      
      // TESTING TO SEE IF MEAL SAVING WORKS AND TO DEBUG
      final allMeals = await DatabaseHelper.instance.getAllMeals();
      debugPrint('CURRENT MEALS IN SQLITE: $allMeals');
      debugPrint('TOTAL MEAL COUNT: ${allMeals.length}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Meal updated successfully!'
                : 'Meal added to catalog!',
          ),
          backgroundColor: Colors.green[700],
        ),
      );

      // Return true to refresh catalog
    Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save meal: $e. Please try again.'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        // title (for either adding or edditing a meal)
        centerTitle: true,
        title: Text(_isEditing ? 'Edit Meal' : 'Add Meal'),
      ),
      
      body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      
                      // Pushes content down to the bottom for easier user interaction
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                
                                  // meal name box
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Meal Name',
                                      border: OutlineInputBorder(),
                                    ),
                                    textCapitalization: TextCapitalization.words,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter a meal';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // estimated price box
                                  TextFormField(
                                    controller: _priceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Estimated Price',
                                      prefixText: r'$ ',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter an estimated price';
                                      }
                                      final cleaned = value.trim().replaceAll(r'$', '');
                                      final parsed = double.tryParse(cleaned);
                                      if (parsed == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (parsed <= 0) {
                                        return 'Price must be greater than zero';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // cuisine dropdown 
                                  DropdownButtonFormField<String>(
                                    value: _selectedCuisine,
                                    decoration: const InputDecoration(
                                      labelText: 'Cuisine',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _cuisines.map((cuisine) {
                                      return DropdownMenuItem(
                                        value: cuisine,
                                        child: Text(cuisine),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedCuisine = newValue;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // location (venue note) box
                                  TextFormField(
                                    controller: _venueController,
                                    decoration: const InputDecoration(
                                      labelText: 'Location',
                                      border: OutlineInputBorder(),
                                    ),
                                    textCapitalization: TextCapitalization.sentences,
                                  ),
                                  const SizedBox(height: 24),

                                  // save 
                                  ElevatedButton(
                                    onPressed: _isSaving ? null : _saveMeal,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _isEditing ? 'Update Meal' : 'Save Meal',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                  ),
                                  const SizedBox(height: 8),

                                  // cancel button
                                  TextButton(
                                    onPressed: _isSaving
                                        ? null
                                        : () {
                                            Navigator.of(context).pop(false);
                                          },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
}