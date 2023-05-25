import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/screens/Layouts/TextInput.dart';

class Input {
  static double iconSize = 15.0;

  static Widget primary(
    String hint, { 
    TextEditingController? controller, IconData? leadingIcon, 
    IconData? trailingIcon,
    int maxLines = 1,
    double height = 50,
    bool password = false,
    TextAlign textAlign = TextAlign.left,
    Function(String value)? onChanged,
    Function(String value)? onSubmit,
  }){
    
    return TextInput(
      label: hint,
      controller: controller,
      color: Colors.white,
      height: height,
      backgroundColor: AppColor.input,
      borderRadius: 7,
      icon: leadingIcon != null ? /*show*/ Icon( ////////////
        leadingIcon, 
        color: Colors.white30,
        size: Input.iconSize,
      ) : null,
      trailingIcon: trailingIcon != null ? Icon( ////////////
        trailingIcon, 
        color: Colors.white30,
        size: Input.iconSize,
      ) : null,
      maxLines: maxLines,
      align: textAlign,
      password: password,
      onChanged: onChanged,
      onSubmitted: onSubmit,
    );
  }

  static Widget secondary(
    String hint, { 
    TextEditingController? controller, IconData? leadingIcon, 
    IconData? trailingIcon,
    int maxLines = 1,
    double height = 50,
    bool password = false,
    TextAlign textAlign = TextAlign.left,
    Function(String value)? onChanged,
    Function(String value)? onSubmit,
  }){

    return TextInput(
      label: hint,
      controller: controller,
      height: height,
      backgroundColor: AppColor.secondary,
      borderRadius: 7,
      icon: leadingIcon != null ? /*show*/ Icon( ////////////
        leadingIcon, 
        color: Colors.black,
        size: Input.iconSize,
      ) : null,
      trailingIcon: trailingIcon != null ? Icon( ////////////
        trailingIcon, 
        color: Colors.black,
        size: Input.iconSize,
      ) : null,
      maxLines: maxLines,
      align: textAlign,
      password: password,
      onChanged: onChanged,
      onSubmitted: onSubmit,
    );
  }
}