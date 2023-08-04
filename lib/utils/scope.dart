import 'package:jollofradio/utils/helpers/Storage.dart';

///

String routeScope(String scope, Map routes){

  return routes[scope];

}

Future<dynamic> auth() async {
  
  //read user object
  final user = await Storage.get('user', Map);
  if(user == null)
    return null;

  return user;

}

Future<bool> isCreator() async {
  final prof = await auth(); //get logged user
  if(prof == null)
    return false;

  //check for entity
  return (prof['podcasts'] != null) == (true);

}