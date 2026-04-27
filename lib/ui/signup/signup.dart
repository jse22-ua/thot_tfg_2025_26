import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/providers/bookshop_provider.dart';
import 'package:thot_tfg_2025_26/services/auth/auth_service.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../services/bookshop_service.dart';
import '../appbar.dart';
import '../../utils/validators.dart';
import '../home/home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final serviceBS = BookshopService();
      final serviceU = AuthService();
      final newBookshop = context.read<BookshopProvider>().currentBookshop;
      try {
        String id = await serviceBS.addBookShop(newBookshop!);
        if (!mounted) return;
        context.read<BookshopProvider>().setBookshopId(id);

        final newUser = User(
          nombre: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          bookshopId: id,
        );

        String? userId = await serviceU.addUser(newUser);
        String? bookshopId = await serviceBS.addBookShop(newBookshop);

        if(!mounted) return;
        context.read<UserProvider>().setUserId(userId!);
        context.read<UserProvider>().setUser(newUser);
        context.read<BookshopProvider>().setBookshopId(bookshopId);

        if(!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );

      }catch(ex){
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al realiza el registro'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const ThotAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.scaffoldBackgroundColor, colorScheme.surface],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 40.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 15,
                    offset: const Offset(5, 5),
                  ),
                ],
                border: Border.all(color: colorScheme.secondary, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NUEVO ESCRIBA',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(
                        color: colorScheme.secondary,
                        thickness: 2,
                        indent: 50,
                        endIndent: 50,
                      ),
                      const SizedBox(height: 20),
                      Icon(Icons.person_add_rounded,
                          size: 60, color: colorScheme.secondary),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Identifícate'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value == null || !value.contains('@'))
                            ? 'Correo no válido'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) => Validators.validatePassword(
                            _passwordController.text,
                            _confirmPasswordController.text),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Contraseña',
                          prefixIcon: Icon(Icons.enhanced_encryption_outlined),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 45),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero, // Para que no haya padding interno que parta el texto
                                  side: BorderSide(color: colorScheme.primary, width: 2),
                                  shape: const BeveledRectangleBorder(),
                                  foregroundColor: colorScheme.primary,
                                ),
                                child: Text(
                                  'VOLVER',
                                  style: GoogleFonts.cinzel(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13, // Ajustamos un poco el tamaño
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _submitForm();

                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'REGISTRARSE',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Inicio de sesión',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
