import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Map login(Map response) {
  return {
    'token': response['data']['access_token'],
    'user': response['data']['data'],
  };

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