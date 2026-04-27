import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;


class AuthService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Registro con Email y Password
  Future<String?> addUser(User user) async{
    try{
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      if (userCredential.user != null){
        await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toMap());
        return userCredential.user!.uid;
      }
      return null;
    } catch(ex){
      print("Error al crear el usuario: $ex");
      return null;
    }
  }
}
