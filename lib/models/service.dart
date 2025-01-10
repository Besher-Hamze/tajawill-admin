import 'package:tajawil_admin/models/category.dart';

class Service {
  final String id;
  final String name;
  final String description;
  final String address;
  final double longitude;
  final double latitude;
  final String imageUrl;
  final String userId;
  final CategoryModel category;
  final double averageRating;
  final int totalRates;
  final String governorates;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.imageUrl,
    required this.category,
    required this.userId,
    required this.governorates,
    this.averageRating = 0.0,
    this.totalRates = 0,
  });

  factory Service.fromMap(Map<String, dynamic> map, String id) {
    return Service(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      longitude: map['longitude']?.toDouble() ?? 0.0,
      latitude: map['latitude']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      userId: map['userId'] ?? '',
      category: CategoryModel.fromMap(map['category'], ""),
      averageRating: map['averageRating']?.toDouble() ?? 0.0,
      totalRates: map['totalRates'] ?? 0,
      governorates: map['governorates'] ?? "حلب"
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'imageUrl': imageUrl,
      'userId': userId,
      'category': category.toMap(),
      'averageRating': averageRating,
      'totalRates': totalRates,
      'governorates':governorates
    };
  }
}
