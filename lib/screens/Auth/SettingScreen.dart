import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/models/Test/SettingFactory.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/screens/Layouts/Templates/Setting.dart';
import 'package:jollofradio/utils/scope.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/services/auth/GoogleSignin.dart';
import 'package:jollofradio/screens/Layouts/TextInput.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';

class SettingScreen extends StatefulWidget {
  final dynamic user;
  
  const SettingScreen({
    super.key,
    required this.user 
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController code = TextEditingController();
  GoogleSigninAuth googleSignIn = GoogleSigninAuth();
  late dynamic user;
  bool creator = false;
  dynamic _setState;
  bool isDeleting = false;
  List settings = SettingFactory().get(0, 10);

  @override
  void initState() {
    user = widget.user;
    (() async {
      var creator = (await isCreator());

      setState(() {
        this.creator = creator;
      });
    }());

    settings.map((setting) {
      //map depth
      setting['options'].map((option) {
        String name = option['name'];
        dynamic userSetting = user.settings; //get user
        userSetting = userSetting
        .isEmpty ? {} : userSetting; //casts null check

        /*
        var config = userSetting.firstWhere((element) {
          return element['key'] == name;
        }, orElse: () => null)
        ?['value'] ?? false;
        */

        final bool config = userSetting[name] ?? false;
        option['active'] = config;
        
      }).toList();

    }).toList();

    super.initState();
  }

  Future<void> _deleteAccount() async {
    Map data = {
      'password': code.text,
      'userType': creator 
      ? 'creator' : 'user'
    };

    if(data['password'].isEmpty) return;
    _setState(() {
      isDeleting = true;
    });

    await AuthController.close(data).then((response) async {
      _setState(() => isDeleting = false );

      if(response['error']){
        Toaster.error(response['message']);
        return;
      }

      //closes the dailog
      Navigator.pop(context);

      //shows confirm msg
      Toaster.success(
        "You've successfully deleted your account! bye ... "
      );

      //logout user token
      AuthController.logout();
      googleSignIn.signOut ();

      //stop audio player
      audioHandler.stop();

      //redirects session
      await Future.delayed(Duration(seconds: 2), () async {
        
        RouteGenerator.goBack(2); /////////////////////////
        RouteGenerator.exit(
          SIGNIN, {"signout": 1}
        );

      });
    });
  }

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
        width: MediaQuery.of(context).size.width, //////////
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
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ...settings.map((setting){
                      return SettingTemplate(setting: setting);
                    })
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withAlpha(50)
                ),
                onPressed: () async => _initCloseDialog() ,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Iconsax.profile_delete, 
                      color: Colors.red
                    ),
                    SizedBox(width: 10),
                    Text("Close Account", style: const TextStyle  (
                      color: Colors.red
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

  Future<dynamic> _initCloseDialog() async {
    setState(() {
      isDeleting = false;
    });

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Close Account?", style: const TextStyle(
            color: Colors.red,
            fontSize: 15,
            fontWeight: FontWeight.bold
          )),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Come On 😟",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "We can talk this through and improve your ${  ///
                  ""
                }experience, else if you've made up your mind. ${
                  ""
                }click on the confirm button to delete your ${ ///
                  ""
                }account",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent
              ),
              onPressed: () {
                Navigator.pop(context);

                Future.delayed(Duration(seconds: (1)), ( ) async {
                  _confirmCloseDialog();
                });
              },
              child: Text("Yes, proceed!", style: const TextStyle(
                color: Colors.red
              )),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent
              ),
              onPressed: () {
                Navigator.pop(context);

              },
              child: Text("No, I'll stay", style: const TextStyle(
                color: Colors.black
              )),
            )
          ],
        );
      },
    );
  }

  Future<dynamic> _confirmCloseDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _setState = setState;
            setState(() {
              isDeleting = isDeleting;
            });
            
            if(isDeleting) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min, /////////////////////
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: ( const CircularProgressIndicator( ) )
                        ),
                      )
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(20, 25, 25, 0),
              title: Text("Authorize Deletion", style: const TextStyle(
                color: Colors.red,
                fontSize: 15,
                fontWeight: FontWeight.bold
              )),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "This action cannot be undone! You still have a ${""
                    }chance to cancel and enjoy our awesome services", //
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Enter your password to authorize deletion of all ${
                      ""
                    }related services on the JollofRadio platform", ////
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextInput(
                    controller: code,
                    icon: Icon(
                      Iconsax.key,
                      size: 14,
                    ),
                    label: "...",
                    color: AppColor.primary,
                    password: true,
                    margin: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent
                  ),
                  onPressed: () {
                    _deleteAccount();
                  },
                  child: Text("Authorize", style: const TextStyle( /////
                    color: Colors.red
                  )),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: const TextStyle( ////////
                    color: Colors.black
                  )),
                )
              ],
            );
          }
        );
      },
    );
  }
}