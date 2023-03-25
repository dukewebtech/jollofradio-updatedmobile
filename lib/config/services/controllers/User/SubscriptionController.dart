import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';

class SubscriptionController {

  static Future<Map> construct(Map model) async {
    Map subscriptions = {
      'creators': <Creator>[],
      'podcasts': <Podcast>[],
    };

    // if (model.containsKey('data')){
      dynamic data = model;

      for(var creator in data['creators']){

        subscriptions['creators'].add(Creator.fromJson(creator));

      }

      for(var episode in data['podcasts']){

        subscriptions['podcasts'].add(Podcast.fromJson(episode));

      }

    // }

    return subscriptions;

  }

  static Future<Map> index() async {
    var request = await api(auth: true).get(endpoint(USER_SUBSCRIPTION_ROUTE));
        request = (request) as Map;

    Map subscriptions = {
      'status': 400,
      'creators': <Creator>[],
      'podcasts': <Podcast>[],
    };

    if (request.containsKey('data')){
      dynamic data = request['data'];

      //tracking cache control
      subscriptions['status'] = 200;

      for(var creator in data['creators']){

        subscriptions['creators'].add(Creator.fromJson(creator));

      }

      for(var episode in data['podcasts']){

        subscriptions['podcasts'].add(Podcast.fromJson(episode));

      }
    }

    return subscriptions;

  }

  static Future<bool> create(Map data) async {
    var request = await api(auth: true).post(endpoint(USER_SUBSCRIPTION_ROUTE), 
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
    var request = await api(auth: true).delete(endpoint(USER_SUBSCRIPTION_ROUTE),
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