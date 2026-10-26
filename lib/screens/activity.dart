import 'package:flutter/material.dart';
import '../models/meal.dart';


class ActivityScreen extends StatefulWidget {
  final Meal meal;

  const ActivityScreen({super.key, required this.meal});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

// Activity screen to display the purchase log for a specific meal
class _ActivityScreenState extends State<ActivityScreen> {
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
           
            // Meal Summary Card
            Card(
              elevation: 2,
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
                    
                    // display cuisine and target price
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(label: Text(widget.meal.cuisine)),
                        Text(
                          'Target: \$${(widget.meal.estimatedPriceMinor / 100).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Purchase Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // purchase log list (to be implemented)
            const Expanded(
              child: Center(
                child: Text('Purchase logs will appear here.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}