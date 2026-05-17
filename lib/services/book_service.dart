import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thot_tfg_2025_26/models/editorial.dart';
import 'package:thot_tfg_2025_26/services/firebase_service.dart';
import 'package:thot_tfg_2025_26/utils/adapter.dart';
import '../models/book.dart';
import '../models/bookstock.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;


class BookService {

  Future<List<BookStock>> getBooksToReturn(String bookshopId) async {
    try {
      // 1. Filtrar por librería y por estado 'En deposito' directamente en Firestore
      // Esta es la parte más eficiente posible sin cambiar el modelo de datos
      final snapshot = await FirebaseService.firestore
          .collection('booksStock')
          .where('id_bookshop', isEqualTo: bookshopId)
          .where('state', isEqualTo: 'En deposito')
          .get();

      // 2. Obtener editoriales para conocer los días de devolución de cada una
      final editorialSnapshot = await FirebaseService.firestore.collection('editorials').get();
      Map<String, int> editorialReturnDays = {};
      for (var doc in editorialSnapshot.docs) {
        editorialReturnDays[doc.id] = doc.data()['days_min_return'] ?? 0;
      }

      // 3. Filtrar en memoria por la fecha
      List<BookStock> toReturn = [];
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final stock = BookStock.fromMap({...doc.data(), 'id': doc.id});
        
        if (stock.createdAt != null && stock.editorialId != null) {
          final createdAt = DateTime.parse(stock.createdAt!);
          final daysElapsed = now.difference(createdAt).inDays;
          final minDays = editorialReturnDays[stock.editorialId] ?? 30;

          if (daysElapsed > minDays) {
            toReturn.add(stock);
          }
        }
      }
      return toReturn;
    } catch (e) {
      print("Error en getBooksToReturn: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getInventoryAlerts(String bookshopId) async {
    try {
      final stockSnapshot = await FirebaseService.firestore
          .collection('booksStock')
          .where('id_bookshop', isEqualTo: bookshopId)
          .get();

      final editorialSnapshot = await FirebaseService.firestore.collection('editorials').get();
      Map<String, Editorial> editorialMap = {};
      for (var doc in editorialSnapshot.docs) {
        editorialMap[doc.id] = Editorial.fromMap(doc.data());
      }

      List<Map<String, dynamic>> alerts = [];

      for (var doc in stockSnapshot.docs) {
        final data = doc.data();
        final int quantity = data['quantity'] ?? 0;
        final String title = data['title'] ?? 'Libro sin título';
        final String isbn = data['id_book'] ?? '';
        final String createdAtStr = data['createdAt'] ?? '';
        final String editorialId = data['editorialId'] ?? '';
        
        if (quantity < 5 && quantity > 0) {
          alerts.add({
            'type': 'low_stock',
            'title': 'Bajo Stock: $title',
            'message': 'Solo quedan $quantity unidades.',
            'isbn': isbn,
          });
        }

        if (quantity == 0) {
          alerts.add({
            'type': 'low_stock',
            'title': 'Sin Stock: $title',
            'message': 'No quedan unidades',
            'isbn': isbn,
          });
        }

        if (createdAtStr.isNotEmpty) {
          final DateTime createdAt = DateTime.parse(createdAtStr);
          final DateTime now = DateTime.now();
          final int daysElapsed = now.difference(createdAt).inDays;
          
          if (editorialId != '') {
            final editorial = editorialMap[editorialId];
            final String nameEditorial = editorial?.name ?? 'Editorial desconocida';
            final int minDays = editorial?.days_min_return ?? 30;

            if (daysElapsed >= minDays) {
              alerts.add({
                'type': 'return_period',
                'title': 'Plazo de Devolución: $title',
                'message': 'Han pasado $daysElapsed días. Plazo de $minDays días superado. La editorial $nameEditorial ya te permite devolverlo.',
                'isbn': isbn,
              });
            }
          }
        }


      }
      return alerts;
    } catch (e) {
      print("Error en getInventoryAlerts: $e");
      return [];
    }
  }

  Future<String?> addBook(Book book) async{
    try{
      await FirebaseService.firestore.collection('books').doc(book.isbn).set(book.toMap());
      return book.isbn;
    }catch(ex){
      return null;
    }

  }

  Future<String?> addBookStock(BookStock bookStock) async{
    final DocumentReference docRef = await FirebaseService.firestore.collection('booksStock').add(bookStock.toMap());
    return docRef.id;
  }


  Future<List<BookStock>> getAllStockByShop(String bookshopId) async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection('booksStock')
          .where('id_bookshop', isEqualTo: bookshopId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BookStock.fromMap(data);
      }).toList();
    } catch (e) {
      print("Error en getAllStockByShop: $e");
      return [];
    }
  }

  Future<List<BookStock>> getStockByShop(String bookshopId, int limit) async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection('booksStock')
          .where('id_bookshop', isEqualTo: bookshopId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Guardamos el ID del documento para poder borrarlo luego
        return BookStock.fromMap(data);
      }).toList();
    } catch (e) {
      print("Error en getStockByShop: $e");
      return [];
    }
  }

  Future<bool> deleteStock(String stockId) async {
    try {
      await FirebaseService.firestore.collection('booksStock').doc(stockId).delete();
      return true;
    } catch (e) {
      print("Error al borrar stock: $e");
      return false;
    }
  }

  Future<bool> updateStock(String stockId, Map<String, dynamic> data) async {
    try {
      await FirebaseService.firestore.collection('booksStock').doc(stockId).update(data);
      return true;
    } catch (e) {
      print("Error al actualizar stock: $e");
      return false;
    }
  }

  Future<List<BookStock>> searchStockEfficient(String bookshopId, String query) async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection('booksStock')
          .where('id_bookshop', isEqualTo: bookshopId)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) => BookStock.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error en searchStockEfficient: $e");
      return [];
    }
  }

  Future<BookStock?> getStockByISBN(String bookshopId, String isbn) async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection('booksStock')
          .where('id_bookshop', isEqualTo: bookshopId)
          .where('id_book', isEqualTo: isbn)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return BookStock.fromMap(data);
      }
      return null;
    } catch (e) {
      print("Error en getStockByISBN: $e");
      return null;
    }
  }


  Future<Book?> getBook(String isbn)async{
    print(isbn);
    final docRef = await FirebaseService.firestore
        .collection('books').doc(isbn);
    final docSnap = await docRef.get();
    print(docSnap.data);

    if (docSnap.exists && docSnap.data() != null) {
      print(docSnap.data());
      return Book.fromMap(docSnap.data()!);
    }
    return null;
  }

  Future<void> updateStockQuantity(String stockId, int newQuantity) async {
    await FirebaseService.firestore.collection('booksStock').doc(stockId).update({
      'quantity': newQuantity,
    });
  }


  Future<Map<String, dynamic>?> fetchBookData(String isbn) async {
    // 1. Intentar con Open Library
    final openLibraryData = await _fetchFromOpenLibrary(isbn);
    if (openLibraryData != null) return openLibraryData;

    // 2. Intentar con Google Books si Open Library falla
    final googleBooksData = await _fetchFromGoogleBooks(isbn);
    if (googleBooksData != null) return googleBooksData;

    return null;
  }

  Future<Map<String, dynamic>?> _fetchFromOpenLibrary(String isbn) async {
    try {
      final url = Uri.parse('https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&format=json&jscmd=data');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bookKey = 'ISBN:$isbn';

        if (data.containsKey(bookKey)) {
          final bookInfo = data[bookKey];
          return {
            'title': bookInfo['title'] ?? '',
            'author': (bookInfo['authors'] as List?)?.first['name'] ?? '',
            'editorial': (bookInfo['publishers'] as List?)?.first['name'] ?? '',
            'category': (bookInfo['subjects'] as List?)?.first['name'] ?? '',
            'price': _generateRandomPrice(),
          };
        }
      }
    } catch (e) {
      print('Error en Open Library: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchFromGoogleBooks(String isbn) async {
    try {
      print('Peticiones a google');
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['totalItems'] > 0) {
          final bookInfo = data['items'][0]['volumeInfo'];
          return {
            'title': bookInfo['title'] ?? '',
            'author': (bookInfo['authors'] as List?)?.join(', ') ?? '',
            'editorial': bookInfo['publisher'] ?? '',
            'category': (bookInfo['categories'] as List?)?.first ?? '',
            'price': _generateRandomPrice(),
          };
        }
      }
    } catch (e) {
      print('Error en Google Books: $e');
    }
    return null;
  }

  Future<List<Book>> searchBooksInFirestore(String query) async {
    try {
      // Búsqueda simple por título en Firestore
      final snapshot = await FirebaseService.firestore
          .collection('books')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error searching books in Firestore: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchFromOpenLibraryExtended(
      String isbn,
      String title,
      String author,
      String editorial,
      int limit) async {
    try {
      print('peticiones a openLibrary');
      final query = Adapter.convertInQueryOpenLibrary(isbn, title, author, editorial, limit: limit);
      final url = Uri.parse('https://openlibrary.org/search.json?$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List docs = data['docs'] ?? [];
        
        return docs.where((book) {
          final year = book['first_publish_year'] ?? 0;
          return year >= 2011;
        }).map((book) => {
          'title': book['title'] ?? '',
          'author': (book['author_name'] as List?)?.first ?? '',
          'isbn': (book['isbn'] as List?)?.first ?? '',
          'editorial': (book['publisher'] as List?)?.first ?? '',
          'year': book['first_publish_year'],
        }).toList();
      }
    } catch (e) {
      print('Error en Open Library Extended: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> searchFromGoogleBooksExtended(String isbn,
      String title,
      String author,
      String editorial,
      int limit) async {
    try {
      print('llamada a google');
      final query = Adapter.convertInQueryGoogleBooks(isbn, title, author, editorial,limit: limit);
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['items'] ?? [];
        
        return items.where((item) {
          final info = item['volumeInfo'];
          final dateStr = info['publishedDate'] ?? '';
          if (dateStr.length >= 4) {
            final year = int.tryParse(dateStr.substring(0, 4)) ?? 0;
            return year >= 2011;
          }
          return false;
        }).map((item) {
          final info = item['volumeInfo'];
          return {
            'title': info['title'] ?? '',
            'author': (info['authors'] as List?)?.join(', ') ?? '',
            'isbn': (info['industryIdentifiers'] as List?)?.firstWhere((id) => id['type'] == 'ISBN_13', orElse: () => info['industryIdentifiers']?.first)['identifier'] ?? '',
            'editorial': info['publisher'] ?? '',
            'year': info['publishedDate'],
          };
        }).toList();
      }
    } catch (e) {
      print('Error en Google Books Extended: $e');
    }
    return [];
  }

  double _generateRandomPrice() {
    final random = Random();
    // Genera un número entre 10 y 18
    return double.parse((random.nextDouble() * 13 + 5).toStringAsFixed(2));
  }


}