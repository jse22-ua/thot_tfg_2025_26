import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thot_tfg_2025_26/models/sale.dart';
import 'package:thot_tfg_2025_26/services/firebase_service.dart';

class SaleService {
  final CollectionReference _salesRef = FirebaseService.firestore.collection('sales');

  Future<String?> addSale(SaleModel sale) async {
    try {
      final docRef = await _salesRef.add(sale.toMap());
      return docRef.id;
    } catch (e) {
      print("Error adding sale: $e");
      return null;
    }
  }

  Future<List<SaleModel>> getSalesByShop(String bookshopId) async {
    try {
      print(bookshopId);
      final querySnapshot = await _salesRef
          .where('idBookshop', isEqualTo: bookshopId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return SaleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error getting sales: $e");
      return [];
    }
  }

  // Para estadísticas: Ventas del día
  Future<double> getTodaySalesAmount(String bookshopId) async {
    print(bookshopId);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final querySnapshot = await _salesRef
        .where('idBookshop', isEqualTo: bookshopId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    double total = 0;
    for (var doc in querySnapshot.docs) {
      total += (doc.data() as Map<String, dynamic>)['totalPrice'] ?? 0.0;
    }
    return total;
  }
}
