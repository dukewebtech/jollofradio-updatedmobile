import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class Cropper {

  static const TITLE = "Crop Image";

  static Future<File?> cropImage(File image) async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
          cropGridColor: Colors.black,
          toolbarTitle: TITLE,
          statusBarColor: Color(0XFF030F18),
          toolbarColor: Color(0XFF030F18),
          activeControlsWidgetColor:/**/Color(0XFFF0CF7B),
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: TITLE,
          aspectRatioLockEnabled: true,
        )
      ]
    );

    if(cropped != null) {

      return File(cropped.path); //return a cropped image

    }

    return null;

  }

}