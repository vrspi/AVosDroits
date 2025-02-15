import 'dart:math';

class LegalService {
  final String name;
  final String type; // 'lawyer', 'association', 'administration', etc.
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? email;
  final String? website;
  final List<String> services;
  final Map<String, String> openingHours;
  final bool hasFreeLegalAid;
  final List<String> languages;

  LegalService({
    required this.name,
    required this.type,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.email,
    this.website,
    required this.services,
    required this.openingHours,
    required this.hasFreeLegalAid,
    required this.languages,
  });

  factory LegalService.fromJson(Map<String, dynamic> json) {
    return LegalService(
      name: json['name'],
      type: json['type'],
      description: json['description'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      services: List<String>.from(json['services']),
      openingHours: Map<String, String>.from(json['openingHours']),
      hasFreeLegalAid: json['hasFreeLegalAid'],
      languages: List<String>.from(json['languages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'email': email,
      'website': website,
      'services': services,
      'openingHours': openingHours,
      'hasFreeLegalAid': hasFreeLegalAid,
      'languages': languages,
    };
  }

  double distanceTo(double userLat, double userLng) {
    // Simple Haversine formula for distance calculation
    const double earthRadius = 6371; // in kilometers
    final double latDiff = _toRadians(userLat - latitude);
    final double lngDiff = _toRadians(userLng - longitude);
    final double a = _haversine(latDiff) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(userLat)) *
            _haversine(lngDiff);
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  double _haversine(double rad) {
    return pow(sin(rad / 2), 2).toDouble();
  }
} 