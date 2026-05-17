class BookStock {
  final String? id; // ID del documento en Firestore
  final String id_book;
  final int quantity;
  final String state;
  final String? ubication;
  final double supplier_price;
  final double sale_price;
  final String id_bookshop;
  
  // Datos denormalizados del libro para eficiencia en listados
  final String? title;
  final String? author;
  final String? category;
  final String? editorialName;
  final String? editorialId;
  final String? createdAt;

  BookStock({
    this.id,
    required this.id_book,
    required this.quantity,
    required this.state,
    required this.supplier_price,
    required this.sale_price,
    this.ubication,
    required this.id_bookshop,
    this.title,
    this.author,
    this.category,
    this.editorialName,
    this.editorialId,
    this.createdAt
  });

  Map<String, dynamic> toMap() {
    return {
      'id_book' : id_book,
      'id_bookshop': id_bookshop,
      'quantity' : quantity,
      'state' : state,
      'ubication' : ubication,
      'supplier_price' : supplier_price,
      'sale_price' : sale_price,
      'title': title,
      'author': author,
      'category': category,
      'editorialName': editorialName,
      'editorialId': editorialId,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory BookStock.fromMap(Map<String, dynamic> map) {
    return BookStock(
      id: map['id'],
      id_book: map['id_book'] ?? '',
      quantity: map['quantity'] ?? 0,
      state: map['state'] ?? '',
      supplier_price: (map['supplier_price'] ?? 0.0).toDouble(),
      sale_price: (map['sale_price'] ?? 0.0).toDouble(),
      ubication: map['ubication'],
      id_bookshop: map['id_bookshop'] ?? '',
      title: map['title'],
      author: map['author'],
      category: map['category'],
      editorialName: map['editorialName'],
      editorialId: map['editorialId'],
      createdAt: map['createdAt']
    );
  }
}