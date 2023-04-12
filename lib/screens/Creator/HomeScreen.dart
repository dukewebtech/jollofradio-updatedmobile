import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/date.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Creator user;

  @override
  void initState() {
    var auth = Provider.of<CreatorProvider>(context,listen: false);
    user = auth.user;

    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  bool hasNotifications(){
    bool unread = false;
    final List notifications = user.notifications!.map((alert) {
      if(alert['status'] == 'unread'){
        unread = true;
      }
    }).toList();

    return unread;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;
    
    return Scaffold(
      appBar: null,
      body: LiquidPullToRefresh(
        showChildOpacityTransition: false,
        height: 120,
        backgroundColor: AppColor.secondary,
        onRefresh: () async => {
          await Future.delayed(Duration(seconds: 1), () async {
            setState(() {
              // isLoading = true;
            });
          })
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          margin: EdgeInsets.only(
            top: AppBar().preferredSize.height + 00,
            left: 20, 
            right: 20
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 250,
                      child: Labels.primary(
                        "Hi, " +user.firstname,
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        RouteGenerator.goto(NOTIFICATION, {
                          "user": user
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0XFF0D1921),
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Iconsax.notification,
                              color: Color(0XFF828282),
                              size: 16,
                            ),
                            if(hasNotifications())
                            Positioned(
                              top: 5,
                              right: 2,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Color(0XFFFF4242),
                                  borderRadius: BorderRadius.circular(100)
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                         RouteGenerator.goto(PROFILE, {
                          "user": user
                         });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0XFF0D1921),
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Icon(
                          Iconsax.user,
                          color: Color(0XFF828282),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Labels.primary(
                  "Overview",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
                SizedBox(
                  height: 300,
                ),
                Labels.primary(
                  "Summary",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),                
              ],
            ),
          ),
        ),
      ),
    );
  }
}