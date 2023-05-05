import 'package:jollofradio/config/models/Category.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class SearchController {

  static Future<Map> search(query) async {
    var request = await api(auth: true).get(endpoint(SEARCH_ROUTE), {
      'query': query
    });
        request = (request) as Map;
       
    Map results = {
      'playlist': <Podcast>[],
      'podcasts': <Episode>[],
      'creators': <Creator>[],
      'category': <Category>[],
    };

    if (request.containsKey('data')){
      dynamic data = request['data'];

      List podcasts = data['podcasts'];
      List episodes = data['episodes'];
      List creators = data['creators'];
      List category = data['category'];

      for(var podcast in podcasts){
        
        results['playlist'].add(Podcast.fromJson(podcast));
        
      }

      for(var episode in episodes){
        
        results['podcasts'].add(Episode.fromJson(episode));
        
      }

      for(var creator in creators){
        
        results['creators'].add(Creator.fromJson(creator));
         
      }

      for(var catItem in category){
        
        results['category'].add(Category.fromJson(catItem));
         
      }
    }

    return results;

  }

}