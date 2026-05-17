import 'package:cloud_firestore/cloud_firestore.dart';

class ReturnRecord {
  final String? id;
  final String idBookStock;
  final String isbn;
  final String title;
  final String author;
  final String editorialName;
  final String idEditorial;
  final String idBookshop;
  final int quantity;
  final DateTime date;

  ReturnRecord({
    this.id,
    required this.idBookStock,
    required this.isbn,
    required this.title,
    required this.author,
    required this.editorialName,
    required this.idEditorial,
    required this.idBookshop,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'idBookStock': idBookStock,
      'isbn': isbn,
      'title': title,
      'author': author,
      'editorialName': editorialName,
      'idEditorial': idEditorial,
      'idBookshop': idBookshop,
      'quantity': quantity,
      'date': Timestamp.fromDate(date),
    };
  }

  factory ReturnRecord.fromMap(Map<String, dynamic> map, String documentId) {
    return ReturnRecord(
      id: documentId,
      idBookStock: map['idBookStock'] ?? '',
      isbn: map['isbn'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      editorialName: map['editorialName'] ?? '',
      idEditorial: map['idEditorial'] ?? '',
      idBookshop: map['idBookshop'] ?? '',
      quantity: map['quantity'] ?? 0,
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
