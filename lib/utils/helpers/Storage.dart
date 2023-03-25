import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore_for_file: unnecessary_null_comparison

class Storage {
  static Future<dynamic> get(String key, [Type type = String]) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    dynamic data;

    if(storage.containsKey (key))
    {
      if(type == String){
        data = storage.getString(
          key
        );
      }
      if(type == int   ){
        data = storage.getInt   (
          key
        );
      }
      if(type == bool  ){
        data = storage.getBool  (
          key
        );
      }
      if(type == Map   ){
        data = storage.getString(
          key
        );
        data = json.decode(data);
      }
    }

    return data;

    //////////////////////////////////////////////////////////////////
  }

  static Future<void> set(String key, val) async {
    SharedPreferences storage = await SharedPreferences.getInstance();

    if(storage != null){
      if(val is String){
        storage.setString(
          key, val
        );
      } else 
      if(val is int   ){
        storage.setInt   (
          key, val
        );
      } else
      if(val is bool  ){
        storage.setBool  (
          key, val
        );
      } else 
      if(val is Map   ){
        val = json.encode( val ); // attempt to converts data to json
        
        storage.setString(
          key, val
        );
      } else {
        storage.setString(
          key, val
        );
      }
    }
  }

  static Future<void> delete(String key) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    storage.remove(key);
   
    //////////////////////////////////////////////////////////////////
  }
}