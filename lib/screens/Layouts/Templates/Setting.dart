import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:provider/provider.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/utils/scope.dart';
import 'package:jollofradio/widget/Labels.dart';

class SettingTemplate extends StatefulWidget {
  final Map setting;
  const SettingTemplate({super.key, required this.setting});

  @override
  State<SettingTemplate> createState() => _SettingTemplateState();
}

class _SettingTemplateState extends State<SettingTemplate> {

  Future<void> _updateSetting(Map option) async {
    bool creator = await isCreator();
    
    setState(() {
      option['active'] = !option['active'];
    });

    Map payload = {
      'userType': (creator) 
      ? 'creator' : 'user',
      'settings': {
        option['name']: option['active']
      }
    };

    AuthController.update(payload).then((dynamic response) {
      if(response['error']){
        //revert state change
        setState(() {
          option['active'] = !option['active'];
        });

        Toaster.error(response['message']);
        return;
      }

      if(!creator){

         Provider.of<UserProvider   >(context, listen: false)
        .login(response['data']);

      }
      else {

         Provider.of<CreatorProvider>(context, listen: false)
        .login(response['data']);

      }
    });
  }

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
                        _updateSetting(option);
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