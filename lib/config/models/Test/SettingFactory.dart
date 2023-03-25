import 'package:flutter/material.dart';

class SettingFactory {

  final List data = [
    {
      "title": "Explicit content",
      "options": [
        {
          "description": "Give explicit content a chance to playback audio",
          "active": false
        },
      ]
    },
    {
      "title": "Autoplay",
      "options": [
        {
          "description": "Autoplay similar podcasts based on my playlist",
          "active": false
        },
      ]
    },
    {
      "title": "Notification",
      "options": [
        {
          "description": "Show a new release announcement once i open app",
          "active": false
        },
        {
          "description": "Send push notifications regarding product offer",
          "active": false
        },
      ]
    },
    {
      "title": "Security",
      "options": [
        {
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
          "description": "Optimize streaming quality for faster buffering",
          "active": false
        },
        {
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