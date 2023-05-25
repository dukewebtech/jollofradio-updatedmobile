import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class EpisodeController {

  static Future<Episode?> show(Episode episode) async {
    int podcastId = episode.podcastId;
    int episodeId = episode.id;

    var request = await api(auth: true).get(endpoint(CREATOR_PODCAST_ROUTE
    +'/$podcastId/episode/$episodeId'));
        request = (request) as Map;

    if (request.containsKey('data')){
      dynamic data = request['data'];

      return Episode.fromJson(data);

    }

    return null;
  }

  static Future<Map> create(Map data) async {
    Podcast podcast = data['podcast'] 
    as Podcast;

    var request = await api(auth: true).post(endpoint(CREATOR_PODCAST_ROUTE
    +'/${podcast.id}/episode'),
      data
    );

    return response(request['status'], 
      message: request['message'],
      data: request['data'],
    );
  }
  
  static Future<Map> update(Map data) async {
    Episode episode = data['episode'] 
    as Episode;
    int podcastId = episode.podcastId;
    int episodeId = episode.id;
    data = data['episodes'].first;

    var request = await api(auth: true).put(endpoint(CREATOR_PODCAST_ROUTE
    +'/$podcastId/episode/$episodeId'),
      data
    );

    return response(request['status'], 
      message: request['message'],
      data: request['data'],
    );
  }

  static Future<bool> delete(Episode episode) async {
    int podcastId = episode.podcastId;
    int episodeId = episode.id;

    var request = await api(auth: true).delete(endpoint(CREATOR_PODCAST_ROUTE
    +'/$podcastId/episode/$episodeId'));

    if(request['status'] == 200){

      return true;
    }

    return false;

  }

}