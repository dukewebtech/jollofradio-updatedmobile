import 'dart:io' show Platform;
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class HomeController {

  static Future<Map> construct(Map model) async {
    Map streams = {
      'latest': [],
      'trending': [],
      'toppick': [],
      'podcast': [],
      'release': [],
      'playlist': [],
    };

    // if (model.containsKey('data')){
      dynamic data = model;
      for(var episode in data['latest']){

        streams['latest'].add(Episode.fromJson(episode));

      }
      for(var episode in data['trending']){

        streams['trending'].add(Episode.fromJson(episode));

      }
      for(var episode in data['toppick']){

        streams['toppick'].add(Episode.fromJson(episode));

      }
      for(var podcast in data['podcast']){

        streams['podcast'].add(Podcast.fromJson(podcast));

      }
      for(var episode in data['release']){

        streams['release'].add(Episode.fromJson(episode));

      }
      streams['playlist'] = data['playlist']; //:: playlist

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
      'toppick': [],
      'podcast': [],
      'release': [],
      'playlist': [],
    };

    if (request.containsKey('data')){
      dynamic data = request['data'];

      streams = await construct(data);
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

  static Future<bool> analytics(Map data) async {
    String type = data['type'];
    data.remove('type');

    //getting device info
    data['signature'] = {
      "OS": Platform.isAndroid? 'Android': 'iOS',
      "version": Platform.operatingSystemVersion,
      "locale": Platform.localeName,
      "processors": Platform.numberOfProcessors ,
      "Dart VM": Platform.version
    };

    
    var request = await api(/***/).post(endpoint(ANALYTICS_ROUTE+'/$type'), 
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