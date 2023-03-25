import 'package:flutter/material.dart';

class CategoryFactory {

  final List data = [
    {
      "id": 1,
      "title": "Music",
      "image": "assets/uploads/category/1.png",
      "link": null,
      "color": Color(0XFF441D39)
    },
    {
      "id": 2,
      "title": "Comedy",
      "image": "assets/uploads/category/2.png",
      "link": null,
      "color": Color(0XFF582ABB)
    },
    {
      "id": 3,
      "title": "Entertainment",
      "image": "assets/uploads/category/3.png",
      "link": null,
      "color": Color(0XFFF0CF7B)
    },
    {
      "id": 4,
      "title": "Fashion",
      "image": "assets/uploads/category/4.png",
      "link": null,
      "color": Color(0XFFB5DA21)
    },
    {
      "id": 5,
      "title": "Business",
      "image": "assets/uploads/category/5.png",
      "link": null,
      "color": Color(0XFFE8503C)
    },
    {
      "id": 6,
      "title": "Tech",
      "image": "assets/uploads/category/6.png",
      "link": null,
      "color": Color(0XFF7B95F0)
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