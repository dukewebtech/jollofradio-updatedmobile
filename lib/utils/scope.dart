import 'package:jollofradio/utils/helpers/Storage.dart';

///

String routeScope(String scope, Map routes){

  return routes[scope];

}

Future<bool> isCreator() async {
  //read user object
  final user = await Storage.get('user', Map);
  if(user == null)
    return false;

  //check for entity
  return (user['podcasts'] != null) == (true);

}