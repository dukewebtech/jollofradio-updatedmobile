import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class PodcastController {

  static Future<List<Podcast>> index() async {
    var request = await api(auth: true).get(endpoint(CREATOR_PODCAST_ROUTE));
        request = (request) as Map;

    List<Podcast> podcasts = [];

    if (request.containsKey('data')){
      dynamic data = request['data'];

      for(var item in data){
        podcasts.add(Podcast.fromJson(item));
      } 
    }

    return podcasts;
  }

}