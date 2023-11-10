import 'dart:convert';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/api.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Endpoints.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/utils/scope.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jollofradio/utils/validator.dart';

class AuthController {

  static Future<Map<String, dynamic>> signin(Map data) async {
    String userType = data['userType'];
    String route = routeScope(
      userType, {
      '': '',
      'user': USER_SIGNIN_ROUTE,
      'creator': CREATOR_SIGNIN_ROUTE,
    });

    String email = data['email'];
    String password = data['password'];

    if(email.isEmpty){
      return response(400, 
        message: "You need to enter your email address or ID",
      );
    }
    else
    if(password.isEmpty){
      return response(400, 
        message: "You need to enter your password",
      );
    }
    else
    if(userType.isEmpty){
      return response(400, 
        message: "You have not selected a user account type",
      );
    }
    else{
      var request = await api().post(endpoint(route), data);
      return response(request['status'], 
        message: request['message'],
        data: request
      );
    }
  }

  static Future<Map<String, dynamic>> social(Map data) async {
    String oauth = data['oauth'];
    String token = data['token'];

    var request = await api().post(endpoint(SOCIAL_LOGIN_ROUTE
      +'/$oauth/$token'
    ), data);

    return response(request['status'], 
      message: request['message'],
      data: request
    );
  }

  static Future<Map<String, dynamic>> signup(Map data) async {
    String userType = data['userType'];
    String route = routeScope(
      userType, {
      'user': USER_SIGNUP_ROUTE,
      'creator': CREATOR_SIGNUP_ROUTE,
    });

    /*
    List fullname = (data['fullname'] as String).split  (' ');
    if(fullname.length < 2){
      return response(400, 
        message: "You need to enter your fullname to signup.",
        data: {},
      );
    }
    
    */
    
    String firstname = data['firstname'];
    String lastname = data['lastname'];
    String email = data['email'];
    String telephone = data['telephone'];
    String country = data['country'];
    String state = data['state'];
    String city = data['city'];
    String age = data['age'];
    String password = data['password'];
    String confirmPassword = data['confirmPassword'];

    bool passValidated = checkPassword(
      password
    )[
      'validated'
    ];


    // data['firstname'] = firstname;
    // data['lastname'] = lastname;


    if(firstname == ""){
      return response(400, 
        message: "You need to enter your firstname",
      );
    }
    else
    if(lastname == ""){
      return response(400, 
        message: "You need to enter your lastname",
      );
    }
    else
    if(email == ""){
      return response(400, 
        message: "You need to enter a unique Email address.",
      );
    }
    else
    if(telephone == ""){
      return response(400, 
        message: "You need to enter your telephone",
      );
    }
    else
    if(country == ""){
      return response(400, 
        message: "You need to select your country",
      );
    }
    else
    if(state == ""){
      return response(400, 
        message: "You need to enter your state / region",
      );
    }
    else
    if(city == ""){
      return response(400, 
        message: "You need to enter your city",
      );
    }
    else
    if(age == ""){
      return response(400, 
        message: "You need to tell us how old you are 😉",
      );
    }
    else
    if(password == ""){
      return response(400, 
        message: "You need to enter your password",
      );
    }
    else
    if(confirmPassword == ""){
      return response(400, 
        message: "You need to confirm your account password",
      );
    }
    else
    if(!passValidated){
      return response(400, 
        message: Message.password_invalid,
      );
    }
    else{
      var request = await api().post(endpoint(route), data)
      .then((data){
        return response(data['status'], 
          message: data['message'],
          data: data['data'], ///////////////////////////////
        );
      });

      return request;
    }
  }

  static Future<Map<String, dynamic>> update(Map data) async {
    String userType = data['userType'];
    String route = routeScope(
      userType, {
      'user': USER_PROFILE_ROUTE,
      'creator': CREATOR_PROFILE_ROUTE,
    });

    var request = await api(auth: true).post(endpoint(route), 
      data
    ).then(
      (data){

      return response(data['status'], 
        message: data['message'],
        data: data['data'], ///////////////////////////////
      );
    });

    return request;
  }

