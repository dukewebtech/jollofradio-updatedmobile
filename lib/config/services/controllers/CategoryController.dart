import 'package:jollofradio/config/models/Category.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class CategoryController {

  static Future<List<Category>> construct(List model) async {
    List<Category> categories = [];

    for(var category in model){
      categories.add(
        Category.fromJson(category)
      ); 
    }

    return categories;

  }

  static Future<List<Category>> index() async {
    var request = await api(auth: true).get(endpoint(CATEGORY_ROUTE));
        request = (request) as Map;
       
    if (request.containsKey('data')){
      dynamic data = request['data'];

      List<Category> categories = [];

      for(var category in data){
        categories.add(
          Category.fromJson(category)
        );
      }
            
      return categories;
    }

    return [];

  }

  static Future<List<Podcast>> show(Map query) async {
    var category = query['category'];

    var request = await api(auth: true).get(endpoint(INTEREST_ROUTE)
      +'/$category',
      query
    );
        request = (request) as Map;
       
    if (request.containsKey('data')){
      dynamic data = request['data'];

      List<Podcast> podcasts = [];

      for(var podcast in data){
        podcasts.add(
          Podcast.fromJson(podcast)
        );
      }
            
      return podcasts;
    }

    return [];

  }

}