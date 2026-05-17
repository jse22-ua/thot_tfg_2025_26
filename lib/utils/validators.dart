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

  static bool validateISBN(String isbn){
    if(isbn.length!=13){
      return false;
    }
    if(!isbn.startsWith("978")&&!isbn.startsWith("979")){
      return false;
    }
    List<int> numbers = isbn.split('').map(int.parse).toList();

    int count = 0;
    for(var i=0; i<numbers.length; i++){
      if(i%2!=0){
        count = count + numbers[i]*3;
      }else{
        count = count + numbers[i];
      }
    }

    if(count%10 != 0){
      return false;
    }

    return true;
  }

}