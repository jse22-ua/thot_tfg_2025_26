class Book {
  final String? isbn;
  final String title;
  final String author;
  final String category;
  final double price;
  final String? id_editorial;


  Book({this.isbn,
    required this.title,
    required this.author,
    required this.category,
    required this.price,
    this.id_editorial,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'category': category,
      'price': price,
      'id_editorial': id_editorial,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      category: map['category'] ?? '',
      price: map['price'] ?? '',
      id_editorial: map['id_editorial'] ?? '',
    );
  }
}