// meal class to represent a meal entry in the database
class Meal {
  final int? id;
  final String name;
  final String venueNote;
  final String cuisine;
  final int estimatedPriceMinor; 
// Constructor for the Meal class
  const Meal({
    this.id,
    required this.name,
    this.venueNote = '',
    required this.cuisine,
    required this.estimatedPriceMinor,
  });

  // Convert  Meal object into Map for SQLite to update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'venue_note': venueNote,
      'cuisine': cuisine,
      'estimated_price_minor': estimatedPriceMinor,
    };
  }

  // Create Meal object from a database Map query result
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as int?,
      name: map['name'] as String,
      venueNote: (map['venue_note'] as String?) ?? '',
      cuisine: map['cuisine'] as String,
      estimatedPriceMinor: map['estimated_price_minor'] as int,
    );
  }

  // Helper method - updates records without changing the original object 
  Meal copyWith({
    int? id,
    String? name,
    String? venueNote,
    String? cuisine,
    int? estimatedPriceMinor,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      venueNote: venueNote ?? this.venueNote,
      cuisine: cuisine ?? this.cuisine,
      estimatedPriceMinor: estimatedPriceMinor ?? this.estimatedPriceMinor,
    );
  }
}