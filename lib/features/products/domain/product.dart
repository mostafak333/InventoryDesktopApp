class Product {
  final int? id;
  final String name;
  final double wholesalePrice;
  final double sellingPrice;
  final int quantity;
  final int displayQuantity;
  final String status;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    required this.wholesalePrice,
    required this.sellingPrice,
    required this.quantity,
    this.displayQuantity = 0,
    required this.status,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      wholesalePrice: (map['wholesalePrice'] as num).toDouble(),
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      displayQuantity: map['displayQuantity'] == null
          ? 0
          : (map['displayQuantity'] as num).toInt(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'wholesalePrice': wholesalePrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'displayQuantity': displayQuantity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
