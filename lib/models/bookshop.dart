import 'package:thot_tfg_2025_26/services/book_service.dart';

class Bookshop {
  final String name;
  final String address;
  final String? phone;

  Bookshop({
    required this.name,
    required this.address,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory Bookshop.fromMap(Map<String, dynamic> map) {
    return Bookshop(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}