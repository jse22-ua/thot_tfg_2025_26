class Bookshop {
  final String? email;
  final String name;
  final String address;
  final String? phone;

  Bookshop({
    this.email,
    required this.name,
    required this.address,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'address': address,
      'phone': phone,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}