import 'package:flutter/material.dart';
import '../../models/bookshop.dart';

class BookshopProvider with ChangeNotifier {
  Bookshop? _currentBookshop;
  String? _bookshopId;

  Bookshop? get currentBookshop => _currentBookshop;
  String? get bookshopId => _bookshopId;
  bool get hasBookshop => _bookshopId != null;

  // Método para establecer la librería tras crearla
  void setBookshop(Bookshop bookshop) {
    _currentBookshop = bookshop;
    notifyListeners();
  }

  void setBookshopId(String id) {
    _bookshopId = id;
    notifyListeners();
  }

  // Método para limpiar (útil al cerrar sesión)
  void clear() {
    _currentBookshop = null;
    _bookshopId = null;
    notifyListeners();
  }
}