import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  String? _userId;


  User? get currentUser => _currentUser;
  String? get userId => _userId;
  bool get logged => _userId != null;

  // Método para establecer la librería tras crearla
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }

  void clear(){
    _currentUser = null;
    _userId = null;
    notifyListeners();
  }
}