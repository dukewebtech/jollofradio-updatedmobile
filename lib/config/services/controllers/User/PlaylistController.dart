import 'package:jollofradio/config/models/Playlist.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class PlaylistController {

  static bool rules(dynamic data) {

    return false;

  }

  static Future<List<Playlist>> construct(List model) async {
    List<Playlist> playlist = [];

    // if (request.containsKey('data')){
      dynamic data = model;

      for(var item in data){
        playlist.add(Playlist.fromJson(item));
      }
      
    // }

    return playlist;
  }

  static Future<List<Playlist>> index() async {
    var request = await api(auth: true).get(endpoint(USER_PLAYLIST_ROUTE));
        request = (request) as Map;

    List<Playlist> playlist = [];

    if (request.containsKey('data')){
      dynamic data = request['data'];

      for(var item in data){
        playlist.add(Playlist.fromJson(item));
      } 
    }

    return playlist;
  }

  static Future<Podcast?> show(int id) async {
    var request = await api(auth: true).get(endpoint(PODCASTS_ROUTE)+'/$id');
        request = (request) as Map;

    Podcast? playlist;

    if (request.containsKey('data')){
      dynamic data = request['data'];

      playlist = Podcast.fromJson(
        data
      );
    }

    return playlist;
  }


  static Future<bool> create(Map data) async {
    var request = await api(auth: true).post(endpoint(USER_PLAYLIST_ROUTE),
     data
    );
        request = (request) as Map;

    if (request.containsKey('data')){
      dynamic data = request['data'];

      return true;
      
    }

    return false;

  }

  static Future<bool> update(Map data) async {
    var request = await api(auth: true).put(endpoint(USER_PLAYLIST_ROUTE)
    +'/${data['playlist_id']}',
    data
    );
        request = (request) as Map;

    if (request.containsKey('data')){
      dynamic data = request['data'];

      return true;
      
    }

    return false;

  }

  static Future<bool> remove(Map data) async {
    int id = data['playlist_id'];
    int ep = data['episode_id'];

    var request = await api(auth: true).delete(endpoint(USER_PLAYLIST_ROUTE)
      +'/$id/$ep'
    );
        request = (request) as Map;

    if (request['status'] == 200){

      return true;
    }

    return false;

  }

  static Future<bool> delete(int id) async {
    var request = await api(auth: true).delete(endpoint(USER_PLAYLIST_ROUTE)
      +'/$id'
    );
        request = (request) as Map;

    if (request.containsKey('data')){
      dynamic data = request['data'];

      return true;
    }

    return false;

  }

}