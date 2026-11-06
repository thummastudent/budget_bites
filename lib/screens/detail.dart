import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../database/database_helper.dart';
import '../models/purchase_log.dart';

class Details extends StatefulWidget {
  final Meal meal;

  const Details({super.key, required this.meal});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final _costController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLogging = false;
  
  
  @override
  void initState() {
    super.initState();
    // Default cost field  
    final defaultPrice =
        (widget.meal.estimatedPriceMinor / 100).toStringAsFixed(2);
    _costController.text = defaultPrice;
  }

  @override
  void dispose() {
    _costController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Function to pick a date using a date picker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Log the meal with the provided cost, date, and note
  Future<void> _logMeal() async {
    final costText = _costController.text.trim().replaceAll('\$', '');
    final parsedCost = double.tryParse(costText);

    if (parsedCost == null || parsedCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive cost.')),
      );
      return;
    }

    setState(() {
      _isLogging = true;
    });

    final costMinor = (parsedCost * 100).round();
    final log = PurchaseLog(
      mealId: widget.meal.id!,
      purchasedAt: _selectedDate,
      actualPriceMinor: costMinor,
      note: _noteController.text.trim(),
    );

    await DatabaseHelper.instance.insertPurchaseLog(log);

    if (!mounted) return;

    setState(() {
      _isLogging = false;
      _noteController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal logged successfully!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final priceFormatted =
        (widget.meal.estimatedPriceMinor / 100).toStringAsFixed(2);
    final dateStr =
        '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}';


    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.meal.name} Details'),
        centerTitle: true,
     
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            // detail view header card with meal name, cuisine, and usual price
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.meal.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                   
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(widget.meal.cuisine),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        
                        
                        Text(
                          'Usual: \$$priceFormatted',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    if (widget.meal.venueNote.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.meal.venueNote,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // implementation of log meal form
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Log a Purchase',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _costController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Cost (\$)',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(dateStr),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        hintText: 'e.g., Lunch with friends',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLogging ? null : _logMeal,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLogging
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Log meal',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
      
            const SizedBox(height: 20),

            //implementation of purchase logs for this food
            const Text(
              'Logs for this spot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('No purchases recorded yet.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}