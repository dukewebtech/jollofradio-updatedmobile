import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class PodcastController {

  static Future<Map> construct(Map model) async {
    Map podcasts = {
      'podcasts': [],
      'pending': [],
      'topChart': [],
    };

    // if (request.containsKey('data')){
      for(var item in model['podcasts']){
        podcasts['podcasts'].add(Podcast.fromJson(item));
      }

      for(var item in model['pending']){
        podcasts['pending'].add(Podcast.fromJson(item));
      }

      for(var item in model['topChart']){
        podcasts['topChart'].add(Podcast.fromJson(item));
      }      
    // }

    return podcasts;
  }

  static Future<Map> index() async {
    var request = await api(auth: true).get(endpoint(CREATOR_PODCAST_ROUTE));
        request = (request) as Map;

    Map podcasts = {
      'podcasts': [],
      'pending': [],
      'topChart': [],
    };

    if (request.containsKey('data')){
      dynamic data = request['data'];

      for(var item in data['podcasts']){
        podcasts['podcasts'].add(Podcast.fromJson(item));
      }

      for(var item in data['pending']){
        podcasts['pending'].add(Podcast.fromJson(item));
      }

      for(var item in data['topChart']){
        podcasts['topChart'].add(Podcast.fromJson(item));
      }
    }

    return podcasts;
  }

  static Future<Map> import(Map data) async {
    var request = await api(auth: true).post(endpoint(CREATOR_PODCAST_ROUTE
    +'/import'), 
      data
    );

    return response(request['status'], 
      message: request['message'],
      data: request['data'],
    );
  }

  static Future<Map> upload(Map data) async {
    var request = await api(auth: true).post(endpoint(CREATOR_PODCAST_ROUTE), 
      data
    );

    return response(request['status'], 
      message: request['message'],
      data: request['data'],
    );
    
  }

  static Future<Map> update(Map data) async {
    var request = await api(auth: true).put(endpoint(CREATOR_PODCAST_ROUTE
    +'/${data["id"]}'), 
      data
    );

    return response(request['status'], 
      message: request['message'],
      data: request['data'],
    );

  }

  static Future<bool> delete(int id) async {
    var request = await api(auth: true).delete(endpoint(CREATOR_PODCAST_ROUTE
    +'/$id'));

    if(request['status'] == 200){

      return true;
    }

    return false;

  }

}