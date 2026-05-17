import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thot_tfg_2025_26/models/return_record.dart';
import 'package:thot_tfg_2025_26/services/firebase_service.dart';

class ReturnService {
  final CollectionReference _returnsRef = FirebaseService.firestore.collection('returns');

  Future<bool> processReturn(ReturnRecord record) async {
    try {
      // 1. Añadir a la colección de devoluciones
      await _returnsRef.add(record.toMap());

      // 2. Eliminar o actualizar el stock del libro
      // En este flujo, asumimos que se devuelve todo el stock de ese registro de depósito
      await FirebaseService.firestore
          .collection('booksStock')
          .doc(record.idBookStock)
          .delete();

      return true;
    } catch (e) {
      print("Error processing return: $e");
      return false;
    }
  }

  Future<List<ReturnRecord>> getReturnsByShop(String bookshopId) async {
    try {
      final querySnapshot = await _returnsRef
          .where('idBookshop', isEqualTo: bookshopId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return ReturnRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error getting returns: $e");
      return [];
    }
  }
}
