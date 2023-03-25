import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class StreamController {

  static Future<Map> construct(Map model) async {
    Map streams = {
      'recent': [],
      'latest': [],
      'trending': [],
      'likes': [],
      'release': [],
    };

    // if (model.containsKey('data')){
      dynamic data = model;
      for(var episode in data['recent']){

        streams['recent'].add(Episode.fromJson(episode));

      }
      for(var episode in data['latest']){

        streams['latest'].add(Episode.fromJson(episode));

      }
      for(var episode in data['trending']){

        streams['trending'].add(Episode.fromJson(episode));

      }
      for(var episode in data['likes']){

        streams['likes'].add(Episode.fromJson(episode));

      }
      for(var episode in data['release']){

        streams['release'].add(Episode.fromJson(episode));

      }
    // }

    return streams;

  }

  static Future<Map> index([Map? query]) async {
    var request = await api(auth: true).get(endpoint(USER_STREAM_ROUTE), 
      query
    );
        request = (request) as Map;

    Map streams = {
      'recent': [],
      'latest': [],
      'trending': [],
      'likes': [],
      'release': [],
    };

    if (request.containsKey('data')){
      dynamic data = request['data'];

      for(var episode in data['recent']){

        streams['recent'].add(Episode.fromJson(episode));

      }
      for(var episode in data['latest']){

        streams['latest'].add(Episode.fromJson(episode));

      }
      for(var episode in data['trending']){

        streams['trending'].add(Episode.fromJson(episode));

      }
      for(var episode in data['likes']){

        streams['likes'].add(Episode.fromJson(episode));

      }
      for(var episode in data['release']){

        streams['release'].add(Episode.fromJson(episode));

      }
    }

    return streams;

  }

  static Future<bool> create(Map data) async {
    var request = await api(auth: true).post(endpoint(USER_STREAM_ROUTE
    +'/like'), 
      data
    );
        request = (request) as Map;

    if (request.containsKey('data')){
      dynamic data = request['data'];

      return true;
    }

    return false;

  }

  static Future<bool> delete(Map data) async {
    var request = await api(auth: true).delete(endpoint(USER_STREAM_ROUTE
      +'/${data['episode_id']}')
    );
        request = (request) as Map;

    if (request.containsKey('data')){
      dynamic data = request['data'];

      return true;
    }

    return false;

  }

}