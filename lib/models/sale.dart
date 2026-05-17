import 'package:cloud_firestore/cloud_firestore.dart';

class SaleItem {
  final String idStock;
  final String bookTitle;
  final String author;
  final int quantity;
  final double unitPrice;
  final double supplierPrice; // Añadido para calcular beneficios
  final String? category;     // Añadido para estadísticas por género

  SaleItem({
    required this.idStock,
    required this.bookTitle,
    required this.author,
    required this.quantity,
    required this.unitPrice,
    required this.supplierPrice,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'idStock': idStock,
      'bookTitle': bookTitle,
      'author': author,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'supplierPrice': supplierPrice,
      'category': category,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      idStock: map['idStock'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      author: map['author'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      supplierPrice: (map['supplierPrice'] ?? 0.0).toDouble(),
      category: map['category'],
    );
  }
}

class SaleModel {
  final String? id;
  final List<SaleItem> items;
  final double totalPrice;
  final DateTime date;
  final String idBookshop;
  final String? customerName;

  SaleModel({
    this.id,
    required this.items,
    required this.totalPrice,
    required this.date,
    required this.idBookshop,
    this.customerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((i) => i.toMap()).toList(),
      'totalPrice': totalPrice,
      'date': Timestamp.fromDate(date),
      'idBookshop': idBookshop,
      'customerName': customerName,
      // Guardamos solo los IDs para facilitar consultas si fuera necesario
      'stockIds': items.map((i) => i.idStock).toList(),
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SaleModel(
      id: documentId,
      items: (map['items'] as List? ?? []).map((i) => SaleItem.fromMap(i)).toList(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      idBookshop: map['idBookshop'] ?? '',
      customerName: map['customerName'],
    );
  }
}
