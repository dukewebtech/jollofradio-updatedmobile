import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';
import 'package:jollofradio/utils/scope.dart';

class NotificationController {

  static Future<Map> index(Map data) async {
    String userType = data['userType'];
    String route = routeScope(
      userType, {
      'user': USER_NOTIFICATION_ROUTE,
      'creator': CREATOR_NOTIFICATION_ROUTE,
    });

    var request = await api(auth: true).get(endpoint(route), data);
        request = (request) as Map;
                   
    if (request.containsKey('data')){
      dynamic data = request['data'];
            
      return data;
    }

    return {};

  }

  static Future<bool> update(Map data) async {
    int id = data['id'];
    String userType = data['userType'];
    String route = routeScope(
      userType, {
      'user': USER_NOTIFICATION_ROUTE,
      'creator': CREATOR_NOTIFICATION_ROUTE,
    });

    var request = await api(auth: true).put(endpoint(route+'/$id'));
        request = (request) as Map;
                   
    if(request['status'] == 200){

      return true;
    }

    return false;

  }


}