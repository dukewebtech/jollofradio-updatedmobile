import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final String label;
  final Widget? icon;
  final Widget? trailingIcon;
  final TextInputType type;
  final TextInputAction action;
  final TextEditingController? controller;
  final TextAlign align;
  final bool password;
  final int? maxLines;
  final double height;
  final double fontSize;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double borderRadius;
  final Function(String value)? onChanged;
  final Function(String value)? onSubmitted;

  const TextInput({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.controller,
    this.type = TextInputType.text,
    this.align = TextAlign.left,
    this.action = TextInputAction.none,
    this.password = false,
    this.maxLines = 1,
    this.height = 50,
    this.fontSize = 14,
    this.color = const Color(0XFF000000),
    this.backgroundColor = const Color(0XFFF6F6F6),
    this.margin,
    this.padding,
    this.borderRadius = 10,
    this.onChanged,
    this.onSubmitted,
    
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: backgroundColor, 
        borderRadius: BorderRadius.circular(
          borderRadius
        ),
      ),
      child: TextField(
        controller: controller,
        autofocus: false,
        textAlign: align,
        obscureText: password,
        keyboardType: type,
        textInputAction: action,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: fontSize,
          color: color
        ),
        
        decoration: InputDecoration(
          contentPadding: padding ?? EdgeInsets.all(
            15
          ) ,
          prefixIcon: icon,
          suffixIcon: trailingIcon,
          hintText: label,
          hintStyle: TextStyle(
            fontSize: fontSize,
            color: Colors.white24
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
        ),

        onChanged: onChanged,
        onSubmitted: onSubmitted, /////////////////

      ),
    );
  }
}