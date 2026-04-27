class Validators {
  static String? validatePassword(String? pass, String confirmPass) {
    if (pass == null || pass.isEmpty) {
      return 'Por favor, ingrese una contraseña';
    }
    if (pass.length < 6) {
      return 'Debe tener al menos 6 caracteres';
    }
    if (pass != confirmPass) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

}