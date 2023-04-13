import 'package:flutter/material.dart';

class SettingFactory {

  final List data = [
    {
      "title": "Explicit content",
      "options": [
        {
          "name": "explicit_content",
          "description": "Give explicit content a chance to playback audio",
          "active": false
        },
      ]
    },
    {
      "title": "Autoplay",
      "options": [
        {
          "name": "autoplay",
          "description": "Autoplay / resume podcasts based on my activity",
          "active": false
        },
      ]
    },
    {
      "title": "Notification",
      "options": [
        {
          "name": "new_release",
          "description": "Show a new release announcement once i open app",
          "active": false
        },
        {
          "name": "product_offer",
          "description": "Send push notifications regarding product offer",
          "active": false
        },
      ]
    },
    {
      "title": "Security",
      "options": [
        {
          "name": "biometric_login",
          "description": "Enable biometrics login when i opened the app",
          "active": false
        },
        // {
        //   "description": "Lock my account usage to just this device alone",
        //   "active": false
        // },
      ]
    },
    {
      "title": "Audio Quality",
      "options": [
        {
          "name": "optimize_stream",
          "description": "Optimize streaming quality for faster buffering",
          "active": false
        },
        {
          "name": "lower_latency",
          "description": "Switch to lower audio quality for lower latency",
          "active": false
        },
      ]
    },
  ];

  List get(int start, [int? limit]) {

    if(limit != null){
      limit = limit + start;
      if(data.length >= limit){

         return data.sublist(start, limit).toList();

      }    
    }

    return data.sublist(start);
    
  }

}