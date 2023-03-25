import 'package:flutter/material.dart';

class CreatorFactory {

  final List data = [
    {
      "id": 1,
      "name": "Michael Eric",
      "image": "assets/uploads/creators/1.png",
      "podcast": "Business Mindset",
    },
    {
      "id": 2,
      "name": "Isaac Ryan",
      "image": "assets/uploads/creators/2.png",
      "podcast": "Crazily Rich",
    },
    {
      "id": 3,
      "name": "Mahisma Raj",
      "image": "assets/uploads/creators/3.png",
      "podcast": "Talk India",
    },
    {
      "id": 4,
      "name": "Buston Wright",
      "image": "assets/uploads/creators/1.png",
      "podcast": "Secret Affairs",
    },
    {
      "id": 5,
      "name": "Journal Space",
      "image": "assets/uploads/creators/2.png",
      "podcast": "It's all you!",
    },
    {
      "id": 6,
      "name": "Rich Problem",
      "image": "assets/uploads/creators/3.png",
      "podcast": "Money & Rich",
    }
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