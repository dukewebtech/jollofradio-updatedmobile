
import 'dart:convert';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {

  dynamic user;

  UserProvider() {
    (() async {
      final user = await Storage.get('user', String);

      if(user != null){
        // login(
        //   json.decode(user)
        // );
      }
    }());
  }

  User login(user){
    this.user = User.fromJson(user); /////////////////
    Storage.set(
      'user', user
    );
    
    notifyListeners();

    return this.user ;
  }

  void logout(){
    //AuthController.logout();  //logout user from app
    user = null;

    notifyListeners();
  }
}