class PantryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final DateTime expiryDate;
  final DateTime addedDate;

  PantryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.addedDate,
  });

  int get daysUntilExpiry {
    final now = DateTime.now();
    final difference = expiryDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  bool get isExpired => daysUntilExpiry < 0;

  bool get isExpiringSoon => daysUntilExpiry >= 0 && daysUntilExpiry <= 7;

  String get expiryStatus {
    if (isExpired) return 'expired';
    if (isExpiringSoon) return 'warning';
    return 'good';
  }

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: json['quantity'],
      unit: json['unit'],
      expiryDate: DateTime.parse(json['expiry_date']),
      addedDate: DateTime.parse(json['added_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate.toIso8601String(),
      'added_date': addedDate.toIso8601String(),
    };
  }

  PantryItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    DateTime? expiryDate,
    DateTime? addedDate,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}