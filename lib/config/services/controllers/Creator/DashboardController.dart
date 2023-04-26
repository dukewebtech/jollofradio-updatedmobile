import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class DashboardController {

  static Future<Map?> index() async {
    var request = await api(auth: true).get(endpoint(CREATOR_DASHBOARD_ROUTE));
        request = (request) as Map;

    if (request.containsKey('data')){
      dynamic data = request['data'];

      return data;
      
    }

    return null;
  }

}