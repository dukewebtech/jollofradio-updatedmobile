import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jollofradio/config/strings/Message.dart';

Map login(Map response) {
  return {
    'token': response['data']['access_token'],
    'user': response['data']['data'],
  };

}

String shareLink({required type, required data}){
  String text = '-';
  List platforms = [
    'podcast',
    'episode',
    'station'
  ];

  if(platforms.contains(type) == (false)){ // err
    return '';
  }

  if(type == 'podcast'){
    text = Message.build(Message.share_podcast, {
      "title": data.title,
      "podcast": data.slug,
    });
  }

  if(type == 'episode'){
    text = Message.build(Message.share_episode, {
      "title": data.title,
      "podcast": data.podcastId,
      "episode": data.slug,
    });
  }

  if(type == 'station'){
    text = Message.build(Message.share_station, {
      "title": data.title,
      "station": data.slug,
    });
  }

  return text;

}

String numberFormat(num amount){

  return NumberFormat.compact().format( amount );
  
}

String formatTime(Duration time){

  return time
  .toString().split('.').first.padLeft( 8, "0") ;

}

bool textOverflow(String text, TextStyle style, { 
  double minWidth = 0, 
  double maxWidth = double.infinity, 
  int maxLines = 2
}) {
  
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: ui.TextDirection.ltr,
  )
  ..layout(minWidth:minWidth, maxWidth:maxWidth);
  
  return textPainter.didExceedMaxLines; //overflow

}