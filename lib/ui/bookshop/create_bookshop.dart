import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/ui/appbar.dart';
import '../../../models/bookshop.dart';
import '../../../providers/bookshop_provider.dart';
import '../signup/signup.dart';

class CreateBookShop extends StatefulWidget {
  const CreateBookShop({super.key});

  @override
  State<CreateBookShop> createState() => _CreateBookShopState();
}

class _CreateBookShopState extends State<CreateBookShop> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      //final service = BookshopService();
      final newBookshop = Bookshop(
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );
      //try {
        //String id = await service.addBookShop(newBookshop);

        if (!mounted) return;

        context.read<BookshopProvider>().setBookshop(newBookshop);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignUpPage(),
          ),
        );
      // } catch (ex) {
      //   if (!mounted) return;
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Error al registrar la librería'),
      //     ),
      //}
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(5, 5),
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
                        'REGISTRA TU LIBRERÍA',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontSize: 20, // Reducido de 24
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
                          endIndent: 50),
                      const SizedBox(height: 20),
                      Icon(Icons.menu_book_rounded,
                          size: 45, color: colorScheme.secondary), // Reducido de 60
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la Librería *',
                          prefixIcon: Icon(Icons.auto_stories),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Nombra tu recinto'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Ubicación *',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? '¿Dónde se halla?'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 45),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('CONTINUAR'),
                        ),
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
                              // Navegación al login
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
