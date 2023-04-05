import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class CreatorController {

  static Future<Creator?> show(Map data) async {
    int id = data['id'];

    var request = await api(auth: false).get(endpoint(CREATOR_ROUTE)
      +'/$id'
    );
        request = (request) as Map;
        
       
    if (request.containsKey('data')){
      dynamic data = request['data'];

      Creator creator = Creator.fromJson(
        data
      );
            
      return creator;
    }

    return null;

  }

}