import 'package:flutter/material.dart';
import '../models/purchase_log.dart';

// shows one purchase log row like cost, date, note
// stateless because like it only displays data that its given
class LogTile extends StatelessWidget {
  final PurchaseLog log;
  final VoidCallback onTap;

  const LogTile({super.key, required this.log, required this.onTap});

  String _formatDate(DateTime d) {
    return '${d.month}/${d.day}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    // prices are stored in cents so divide by 100 for display
    final cost = '\$${(log.actualPriceMinor / 100).toStringAsFixed(2)}';
    final date = _formatDate(log.purchasedAt);

    String subtitle = date;

    if (log.note.isNotEmpty) {
      subtitle = '$date • ${log.note}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.receipt_long),
        title: Text(cost, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.edit, size: 18),
      ),
    );
  }
}