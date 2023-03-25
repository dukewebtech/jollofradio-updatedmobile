import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/widget/Labels.dart';

class SettingTemplate extends StatefulWidget {
  final Map setting;
  const SettingTemplate({super.key, required this.setting});

  @override
  State<SettingTemplate> createState() => _SettingTemplateState();
}

class _SettingTemplateState extends State<SettingTemplate> {

  @override
  Widget build(BuildContext context) {
    Map setting = widget.setting;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Labels.primary(
            setting['title'],
            fontSize: 14,
            fontWeight: FontWeight.bold,
            margin: EdgeInsets.zero
          ),
          ...setting['options'].map((option){

            return Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 250,
                    child: Text(option['description'], style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey
                    )),
                  ),
                  CupertinoSwitch(
                    activeColor: AppColor.secondary,
                    value: option['active'], 
                    onChanged: (value) {
                      setState(() {
                        option['active'] = !option['active'];
                      });
                    },
                  )
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}