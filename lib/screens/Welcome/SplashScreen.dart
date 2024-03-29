// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/widget/Player.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/utils/scope.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool welcome = true;

  @override
  void initState() {
    _boostrapApp();
    super.initState();
  }

  Future<dynamic> _boostrapApp() async {
    Storage.delete('startup');
    await Storage.get('guest', bool).then((guest) async {

      if(guest == true){
        Storage.set('startup', false);
        RouteGenerator.exit(PUBLIC);
        return;
      }

    });

    var user = await Storage.get('user').then((user) async {
      var redirect = DASHBOARD;
      dynamic auth;

      if(user.runtimeType == String){
        setState(() {
          welcome = false;
          Storage.set('startup', false);
        });

        bool creator = await isCreator();
        if ( creator ){
          redirect = CREATOR_DASHBOARD;
          
          auth =
           Provider.of<CreatorProvider>(context, listen: false)
           .login(json.decode(user));

        }
        else {

          auth =
           Provider.of<UserProvider>(context, listen: false)
           .login(json.decode(user));

        }
        Player.user = auth; //prefmap
        RouteGenerator.exit(redirect);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: null,
      body: welcome != true ? SizedBox.shrink() : SizedBox(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        child: Stack(
          key: ValueKey(1),
          children: <Widget>[
            FadeIn(
              child: Image.asset("assets/images/illustration/shape.png")
            ),
            FadeInLeft(
              delay: Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 30),
                child: Image(
                  image: AssetImage("assets/images/girl.png"),
                  fit: BoxFit.contain,
                  // height: 550,
                  alignment: Alignment.bottomCenter,
                )
              ),
            ),
            Positioned(
              bottom: 0,
              child: FadeIn(
                delay: Duration(milliseconds: 1000),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 350,
                  padding: EdgeInsets.fromLTRB(40,0,40,0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(0, 0, 0, 0), 
                        Color.fromARGB(176, 3, 7, 24)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(Message.splash, style: TextStyle(
                        color: Colors.white,
                        height: 1.2,
                        fontSize: 50,
                        fontWeight: FontWeight.bold
                      )),
                      SizedBox(height: 20),
                      Text(
                        Message.splash_message,
                        style: TextStyle(
                          fontSize: 14
                        ),
                      ),
                      Spacer(),
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9)
                            )
                          ),
                          onPressed: () {

                            RouteGenerator.goto(SIGNIN);

                          },
                          child: Text("Get Started", style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}