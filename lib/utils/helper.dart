import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Map login(Map response) {
  return {
    'token': response['data']['access_token'],
    'user': response['data']['data'],
  };

}

String shareLink({required type, required data}){
  List platforms = [
    'podcast',
    'station'
  ];

  if(platforms.contains(type) == (false)){ // err
    return '';
  }

  if(type == 'podcast'){

    return 'Listen to: ${data.title} on Jollof Radio at https://app.jollofradio.com/podcast/${data.podcastId}?episode=${data.slug}';

  }

  if(type == 'station'){
    
    return 'Listen to: ${data.title} on Jollof Radio at https://app.jollofradio.com/home?station=${data.slug}';

  }

  return '';

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