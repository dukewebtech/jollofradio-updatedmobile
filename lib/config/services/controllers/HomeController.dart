import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class HomeController {

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
      for(var episode in data['latest']){

        streams['latest'].add(Episode.fromJson(episode));

      }
      for(var episode in data['trending']){

        streams['trending'].add(Episode.fromJson(episode));

      }
      for(var podcast in data['release']){

        streams['release'].add(Podcast.fromJson(podcast));

      }
    // }

    return streams;

  }

  static Future<Map> index([Map? query]) async {
    var request = await api(auth: true).get(endpoint(PUBLIC_STREAM_ROUTE), 
      query
    );
        request = (request) as Map;

    Map streams = {
      'latest': [],
      'trending': [],
      'release': [],
    };

    if (request.containsKey('data')){
      dynamic data = request['data'];

      for(var episode in data['latest']){

        streams['latest'].add(Episode.fromJson(episode));

      }
      for(var episode in data['trending']){

        streams['trending'].add(Episode.fromJson(episode));

      }
      for(var podcast in data['release']){

        streams['release'].add(Podcast.fromJson(podcast));

      }
    }
    return streams;
  }

  static Future<bool> stream(Map data) async {
    var request = await api(/** ** */).post(endpoint(PUBLIC_STREAM_ROUTE), 
      data
    );
        request = (request) as Map;

    if (request.containsKey('data')){
      dynamic data = request['data'];

      return true;
    }

    return false;
  }


}