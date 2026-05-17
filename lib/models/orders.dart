import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? id;
  final String isbn;
  final String bookTitle;
  final double price;
  final DateTime date;
  final String state; // Estado: 'Comprado' o 'En deposito' (o similar)
  final int quantity;
  final String idEditorial;
  final String editorialName;
  final String idBookshop;

  OrderModel({
    this.id,
    required this.isbn,
    required this.bookTitle,
    required this.price,
    required this.date,
    required this.state,
    required this.quantity,
    required this.idEditorial,
    required this.editorialName,
    required this.idBookshop,
  });

  Map<String, dynamic> toMap() {
    return {
      'isbn': isbn,
      'bookTitle': bookTitle,
      'price': price,
      'date': Timestamp.fromDate(date),
      'state': state,
      'quantity': quantity,
      'idEditorial': idEditorial,
      'editorialName': editorialName,
      'idBookshop': idBookshop,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      isbn: map['isbn'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      state: map['state'] ?? '',
      quantity: map['quantity'] ?? 0,
      idEditorial: map['idEditorial'] ?? '',
      editorialName: map['editorialName'] ?? '',
      idBookshop: map['idBookshop'] ?? '',
    );
  }
}
