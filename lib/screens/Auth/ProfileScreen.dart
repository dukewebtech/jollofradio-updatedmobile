import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/scope.dart';
import 'package:jollofradio/config/services/auth/GoogleSignin.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';

class ProfileScreen extends StatefulWidget {
  final dynamic user;
  
  const ProfileScreen({ 
    Key? key, 
    required this.user
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GoogleSigninAuth googleSignIn = GoogleSigninAuth();
  late dynamic user;
  bool creator = false;
  List<Map> menu = [
    {
      "label": "Edit Profile",
      "icon": Iconsax.user,
      "action": (user){
        RouteGenerator.goto(PROFILE_EDIT, {
          "user": user,
          "mode": "account",
          "title": "Edit Profile"
        });
      }
    },
    {
      "label": "Change Password",
      "icon": Iconsax.security,
      "action": (user){
        RouteGenerator.goto(PROFILE_EDIT, {
          "user": user,
          "mode": "security",
          "title": "Change Password"
        });
      }
    },
    {
      "label": "Settings",
      "icon": Iconsax.setting,
      "action": (user){
        RouteGenerator.goto(SETTINGS, {
          "user": user,
        });
      }
    },
    {
      "label": "Help & Support",
      "icon": Iconsax.message,
      "action": (user){
        RouteGenerator.goto(WEBVIEW, {
          "title": "Live Chat",
          "file": "assets/html/chat.html"
        });
      }
    },
  ];

  @override
  void initState() {
    user = widget.user;
    (() async {
      var creator = (await isCreator());

      setState(() {
        this.creator = creator;
      });
    }());
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Profile", style: const TextStyle(
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
          left: 0, 
          right: 0
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Color(0XFF0D1921)
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(100)
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: CachedNetworkImage(
                      imageUrl: user.photo,
                      placeholder: (context, url) {
                        return Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            )
                          )
                        );
                      },
                      errorWidget: (context, url, error) => Icon(
                        Icons.error
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Labels.primary(
                        user.username(),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        margin: EdgeInsets.only(
                          bottom: 5
                        )
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user.telephone!='' ? user.telephone : 'n/a',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: 80,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColor.secondary,
                                borderRadius: BorderRadius.circular ( 50 )
                              ),
                              child: Text(
                                creator ? "CREATOR" : "USER",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB  (10, 0, 0, 0),
                child: Column(
                  children: <Widget>[
                    ...menu.map<ListTile>((item){
                      return ListTile(
                        leading: Icon(
                          item['icon'], color: Colors.white,
                          size: 20,
                        ),
                        minLeadingWidth: 10,
                        trailing: Icon(
                          Iconsax.arrow_right_3, size:  ( 14 ),
                          color: Colors.white
                        ),
                        title: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Labels.primary(
                            item['label'],
                            fontSize: 15),
                        ),
                        onTap: () => item['action']( user),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF17252E)
                ),
                onPressed: () async {

                  await AuthController.logout();
                  audioHandler.stop();
                  
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
          ]
        )
      )
    );
  }
}