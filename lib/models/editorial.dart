
class Editorial {
  final String name;
  final String? phone;
  final String? email;
  final int days_min_return;

  Editorial({
    required this.name,
    this.phone,
    this.email,
    required this.days_min_return
});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'days_min_return': days_min_return,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory Editorial.fromMap(Map<String, dynamic> map) {
    return Editorial(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      days_min_return: map['days_min_return'] ?? 0,
    );
  }

}