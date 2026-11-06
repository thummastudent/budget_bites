import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/meal.dart';
import '../models/purchase_log.dart';
import '../widgets/log_tile.dart';

// activity screen for one meal so it shows all its purchases and like lets you log new ones
class ActivityScreen extends StatefulWidget {
  final Meal meal;

  const ActivityScreen({super.key, required this.meal});

  @override
  State<ActivityScreen> createState() {
    return _ActivityScreenState();
  }
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<PurchaseLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  // gets this meals purchases from sqlite so the newest ones show first
  Future<void> _loadLogs() async {
    final maps = await DatabaseHelper.instance.getLogsForMeal(widget.meal.id!);

    List<PurchaseLog> logs = [];

    for (var map in maps) {
      logs.add(PurchaseLog.fromMap(map));
    }

    // if the user left the screen while it was loading dont update anything
    if (!mounted) return;

    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  // adds up everything spent at this meal and its in cents
  int get _totalSpentCents {
    int total = 0;

    for (var log in _logs) {
      total += log.actualPriceMinor;
    }

    return total;
  }

  // turns cents into like $8.95
  String _money(int cents) {
    return '\$${(cents / 100).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.meal.name} Activity'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            const Text(
              'Purchase Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildLogList()),
          ],
        ),
      ),
    );
  }

  // the card at the top so it shows the meal name and cuisine and target price and how much u spent here
  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.meal.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(label: Text(widget.meal.cuisine)),
                Text(
                  'Target: ${_money(widget.meal.estimatedPriceMinor)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Spent here: ${_money(_totalSpentCents)} across ${_logs.length} purchase(s)',
            ),
          ],
        ),
      ),
    );
  }

  // shows a spinner while loading and a message if theres no purchases or else the list
  Widget _buildLogList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logs.isEmpty) {
      return const Center(
        child: Text(
          'No purchases logged yet.\nTap "Log purchase" to add one.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      // extra space at the bottom so the button doesnt cover the last one
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return LogTile(log: log, onTap: () {});
      },
    );
  }
}