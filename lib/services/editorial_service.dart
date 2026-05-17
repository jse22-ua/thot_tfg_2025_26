
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thot_tfg_2025_26/models/editorial.dart';
import 'package:thot_tfg_2025_26/services/firebase_service.dart';


class EditorialService {

  Future<String?> checkAndGetEditorialId(String name) async {
    final query = await FirebaseService.firestore
        .collection('editorials')
        .where('name', isEqualTo: name)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    } else {
      final editorial = Editorial(name:name, phone:'', email: '',days_min_return: 30);
      final DocumentReference docRef = await FirebaseService.firestore.collection('editorials').add(editorial.toMap());

      return docRef.id;
    }
  }

  Future<String?> addEditorial(Editorial editorial) async {
    final DocumentReference docRef = await FirebaseService.firestore.collection('editorials').add(editorial.toMap());
    return docRef.id;
  }

  Future<Editorial?> getEditorial(String id) async {
    final docRef = FirebaseService.firestore.collection("editorials").doc(id);
    final docSnap = await docRef.get();

    if (docSnap.exists && docSnap.data() != null) {
      return Editorial.fromMap(docSnap.data()!);
    }
    return null;
  }

  Future<Editorial?> getEditorialByName(String name) async {
    final query = await FirebaseService.firestore
        .collection('editorials')
        .where('name', isEqualTo: name)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;

      return Editorial.fromMap(doc.data());
    }

    return null;
  }

}