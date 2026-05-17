import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thot_tfg_2025_26/services/auth/auth_service.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/appbar.dart';
import '../../home/home.dart';
import '../../bookshop/create_bookshop.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authService = AuthService();
      try {
        final userId = await authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (userId != null) {
          if (!mounted) return;
          final user = await authService.getUser(userId);
          if(user != null){

            context.read<UserProvider>().setUserId(userId);
            context.read<UserProvider>().setUser(user);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage(id: userId)),
            );
          }else{
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Los datos son incorrectos')),
            );
          }
          

        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenciales incorrectas')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al iniciar sesión')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    // setState(() => _isLoading = true);
    // final authService = AuthService();
    // try {
    //   final userId = await authService.loginWithGoogle();
    //   if (userId != null) {
    //     if (!mounted) return;
    //     //final user = await authService.getUser(userId);
    //     //if(user != null){
    //
    //       context.read<UserProvider>().setUserId(userId);
    //       //context.read<UserProvider>().setUser(user);
    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(builder: (context) => const HomePage()),
    //       );
    //     // //}else{
    //     //   ScaffoldMessenger.of(context).showSnackBar(
    //     //     const SnackBar(content: Text('Error al obtener al usuario')),
    //     //   );
    //     // }

      //}
    // } catch (e) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Error con Google Sign-In')),
    //   );
    // } finally {
    //   if (mounted) setState(() => _isLoading = false);
    // }
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
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
                              'INICIAR SESIÓN',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                fontSize: 20,
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
                            Icon(Icons.auto_stories,
                                size: 45, color: colorScheme.secondary),
                            const SizedBox(height: 30),
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
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: colorScheme.secondary,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) => (value == null || value.isEmpty)
                                  ? 'Introduce tu contraseña'
                                  : null,
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        'ENTRAR',
                                        style: GoogleFonts.cinzel(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _loginWithGoogle,
                                icon: const Icon(Icons.login_rounded),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: colorScheme.secondary, width: 1),
                                  shape: const BeveledRectangleBorder(),
                                  foregroundColor: colorScheme.primary,
                                ),
                                label: Text(
                                  'ENTRAR CON GOOGLE',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿No tienes cuenta? ',
                                  style: TextStyle(color: colorScheme.primary),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const CreateBookShop()),
                                    );
                                  },
                                  child: Text(
                                    'Regístrate',
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
            );
          },
        ),
      ),
    );
  }
}
