import 'package:jollofradio/config/models/Station.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class StationController {

  static Future<Map> construct([Map? model]) async {
    Map stations = {
      'local': [],
      'international': [],
    };

    // if (request.containsKey('data')){
      dynamic data = model;

      var local = data['local'].map((e) => 
      Station.fromJson(e)).toList ();

      var international = 
      data['international'].map((e) => 
      Station.fromJson(e)).toList ();

      stations['local'] = local;
      stations['international'] = international;

    // }

    return stations;

  }

  static Future<Map> index([Map? query]) async {
    var request = await api(auth: true).get(endpoint(STATIONS_ROUTE), 
      query
    );
        request = (request) as Map;

    Map stations = {
      'local': [],
      'international': [],
    };

    if (request.containsKey('data')){
      dynamic data = request['data'];

      var local = 
      data.where((station) 
      => station['type'] == 'Local').map((e) => 
      Station.fromJson(e)).toList ();

      var international = 
      data.where((station) 
      => station['type'] != 'Local').map((e) => 
      Station.fromJson(e)).toList ();

      stations['local'] = local;
      stations['international'] = international;

    }

    return stations;

  }


}