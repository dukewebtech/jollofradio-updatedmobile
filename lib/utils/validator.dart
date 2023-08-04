  //function that validate user entered password

  Map checkPassword(String pass){
    RegExp valid = RegExp(
      r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)"
    );
    double password_strength = 0;
    bool passes = false;

    Map result = <String, dynamic>{
      'strength': 0,
      'validated': false
    };
    String password = pass.trim( );

    if(password.isEmpty){
      password_strength = 0;

    }
    else
    if(password.length < 6 ){
      password_strength = 1 / 4; //////////////

    }
    else
    if(password.length < 8){
      password_strength = 2 / 4; //////////////
      
    }
    else{
      if(!valid.hasMatch(password)){
        password_strength = 3 / 4;
      }
      else{
        password_strength = 4 / 4;
        passes = true;
      }
    }

    result['strength'] = ( password_strength );
    result['validated'] = passes;

    return result;
  }