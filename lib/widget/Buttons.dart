import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/AppColor.dart';

class Buttons {
  static double width = double.infinity;
  static double height = 50.0;

  static Widget back(){
    return IconButton(
      onPressed: () => RouteGenerator.goBack(), // previous page
      icon: Icon(
        CupertinoIcons.arrow_left
      ),
    );
  }

  static Widget _button({
    required String type,
    required String label, //constructing the required parameter
    Function()? callback
  }){
    Color textColor = AppColor.primary;
    Color backgroundColor = AppColor.secondary;
    Color borderColor = Colors.transparent;

    if(type == 'SECONDARY'){
      textColor = AppColor.secondary;
      backgroundColor = AppColor.primary;
      // borderColor = Colors.grey;
      borderColor = Color(0XFF414132);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 30),
      width: Buttons.width,
      height: Buttons.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),      ///////////
        borderRadius: BorderRadius.circular(9),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9), //set radius
          ),
        ),

        onPressed: callback,
        child: Text(label, style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.bold
        )),
      ),
    );
  } 

  static Widget primary(
    { required String label, Function()? onTap }    ////////////
  ){

    return _button(
      type: 'PRIMARY', label: label, callback: onTap   ?? () { }
    );

  }

  static Widget secondary(
    { required String label, Function()? onTap }    ////////////
  ){
    
    return _button(
      type: 'SECONDARY', label: label, callback: onTap ?? () { }
    );
    
  }

}