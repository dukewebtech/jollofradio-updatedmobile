import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class Countries {

  static Future<dynamic> get([String? country]) async {

    var jsonFile = 'assets/uploads/countries.json';

    String data =  await rootBundle.loadString(jsonFile);
    dynamic countries = jsonDecode(data);

    if(country != null){

      countries = countries.firstWhere((element){

        return element['name'] == country 
        || element['code'] == country; //check for match 

      }, orElse: () => null);

    }

    return countries;
    
  }
  
  
}