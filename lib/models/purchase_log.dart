// purchase_log class to represent a purchase log entry in the database
class PurchaseLog {
  final int? id;
  final int mealId; 
  final DateTime purchasedAt;
  final int actualPriceMinor; 
  final String note;

// Constructor
  const PurchaseLog({
    this.id,
    required this.mealId,
    required this.purchasedAt,
    required this.actualPriceMinor,
    this.note = '',
  });

  // Convert PurchaseLog object into Map for SQLite insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meal_id': mealId,
      'purchased_at': purchasedAt.toIso8601String(), 
      'actual_price_minor': actualPriceMinor,
      'note': note,
    };
  }

  // Create PurchaseLog object from database Map query result
  factory PurchaseLog.fromMap(Map<String, dynamic> map) {
    return PurchaseLog(
      id: map['id'] as int?,
      mealId: map['meal_id'] as int,
      purchasedAt: DateTime.parse(map['purchased_at'] as String),
      actualPriceMinor: map['actual_price_minor'] as int,
      note: (map['note'] as String?) ?? '',
    );
  }

  // Helper method - updates records without changing the original object
  PurchaseLog copyWith({
    int? id,
    int? mealId,
    DateTime? purchasedAt,
    int? actualPriceMinor,
    String? note,
  }) {
    return PurchaseLog(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      actualPriceMinor: actualPriceMinor ?? this.actualPriceMinor,
      note: note ?? this.note,
    );
  }
}