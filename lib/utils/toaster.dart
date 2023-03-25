import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toaster extends Fluttertoast {
  Toaster(){
    //

  }

  static late ToastGravity position = ToastGravity.BOTTOM;

  static void show({message, position, status}){   
    Map alignment = <String, dynamic>{
      'TOP': ToastGravity.TOP,
      'TOP_LEFT': ToastGravity.TOP_LEFT,
      'TOP_RIGHT': ToastGravity.BOTTOM,
      'BOTTOM': ToastGravity.BOTTOM,
      'BOTTOM_LEFT': ToastGravity.BOTTOM_LEFT,
      'BOTTOM_RIGHT': ToastGravity.BOTTOM_RIGHT,
      'CENTER': ToastGravity.CENTER,
      'CENTER_LEFT': ToastGravity.CENTER_LEFT,
      'CENTER_RIGHT': ToastGravity.CENTER_RIGHT,
      'SNACKBAR': ToastGravity.SNACKBAR
    };

    Map toastFlag = <String, Color?>{
      'success': Colors.green[800], //msg success ballon
      'error': Colors.red[800],     //msg error ballon
      'warning': Colors.orange[200],//msg warning ballon
      'info': Colors.blue[800],     //msg info ballon
    };

    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: message,
        gravity: alignment[position], 
        fontSize: 14, backgroundColor: toastFlag[status],
    );
  }

  static void success(String message){
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      gravity: position, 
      textColor: Colors.white,
      fontSize: 14, backgroundColor: Colors.green[800],
    );
  }

  static void error(String message){
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      gravity: position,
      textColor: Colors.white,
      fontSize: 14, backgroundColor: Colors.red[800],
    );
  }

  static void warning(String message){
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      gravity: position,
      textColor: Colors.white,
      fontSize: 14, backgroundColor: Colors.orange[200],
    );
  }

  static void info(String message){
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      gravity: position,
      textColor: Colors.white,
      fontSize: 14, backgroundColor: Colors.blue[800],
    );
  }
}