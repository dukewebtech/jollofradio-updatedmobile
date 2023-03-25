import 'dart:convert';
import 'package:jollofradio/utils/helpers/Storage.dart';

///

String routeScope(String scope, Map routes){

  return routes[scope];

}

Future<bool> isCreator() async {
  
  //read user ohect
  final user = json.decode(await Storage.get('user'));

  //test for entity
  return user['podcasts'] != null;

}