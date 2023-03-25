import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/AppColor.dart';

class Labels {

  static Widget _label({
    required TextStyle style,
    required String label, //constructing the required parameter
    EdgeInsets? margin,
    int? lines = 1,
    Function()? callback
  }){

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      // width: auto,
      // height: auto,

      child: GestureDetector(
        onTap: callback,
        child: Text(
          label, style: 
          style, maxLines: lines,overflow: TextOverflow.ellipsis,
        ),
      ),
    );
    
  } 

  static Widget primary(
    String label, { 
    double? fontSize, FontWeight? fontWeight, EdgeInsets? margin, 
    int? maxLines,
    Function()? onTap
  }){
    
    TextStyle style = TextStyle(
      color: Colors.white,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight,
    );

    return _label(
      label: label, 
      style: style,margin: margin,lines: maxLines,callback: onTap
    );
  }

  static Widget secondary(
    String label, { 
    double? fontSize, FontWeight? fontWeight, EdgeInsets? margin, 
    int? maxLines,
    Function()? onTap
  }){

    TextStyle style = TextStyle(
      color: AppColor.secondary,
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight,
    );
    
    return _label(
      label: label, 
      style: style,margin: margin,lines: maxLines,callback: onTap
    );
  }
  

}