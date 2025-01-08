class Profile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  Profile copyWith({
    String? name,
    String? phone,
    String? address,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt,
    );
  }
} 