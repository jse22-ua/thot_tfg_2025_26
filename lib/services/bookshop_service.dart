import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thot_tfg_2025_26/services/firebase_service.dart';
import '../models/bookshop.dart';

class BookshopService {

  Future<String> addBookShop(Bookshop bookshop) async{
    final DocumentReference docRef = await FirebaseService.firestore.collection('bookshops').add(bookshop.toMap());
    return docRef.id;
  }

  Future<Bookshop?> getBookShop(String id) async{
      final docRef = FirebaseService.firestore.collection("bookshops").doc(id);
      final docSnap = await docRef.get();

      if (docSnap.exists && docSnap.data() != null) {
        return Bookshop.fromMap(docSnap.data()!);
      }
      return null;
  }


}