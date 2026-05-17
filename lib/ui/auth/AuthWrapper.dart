import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:thot_tfg_2025_26/services/firebase_service.dart';
import '../home/home.dart';
import 'login/login.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el stream de Firebase directamente
    return StreamBuilder<fb.User?>(
      stream: FirebaseService.auth.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Si está cargando, muestra un spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. Si hay datos, vamos a Inicio pasando el ID
        if (snapshot.hasData && snapshot.data != null) {

          return HomePage(id: snapshot.data!.uid);
        }

        // 3. Si no hay usuario, vamos a Login
        return const LoginPage();
      },
    );
  }
}
