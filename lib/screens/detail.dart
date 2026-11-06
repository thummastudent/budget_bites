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
  
  late Future<List<PurchaseLog>> _logsFuture;
  
  @override
  void initState() {
    super.initState();
    // Default cost field  
    final defaultPrice = (widget.meal.estimatedPriceMinor / 100).toStringAsFixed(2);
    _costController.text = defaultPrice;
    _refreshLogs();
  }

  @override
  void dispose() {
    _costController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Refresh the logs for the current meal
  void _refreshLogs() {
    setState(() {
      _logsFuture = DatabaseHelper.instance.getLogsForMeal(widget.meal.id!).then(
        (maps) => maps.map((map) => PurchaseLog.fromMap(map)).toList(),
      );
    });
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

    await DatabaseHelper.instance.insertPurchaseLog(log.toMap());

    if (!mounted) return;

    setState(() {
      _isLogging = false;
      _noteController.clear();
    });

    _refreshLogs();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal logged successfully!')),
    );
  }

  Future<bool> _confirmAndDeleteLog(PurchaseLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Purchase Log?'),
        content: Text(
            'Delete log of \$${(log.actualPriceMinor / 100).toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && log.id != null) {
      await DatabaseHelper.instance.deletePurchaseLog(log.id!);
      _refreshLogs();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final priceFormatted = (widget.meal.estimatedPriceMinor / 100).toStringAsFixed(2);
   
    final dateStr = '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}';

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
            // Detail view header card
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
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
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

            // Log meal form (Inline)
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _costController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
      
            const SizedBox(height: 24),

            const Text(
              'Logs for this spot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Added FutureBuilder to consume the _logsFuture data
            FutureBuilder<List<PurchaseLog>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No purchases recorded yet.'),
                    ),
                  );
                }

                final logs = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true, // Prevents layout crash inside SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final logPrice = (log.actualPriceMinor / 100).toStringAsFixed(2);
                    final logDate = '${log.purchasedAt.month}/${log.purchasedAt.day}/${log.purchasedAt.year}';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text('\$$logPrice', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(log.note.isEmpty ? 'No notes' : log.note),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(logDate, style: const TextStyle(color: Colors.grey)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () => _confirmAndDeleteLog(log),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}