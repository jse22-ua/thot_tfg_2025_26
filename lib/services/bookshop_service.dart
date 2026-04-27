import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bookshop.dart';

class BookshopService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> addBookShop(Bookshop bookshop) async{
    final DocumentReference docRef = await firestore.collection('bookshops').add(bookshop.toMap());
    return docRef.id;
  }
}