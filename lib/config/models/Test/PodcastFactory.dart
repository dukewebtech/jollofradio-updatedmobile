import 'package:flutter/material.dart';

class PodcastFactory {

  final List data = [
    {
      "id": 1,
      "title": "WTF",
      "creator": "Marc Maron",
      "image": "assets/uploads/podcasts/1.png",
      "duration": "05:30",
      "fav": false,
    },
    {
      "id": 2,
      "title": "This City",
      "creator": "Clara Amfo",
      "image": "assets/uploads/podcasts/2.png",
      "duration": "10:00",
      "fav": false,
    },
    {
      "id": 3,
      "title": "The Dave Ramsey Show",
      "creator": "Dave Ramsey",
      "image": "assets/uploads/podcasts/3.png",
      "duration": "20:00",
      "fav": false,
    },
    {
      "id": 4,
      "title": "Adulting",
      "creator": "Wynsc Studios",
      "image": "assets/uploads/podcasts/4.png",
      "duration": "01:50",
      "fav": false,
    },
    {
      "id": 5,
      "title": "Needs a Friend",
      "creator": "Earwolf",
      "image": "assets/uploads/podcasts/5.png",
      "duration": "10:00",
      "fav": false,
    },
    {
      "id": 6,
      "title": "All Fantasy Everything",
      "creator": "Clara Amfo",
      "image": "assets/uploads/podcasts/6.png",
      "duration": "18:00",
      "fav": false,
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