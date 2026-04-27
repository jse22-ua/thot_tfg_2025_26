class User{
  final String nombre;
  final String email;
  final String password;
  final bool isAdmin;
  final String bookshopId;

  User({
    required this.email,
    required this.nombre,
    required this.password,
    this.isAdmin = true,
    required this.bookshopId,
  });

  Map<String, dynamic> toMap(){
    return {
      'email': email,
      'nombre': nombre,
      'password': password,
      'isAdmin': isAdmin,
      'bookshopId': bookshopId,
      'createdAt': DateTime.now().toIso8601String(),
  };
  }
}