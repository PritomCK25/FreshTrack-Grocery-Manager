
class Grocery {
  final int id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final String? notes;

  Grocery({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.purchaseDate,
    this.expiryDate,
    this.notes,
  });

  // Convert Supabase data into a Grocery object.
  factory Grocery.fromMap(Map<String, dynamic> map) {
    return Grocery(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'],
      purchaseDate: DateTime.parse(map['purchase_date']),
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'])
          : null,
      notes: map['notes'],
    );
  }

  // Convert a Grocery object into data for Supabase.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'purchase_date':
          purchaseDate.toIso8601String().split('T')[0],
      'expiry_date': expiryDate == null
          ? null
          : expiryDate!.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }
}
