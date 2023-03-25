import 'package:jollofradio/config/routes/screens.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

class RouteGenerator {
  static Route<dynamic> init(RouteSettings settings){
    final args = (
      settings.arguments??<String,dynamic>{}) as Map;
    return ScreenProvider.route( //log requested route to route factory
      settings.name, args
    );
  }

   static goto(String route, [Map ?parameters]){
    var args = parameters ?? {};
    /*
    return Navigator.of( context ).pushNamed( // initial routing style
      route, 
      arguments: args
    );
    */
    return navigator.currentState?.
    pushNamed( // global states routing
      route, 
      arguments: args
    );
  }

  static exit(String route, [Map ?parameters]){
    var args = parameters ?? {};
    /*
    return Navigator.of( context ).pushNamed( // initial routing style
      route, 
      arguments: args
    );
    */
    return navigator.currentState?.
    popAndPushNamed(
      route, 
      arguments: args
    );
  }

  static goBack([int history = 1]){
    for(int i=0; i < history; i++){
      /**/ navigator.currentState?.pop(true); // redirects to previous
    }
  }
}