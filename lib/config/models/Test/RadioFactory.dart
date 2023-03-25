import 'package:flutter/material.dart';

class RadioFactory {

  final List data = [
    {
      "id": 1,
      "title": "NPR News Culture",
      "image": "assets/uploads/stations/1.png",
      "frequency": "98.7 FM",
      "state": "Benin",
      "country": "Nigeria",
    },
    {
      "id": 2,
      "title": "Lagos FM",
      "image": "assets/uploads/stations/2.png",
      "frequency": "102.9 FM",
      "state": "Lagos",
      "country": "Nigeria",
    },
    {
      "id": 3,
      "title": "Soundcity Radio",
      "image": "assets/uploads/stations/3.png",
      "frequency": "80.1 FM",
      "state": "Abuja",
      "country": "Nigeria",
    },
    {
      "id": 4,
      "title": "World News FM",
      "image": "assets/uploads/stations/4.png",
      "frequency": "199.9 FM",
      "state": "London",
      "country": "United Kingdom",
    },
    {
      "id": 5,
      "title": "Aljazeera",
      "image": "assets/uploads/stations/5.png",
      "frequency": "96.9 FM",
      "state": "Instanbul",
      "country": "Turkey",
    },
    {
      "id": 6,
      "title": "BBC World News",
      "image": "assets/uploads/stations/6.png",
      "frequency": "102.5 FM",
      "state": "New York",
      "country": "USA",
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