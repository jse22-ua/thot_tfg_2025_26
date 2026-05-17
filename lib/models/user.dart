class User{
  final String nombre;
  final String email;
  final bool isAdmin;
  final String bookshopId;

  User({
    required this.email,
    required this.nombre,
    this.isAdmin = true,
    required this.bookshopId,
  });

  Map<String, dynamic> toMap(){
    return {
      'email': email,
      'nombre': nombre,
      'isAdmin': isAdmin,
      'bookshopId': bookshopId,
      'createdAt': DateTime.now().toIso8601String(),
  };
  }
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      isAdmin: map['isAdmin'] ?? true,
      bookshopId: map['bookshopId'] ?? '',
    );
  }

  
}