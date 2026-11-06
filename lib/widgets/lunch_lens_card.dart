import 'package:flutter/material.dart';
import 'package:budget_bites/helpers/lunch_lens_helper.dart';

// this part is the card that shows the lunch lens guess on the detail screen
// its stateful so it can remember if the user hit not now
class LunchLensCard extends StatefulWidget {
  final LunchLensResult result; // this part is the guess from lunch lens
  final void Function(String price) onApply; // this part sends the price back so the screen can fill the cost box

  const LunchLensCard({super.key, required this.result, required this.onApply});

  @override
  State<LunchLensCard> createState() {
    return _LunchLensCardState();
  }
}

class _LunchLensCardState extends State<LunchLensCard> {
  bool hidden = false; // this part turns true after they hit not now so the card goes away

  // this part runs when they hit apply so it sends the guess back to fill the cost box
  // it only fills the box and nothing saves until they hit save on the form
  void applyGuess() {
    int guessCents = widget.result.estimateCents!;
    double dollars = guessCents / 100;
    String price = dollars.toStringAsFixed(2); // like 8.95 with no dollar sign since the box already has one
    widget.onApply(price);
  }

  // this part runs when they hit not now so it hides the card
  void hideCard() {
    setState(() {
      hidden = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    LunchLensResult result = widget.result;

    // this part shows nothing if they already hit not now
    if (hidden == true) {
      return const SizedBox.shrink();
    }

    // this part shows a simple card if theres not enough purchases yet so we dont try to guess
    if (result.hasEstimate == false) {
      // this part uses logsNeeded so if we change how many purchases it needs the message changes too
      String needMoreText = 'Log ' + logsNeeded.toString() + ' purchases here to get a guess.';

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline),
                  SizedBox(width: 8),
                  Text('Smart helper', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(result.reason), // this part says not enough data yet
              Text(needMoreText),
            ],
          ),
        ),
      );
    }

    // this part gets the color from the app theme so it matches light and dark mode
    Color cardColor = Theme.of(context).colorScheme.secondaryContainer;

    // this part gets the guess and the ! means we know its not null here
    int guessCents = result.estimateCents!;

    // this part turns the guess into text like next meal about $8.95
    String estimateText = 'Next meal about ' + formatMoney(guessCents);

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // this part is the title so the user knows its just a suggestion
            const Row(
              children: [
                Icon(Icons.lightbulb_outline),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Smart helper (suggested, not guaranteed)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // this part is the guess in big text
            Text(
              estimateText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            // this part shows the prices it used so the user knows why
            Text(result.reason),
            const SizedBox(height: 8),

            // this part is the buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: hideCard,
                  child: const Text('Not now'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: applyGuess,
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}