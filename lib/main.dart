import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thot_tfg_2025_26/firebase_options.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/providers/user_provider.dart';
import 'package:thot_tfg_2025_26/ui/bookshop/create_bookshop.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookshopProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definición de colores de la temática Thot
    const Color lapisLazuli = Color(0xFF1A3A5F);
    const Color ancientGold = Color(0xFFC5A021);
    const Color papyrus = Color(0xFFFDF5E6);
    const Color desertSand = Color(0xFFE2C98F);

    return MaterialApp(
      title: 'Thot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Color de fondo de las pantallas
        scaffoldBackgroundColor: desertSand,
        
        // Colores principales
        colorScheme: ColorScheme.fromSeed(
          seedColor: lapisLazuli,
          primary: lapisLazuli,
          secondary: ancientGold,
          surface: papyrus,
        ),

        // Configuración global de AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: lapisLazuli,
          foregroundColor: papyrus,
          elevation: 0,
          titleTextStyle: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ancientGold,
          ),
        ),

        // Configuración de los campos de texto (TextFields)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: GoogleFonts.spectral(
            color: lapisLazuli,
            fontWeight: FontWeight.bold,
          ),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: ancientGold, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ancientGold, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: lapisLazuli, width: 2.5),
          ),

          errorStyle: GoogleFonts.spectral(
              color: Colors.red[900],
              fontWeight: FontWeight.bold,
              fontSize: 13,
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red,
              width: 2.5,
            ),
            ),
          ),

        // Configuración de botones elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lapisLazuli,
            foregroundColor: papyrus,
            elevation: 5,
            shape: const BeveledRectangleBorder(), // Bordes angulares tipo piedra
            textStyle: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Fuente por defecto para el resto de la app
        textTheme: GoogleFonts.spectralTextTheme().apply(
          bodyColor: lapisLazuli,
          displayColor: lapisLazuli,
        ),
      ),
      home: const CreateBookShop(),
    );
  }
}
