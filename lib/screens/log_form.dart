import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/meal.dart';
import '../models/purchase_log.dart';

// form for adding or editing one purchase
// stateful because it has the text boxes and the date that can change
class LogForm extends StatefulWidget {
  final Meal meal;
  final PurchaseLog? log; // null means adding a new one and not null means editing

  const LogForm({super.key, required this.meal, this.log});

  @override
  State<LogForm> createState() {
    return _LogFormState();
  }
}

class _LogFormState extends State<LogForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _costController;
  late TextEditingController _noteController;
  late DateTime _purchasedAt;
  bool _isSaving = false;

  bool get _isEditing {
    return widget.log != null;
  }

  @override
  void initState() {
    super.initState();

    // if editing fill in the old values so the user can change them
    String startingCost = '';
    if (_isEditing) {
      startingCost = (widget.log!.actualPriceMinor / 100).toStringAsFixed(2);
    }
    _costController = TextEditingController(text: startingCost);
    _noteController = TextEditingController(text: widget.log?.note ?? '');
    _purchasedAt = widget.log?.purchasedAt ?? DateTime.now();
  }

  // clean up the text boxes when the form closes so theres no memory leaks
  @override
  void dispose() {
    _costController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // checks the cost box and returns an error message or null if its fine
  String? _validateCost(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter what you paid';
    }

    final amount = double.tryParse(text);
    if (amount == null) {
      return 'Enter a number like 8.50';
    }
    if (amount <= 0) {
      return 'Cost has to be more than \$0';
    }
    if (amount > 1000) {
      return 'That seems too high, max is \$1000';
    }
    return null;
  }

  // opens the calendar so u can pick the date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchasedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _purchasedAt = picked;
      });
    }
  }

  // saves to sqlite so if its editing it updates and if not it inserts a new one
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
    });

    // save in cents so theres no weird rounding stuff
    final costCents = (double.parse(_costController.text.trim()) * 100).round();
    final log = PurchaseLog(
      id: widget.log?.id,
      mealId: widget.meal.id!,
      purchasedAt: _purchasedAt,
      actualPriceMinor: costCents,
      note: _noteController.text.trim(),
    );

    try {
      if (_isEditing) {
        await DatabaseHelper.instance.updatePurchaseLog(log.id!, log.toMap());
      } else {
        await DatabaseHelper.instance.insertPurchaseLog(log.toMap());
      }
      if (!mounted) return;

      // sending back true tells the activity screen to reload
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save, try again')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _purchasedAt;

    String title = 'Log Purchase';
    if (_isEditing) {
      title = 'Edit Purchase';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.meal.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // cost box
                TextFormField(
                  controller: _costController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Cost',
                    prefixText: '\$ ',
                  ),
                  validator: _validateCost,
                ),
                const SizedBox(height: 16),

                // date row with a button to change it
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Date: ${d.month}/${d.day}/${d.year}'),
                  trailing: TextButton(
                    onPressed: _pickDate,
                    child: const Text('Change'),
                  ),
                ),
                const SizedBox(height: 16),

                // note is optional
                TextFormField(
                  controller: _noteController,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Saving...' : 'Save'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed:
                      _isSaving ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}