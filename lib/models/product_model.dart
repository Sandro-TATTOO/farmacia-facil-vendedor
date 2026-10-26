class ProductModel {
  final String id;
  final String pharmacyId;
  final String name;
  final String description;
  final String category;    // Ex: Analgésico, Antibiótico, Vitamina
  final double price;
  final int    stock;
  final bool   requiresPrescription;
  final bool   isActive;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.pharmacyId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    required this.requiresPrescription,
    required this.isActive,
    required this.createdAt,
  });

  bool get isAvailable => isActive && stock > 0;

  String get formattedPrice =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  Map<String, dynamic> toMap() => {
    'id':                   id,
    'pharmacyId':           pharmacyId,
    'name':                 name,
    'description':          description,
    'category':             category,
    'price':                price,
    'stock':                stock,
    'requiresPrescription': requiresPrescription,
    'isActive':             isActive,
    'createdAt':            createdAt.toIso8601String(),
  };

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
    id:                   map['id']                   ?? '',
    pharmacyId:           map['pharmacyId']           ?? '',
    name:                 map['name']                 ?? '',
    description:          map['description']          ?? '',
    category:             map['category']             ?? '',
    price:                (map['price'] ?? 0).toDouble(),
    stock:                map['stock']                ?? 0,
    requiresPrescription: map['requiresPrescription'] ?? false,
    isActive:             map['isActive']             ?? true,
    createdAt:            DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
  );

  ProductModel copyWith({
    String? name, String? description, String? category,
    double? price, int? stock, bool? requiresPrescription, bool? isActive,
  }) => ProductModel(
    id:                   id,
    pharmacyId:           pharmacyId,
    name:                 name                 ?? this.name,
    description:          description          ?? this.description,
    category:             category             ?? this.category,
    price:                price                ?? this.price,
    stock:                stock                ?? this.stock,
    requiresPrescription: requiresPrescription ?? this.requiresPrescription,
    isActive:             isActive             ?? this.isActive,
    createdAt:            createdAt,
  );
}
