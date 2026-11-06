import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Fast Food', 'Dining', 'Grocery', 'Other'];

  late Future<List<Map<String, dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = _fetchLogsWithMeals();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchLogsWithMeals() async {
    final logs = await DatabaseHelper.instance.getAllLogs();
    final meals = await DatabaseHelper.instance.getAllMeals();

    final mealMap = {for (var m in meals) m['id']: m};

    List<Map<String, dynamic>> combined = [];
    for (var log in logs) {
      final meal = mealMap[log['meal_id'] ?? log['mealId']];
      combined.add({
        'id': log['id'],
        'spotName': meal != null ? meal['name'] : 'Unknown Spot',
        'category': meal != null ? meal['cuisine'] : 'Other',
        'costMinor': log['actual_price_minor'] ?? log['amount'] ?? 0,
        'dateStr': (log['purchased_at'] ?? log['date'] ?? '').toString().split('T')[0],
        'note': log['note'] ?? log['notes'] ?? '',
      });
    }
    return combined;
  }

  void _confirmDeleteLog(int logId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Are you sure you want to remove this purchase log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DatabaseHelper.instance.deletePurchaseLog(logId);
              if (!mounted) return;
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Insights'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Filter chip widget for categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // SQLite Data Stream
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _dataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allLogs = snapshot.data ?? [];

                  // Filter logs based on selected category
                  final filteredLogs = _selectedCategory == 'All'
                      ? allLogs
                      : allLogs.where((log) => log['category'] == _selectedCategory).toList();

                  // calculate total and average spent
                  final totalSpentMinor = filteredLogs.fold<int>(
                    0,
                    (sum, log) => sum + (log['costMinor'] as int),
                  );
                  final totalSpentDollars = totalSpentMinor / 100.0;
                  final avgSpentDollars = filteredLogs.isNotEmpty
                      ? totalSpentDollars / filteredLogs.length
                      : 0.0;

                  return Column(
                    children: [
                      // summary cards for total spent and average per meal
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total spent', style: TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${totalSpentDollars.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Avg per meal', style: TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${avgSpentDollars.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // show empty state if no logs, else show list of logs 
                      Expanded(
                        child: filteredLogs.isEmpty
                            ? Card(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Empty state:\nNo meals logged yet. Log one from a spot to see totals.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey, fontSize: 15),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredLogs.length,
                                itemBuilder: (context, index) {
                                  final item = filteredLogs[index];
                                  final costStr = ((item['costMinor'] as int) / 100.0).toStringAsFixed(2);
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: ListTile(
                                      title: Text(
                                        item['spotName'],
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text('${item['category']} • ${item['dateStr']}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '\$$costStr',
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                            onPressed: () => _confirmDeleteLog(item['id']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}