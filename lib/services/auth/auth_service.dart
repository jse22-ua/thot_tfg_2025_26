import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:thot_tfg_2025_26/services/firebase_service.dart';
import '../../models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // Registro con Email y Password
  Future<String?> addUser(User user, String password) async {
    try {
      UserCredential userCredential = await FirebaseService.auth
          .createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      if (userCredential.user != null) {
        await FirebaseService.firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toMap());
        return userCredential.user!.uid;
      }
      return null;
    } catch (ex) {
      print("Error al crear el usuario: $ex");
      return null;
    }
  }

  Future<User?> getUser(String id) async{
    final docRef = FirebaseService.firestore.collection("users").doc(id);
    final docSnap = await docRef.get();

    if (docSnap.exists && docSnap.data() != null) {
      return User.fromMap(docSnap.data()!);
    }
    return null;
  }

  // Login con Email y Password
  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseService.auth
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential.user!.uid;

    } catch (e) {
      print("Error en login: $e");
      return null;
    }
  }


  // Login/Registro con Google (v7.x API)
  Future<String?> loginWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
          serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID']
      );

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseService.auth.signInWithCredential(credential);

      print(userCredential.user);

      return userCredential.user!.uid;

    } catch (e) {
      print("Error Google Sign-In: $e");
      return null;
    }
  }

  Future<bool?> logout() async{
    try {
      await FirebaseService.auth.signOut();
      await GoogleSignIn.instance.signOut();
      return true;
    }catch(ex){
      return false;
    }

  }
}
