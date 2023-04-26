import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class AdvertController {

  static Future<dynamic> enroll(Map data) async {
    var request = await api(auth: true).post(endpoint(CREATOR_ADVERT_ROUTE
      +'/enroll')
    ).then((data){

      return response(data['status'], 
        message: data['message'],
        data: data['data'], ///////////////////////////////
      );

    });

    return request;
  }

}