// Modelo da Farmácia/Vendedor
class VendorModel {
  final String id;           // UID do Firebase Auth
  final String name;         // Nome da farmácia
  final String ownerName;    // Nome do responsável
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String openingHours;
  final bool   hasDelivery;
  final bool   isApproved;   // Aprovado pelo admin
  final bool   isActive;     // Ativo/inativo
  final DateTime createdAt;

  const VendorModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.openingHours,
    required this.hasDelivery,
    required this.isApproved,
    required this.isActive,
    required this.createdAt,
  });

  // Status legível
  String get statusLabel {
    if (!isApproved) return 'Aguardando aprovação';
    if (!isActive)   return 'Inativa';
    return 'Ativa';
  }

  Map<String, dynamic> toMap() => {
    'id':           id,
    'name':         name,
    'ownerName':    ownerName,
    'email':        email,
    'phone':        phone,
    'address':      address,
    'city':         city,
    'state':        state,
    'zipCode':      zipCode,
    'openingHours': openingHours,
    'hasDelivery':  hasDelivery,
    'isApproved':   isApproved,
    'isActive':     isActive,
    'createdAt':    createdAt.toIso8601String(),
  };

  factory VendorModel.fromMap(Map<String, dynamic> map) => VendorModel(
    id:           map['id']           ?? '',
    name:         map['name']         ?? '',
    ownerName:    map['ownerName']    ?? '',
    email:        map['email']        ?? '',
    phone:        map['phone']        ?? '',
    address:      map['address']      ?? '',
    city:         map['city']         ?? '',
    state:        map['state']        ?? '',
    zipCode:      map['zipCode']      ?? '',
    openingHours: map['openingHours'] ?? '',
    hasDelivery:  map['hasDelivery']  ?? false,
    isApproved:   map['isApproved']   ?? false,
    isActive:     map['isActive']     ?? true,
    createdAt:    DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
  );

  VendorModel copyWith({
    String? name, String? ownerName, String? phone,
    String? address, String? city, String? state,
    String? zipCode, String? openingHours,
    bool? hasDelivery, bool? isApproved, bool? isActive,
  }) => VendorModel(
    id:           id,
    name:         name         ?? this.name,
    ownerName:    ownerName    ?? this.ownerName,
    email:        email,
    phone:        phone        ?? this.phone,
    address:      address      ?? this.address,
    city:         city         ?? this.city,
    state:        state        ?? this.state,
    zipCode:      zipCode      ?? this.zipCode,
    openingHours: openingHours ?? this.openingHours,
    hasDelivery:  hasDelivery  ?? this.hasDelivery,
    isApproved:   isApproved   ?? this.isApproved,
    isActive:     isActive     ?? this.isActive,
    createdAt:    createdAt,
  );
}
