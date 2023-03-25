
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:flutter/material.dart';

class CreatorProvider extends ChangeNotifier {

  dynamic user;

  Creator login(user){
    this.user = Creator.fromJson(user); //////////////
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