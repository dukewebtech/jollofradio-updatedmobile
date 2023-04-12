import 'package:google_sign_in/google_sign_in.dart';

class GoogleSigninAuth {
  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;

  Future<void> init([List<String>? scopes]) async {
    List<String> defaultScopes = [
      'email',
      'openid',
      'profile',
      // 'https://www.googleapis.com/auth/contacts.readonly',
    ];

    _googleSignIn = GoogleSignIn(
      scopes: scopes ?? defaultScopes,
    );
  }

  Future<GoogleSignInAuthentication?> signIn() async {
    try {

      final login = await _googleSignIn?.signIn(  ); //gsn
      if(login == null){
        throw Exception();
      }

      _currentUser = login;

      final googleAuth = await login.authentication; //jwt
      return googleAuth;
      
    } catch (error) {

      print('Fail to login: $error'); // returns exception

    }

    return null;
  }

  Future<GoogleSignInAccount?> signOut() async {
    if(await _googleSignIn?.
      isSignedIn() ?? false){

      await _googleSignIn?.disconnect(); //signout session

    }

  }

  Future<GoogleSignInAccount?> currentUser() async {

    return _currentUser;

  }

  ////////////////////////////////////////////////////////

}