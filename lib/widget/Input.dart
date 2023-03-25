import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/screens/Layouts/TextInput.dart';

class Input {
  static double iconSize = 15.0;
  

  static Widget primary(
    String hint, { 
    TextEditingController? controller, IconData? leadingIcon, 
    IconData? trailingIcon,
    bool password = false,
    Function(String value)? onChanged,
    Function(String value)? onSubmit,
  }){
    
    return TextInput(
      label: hint,
      controller: controller,
      color: Colors.white,
      backgroundColor: AppColor.input,
      borderRadius: 7,
      icon: leadingIcon != null ? /*show*/ Icon( ////////////
        leadingIcon, 
        color: Colors.white24,
        size: Input.iconSize,
      ) : null,
      trailingIcon: trailingIcon != null ? Icon( ////////////
        trailingIcon, 
        color: Colors.white24,
        size: Input.iconSize,
      ) : null,
      password: password,
      onChanged: onChanged,
      onSubmitted: onSubmit,
    );
  }

  static Widget secondary(
    String hint, { 
    TextEditingController? controller, IconData? leadingIcon, 
    IconData? trailingIcon,
    bool password = false,
    Function(String value)? onChanged,
    Function(String value)? onSubmit,
  }){

    return TextInput(
      label: hint,
      controller: controller,
      backgroundColor: AppColor.secondary,
      borderRadius: 7,
      icon: leadingIcon != null ? /*show*/ Icon( ////////////
        leadingIcon, 
        color: Colors.white24,
        size: Input.iconSize,
      ) : null,
      trailingIcon: trailingIcon != null ? Icon( ////////////
        trailingIcon, 
        color: Colors.white24,
        size: Input.iconSize,
      ) : null,
      password: password,
      onChanged: onChanged,
      onSubmitted: onSubmit,
    );
  }

}