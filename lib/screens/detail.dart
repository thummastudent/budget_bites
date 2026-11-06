import 'package:flutter/material.dart';
import '../models/meal.dart';

class Details extends StatefulWidget {
  final Meal meal;

  const Details({super.key, required this.meal});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    final priceFormatted =
        (widget.meal.estimatedPriceMinor / 100).toStringAsFixed(2);

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

            // todo: implementation of Smart Helper ("Lunch Lens") 
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Smart Helper ("Lunch Lens") placeholder'),
              ),
            ),
            const SizedBox(height: 20),

            // todo: implementation of log meal form
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Log Meal Form placeholder'),
              ),
            ),
            const SizedBox(height: 20),

            // todo: implementation of purchase logs for this food
            const Text(
              'Logs for this spot',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('No purchase logs recorded yet.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}