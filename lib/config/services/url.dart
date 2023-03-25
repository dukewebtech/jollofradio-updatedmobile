import 'dart:convert';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class api {
  late bool auth;
  api({
    this.auth = false
  });

  Future<dynamic> get(String endpoint, [Map? data]) async {
    dynamic token;
    if(auth){
      token = await Storage.get('token', String);
    }

    endpoint = generateURL(endpoint,data as Map);

    var client = http.Client();
    var url = Uri.parse(endpoint);

    try {
      var response = await client.get(url,  //send request
        headers: {
          "Content-Type": "application/json",
          "Authorization": auth ? 'Bearer $token' : 'XXX',
        }
      );
      if(response.body.isNotEmpty){
        var data = json.decode(response.body);
        data['status'] = response.statusCode;
        
        print(data);
        print('--');


        return data;
        // return json.decode(response.body); ////////////
      }
    } catch(e) {
      return json.decode('{}');
    }
  }

  Future<dynamic> post(String endpoint, [Map? data]) async {
    dynamic token;
    if(auth){
      token = await Storage.get('token', String);
    }

    var client = http.Client();
    var url = Uri.parse(endpoint);

    try {
      var response = await client.post(url, //send request
        body: json.encode(data ?? '{}'), 
        headers: {
          "Content-Type": "application/json",
          "Authorization": auth ? 'Bearer $token' : 'XXX',
        }
      );
      if(response.body.isNotEmpty){
        var data = json.decode(response.body);
        data['status'] = response.statusCode;

        print(data);
        print('--');


        return data;
        // return json.decode(response.body); ////////////
      }
    } catch(e){
      return json.decode('{}');
    }
  } 
}

 String generateURL(String url, Map? params){
  if(params != null && params.isNotEmpty){
    url = '$url?';
    
    params.entries.map((m){
      url += '&${m.key}=${m.value}'; //concatenate strings
    }).toList();
  }

  return url;
 }