import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thot_tfg_2025_26/models/orders.dart';
import 'package:thot_tfg_2025_26/services/firebase_service.dart';

class OrderService {
  final CollectionReference _ordersRef = FirebaseService.firestore.collection('orders');

  Future<String?> addOrder(OrderModel order) async {
    try {
      final docRef = await _ordersRef.add(order.toMap());
      return docRef.id;
    } catch (e) {
      print("Error adding order: $e");
      return null;
    }
  }

  Future<List<OrderModel>> getOrdersByShop(String bookshopId) async {
    try {
      // Intentamos con orderBy primero
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _ordersRef
            .where('idBookshop', isEqualTo: bookshopId)
            .orderBy('date', descending: true)
            .get();
      } catch (e) {
        // Si falla por falta de índice, hacemos la consulta simple y ordenamos en memoria
        print("Fallback order: Index likely missing. $e");
        querySnapshot = await _ordersRef
            .where('idBookshop', isEqualTo: bookshopId)
            .get();
        
        final orders = querySnapshot.docs.map((doc) {
          return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        
        orders.sort((a, b) => b.date.compareTo(a.date));
        return orders;
      }

      return querySnapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error getting orders: $e");
      return [];
    }
  }

  Future<List<OrderModel>> searchOrdersByBookTitle(String bookshopId, String query) async {
    try {
      final querySnapshot = await _ordersRef
          .where('idBookshop', isEqualTo: bookshopId)
          .where('bookTitle', isGreaterThanOrEqualTo: query)
          .where('bookTitle', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error searching orders: $e");
      return [];
    }
  }
}
