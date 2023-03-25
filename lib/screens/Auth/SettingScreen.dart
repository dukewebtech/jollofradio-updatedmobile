import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Test/SettingFactory.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/screens/Layouts/Templates/Setting.dart';
import 'package:jollofradio/widget/Buttons.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List settings = SettingFactory().get(0, 10);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Settings", style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        )),
        leading: Buttons.back(),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: 0,
          left: 20, 
          right: 20
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: Column(
                children: <Widget>[
                  ...settings.map((setting){
                    return SettingTemplate(setting: setting);
                  })
                ],
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF17252E)
                ),
                onPressed: () async {
                  await AuthController.logout();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Iconsax.logout_1, 
                      color: Color(0XFF676767)
                    ),
                    SizedBox(width: 10),
                    Text("Log Out", style: const TextStyle  (
                      color: Color(0XFF676767)
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}