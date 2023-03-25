import 'package:flutter/material.dart';

class PlaylistFactory {

  final List data = [
    {
      "id": 1,
      "title": "WTF",
      "podcasts": "23 Episodes",
      "image": "assets/uploads/podcasts/1.png",
      "duration": null,
    },
    {
      "id": 2,
      "title": "This City",
      "podcasts": "10 Episodes",
      "image": "assets/uploads/podcasts/2.png",
      "duration": null,
    },
    {
      "id": 3,
      "title": "The Dave Ramsey Show",
      "podcasts": "16 Episodes",
      "image": "assets/uploads/podcasts/3.png",
      "duration": null,
    },
    {
      "id": 4,
      "title": "Adulting",
      "podcasts": "22 Episodes",
      "image": "assets/uploads/podcasts/4.png",
      "duration": null,
    },
    {
      "id": 5,
      "title": "Needs a Friend",
      "podcasts": "23 Episodes",
      "image": "assets/uploads/podcasts/5.png",
      "duration": null,
    },
    {
      "id": 6,
      "title": "All Fantasy Everything",
      "podcasts": "10 Episodes",
      "image": "assets/uploads/podcasts/6.png",
      "duration": null,
    },
    {
      "id": 7,
      "title": "The Jollofradio podcast",
      "podcasts": "20 Episodes",
      "image": "assets/uploads/podcasts/7.png",
      "duration": null,
    },
    {
      "id": 8,
      "title": "WTF",
      "podcasts": "33 Episodes",
      "image": "assets/uploads/podcasts/1.png",
      "duration": null,
    },
    {
      "id": 9,
      "title": "This City",
      "podcasts": "31 Episodes",
      "image": "assets/uploads/podcasts/2.png",
      "duration": null,
    },
    {
      "id": 10,
      "title": "The Dave Ramsey Show",
      "podcasts": "40 Episodes",
      "image": "assets/uploads/podcasts/3.png",
      "duration": null,
    },
    {
      "id": 11,
      "title": "WTF",
      "podcasts": "90 Episodes",
      "image": "assets/uploads/podcasts/4.png",
      "duration": null,
    },
    {
      "id": 12,
      "title": "WTF",
      "podcasts": "60 Episodes",
      "image": "assets/uploads/podcasts/5.png",
      "duration": null,
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