  static Future<Map<String, dynamic>> upload(Map data) async {
    String userType = data['userType'];
    String route = routeScope(
      userType, {
      'user': USER_PROFILE_ROUTE,
      'creator': CREATOR_PROFILE_ROUTE,
    });
    String file = data['file'];
    dynamic photo = data['data'];
    dynamic body;
    dynamic result;

    if(photo == null){
      return response(400, 
        message: "You need to select photo to update profile",
      );
    }
    else{
      var request = http.MultipartRequest ('POST', Uri.parse(
        endpoint(route)
      ));
      //setup authorization headers
      var headers = {
        "Content-Type": "application/json",
        "Authorization":'Bearer '+await Storage.get('token'),
      };
      request.headers.addAll(headers);

      //add all file to be uploaded
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo', 
          photo, 
          filename: file, 
          contentType: MediaType('*', '*')
        )
      );

      //sending request and get ping
      var dispatch = await http.Response.fromStream  (  ///
        await request.send()
      );
      result = /***/ json.decode(body = dispatch.body); ///

      return response(result['status'], 
        message: result['message'],
        data: result['data'], ///////////////////////////////
      );
    }
  }

  static Future close(Map data) async {
    String userType = data['userType'];
    String route = routeScope(
      userType, {
      'user': USER_TERMINATE_ROUTE,
      'creator': CREATOR_TERMINATE_ROUTE,
    });

    var request = await api(auth: true).delete(endpoint(route), 
      data
    ).then(
      (data){

      return response(data['status'], 
        message: data['message'],
        data: data['data'], ///////////////////////////////
      );
    });

    return request;
  }

  static Future onboard(Map data) async {
    String token = data['token'];

    var request = await api().post(endpoint(USER_ONBOARD_ROUTE+ '/' +token), 
      data
    );
        request = (request) as Map;
       
    if (request.containsKey('data')){
      dynamic data = request['data'];
            
      return data;
    }

    return;
  }

  static Future activate(Map data) async {
    var request = await api().post(endpoint(VERIFY_ROUTE), 
      data
    ).then(
      (data){

      return response(data['status'], 
        message: data['message'],
        data: data['data'], ///////////////////////////////
      );
    });

    return request;
  }

  static Future service(Map data) async {
    String userType = data['userType'];
    String route = routeScope(
      userType, {
      'user': USER_SERVICE_ROUTE,
      'creator': CREATOR_SERVICE_ROUTE,
    });

    var request = await api(auth: true).get(endpoint(route));
        request = (request) as Map;
       
    if (request.containsKey('data')){
      dynamic data = request['data'];
            
      return data;
    }

    return {};
  }

  static Future forgot(Map data) async {
    var request = await api().post(endpoint(FORGOT_ROUTE), 
      data
    ).then(
      (data){

      return response(data['status'],
        message: data['message'],
        data: data['data'], ///////////////////////////////
      );
    });

    return request;
  }

  static Future verify(Map data) async {
    var request = await api().post(endpoint(FORGOT_ROUTE+ '/verify'), 
      data
    ).then(
      (data){

      return response(data['status'], 
        message: data['message'],
        data: data['data'], ///////////////////////////////
      );
    });

    return request;
  }

  static Future reset(Map data) async {
    var request = await api().post(endpoint(FORGOT_ROUTE+ '/complete'), 
      data
    ).then(
      (data){

      return response(data['status'], 
        message: data['message'],
        data: data['data'], ///////////////////////////////
      );
    });

    return request;
  }

  static Future<void> logout() async {
    // RouteGenerator.exit(SIGNIN);

    /** - **/ await api(auth: true).get(endpoint(USER_LOGOUT_ROUTE))
    .then((_) {
      Storage.delete('user');
      Storage.delete('token');

      print('Session Logout!');
    });
  }

}