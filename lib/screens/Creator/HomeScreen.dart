import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/Creator/DashboardController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/screens/Layouts/Templates/Episode.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Shared.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Creator user;
  bool isLoading = true;
  CacheStream cacheManager = CacheStream();
  Map? statistics = {};

  @override
  void initState() {
    var auth = Provider.of<CreatorProvider>(context,listen: false);
    user = auth.user;

    //cache manager
    (() async {
      await cacheManager.mount({
        'statistics': {
          'data': () async {
            return await DashboardController.index(); ////////////
          },
          'rules': (data){
            return data != null;
          },
        },
      }, Duration(
        seconds: 10
      ));

      getStatistics();

    }());

    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<void> getStatistics() async {
    setState(() {
      isLoading = true;
    });

    final statistics = await cacheManager.stream( //////////////
      'statistics', 
      fallback: () async {
        return DashboardController.index();
      },
    );

    this.statistics = statistics;

    setState(() {
      isLoading = false;
    });
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
              getStatistics();
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
                    Labels.primary(
                      "Hi, " +user.firstname,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
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
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Color(0XFF0D1921),
                          borderRadius: BorderRadius.circular(100)
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: user.photo,
                            placeholder: (context, url) {
                              return Center(
                                child: SizedBox(
                                  width: 15,
                                  height: 15,
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
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Tile(
                          context: context,
                          type: "primary",
                          label: "Plays",
                          icon: Iconsax.play_circle5,
                          data: statistics?['plays'] 
                          ?? '-'
                        ),
                        Tile(
                          context: context,
                          type: "secondary",
                          label: "Episodes",
                          icon: Iconsax.music_filter,
                          data: statistics?['episodes'] 
                          ?? '-'
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Tile(
                          context: context,
                          type: "secondary",
                          label: "Impression",
                          icon: Iconsax.graph,
                          data: statistics?['impression'] 
                          ?? '-'
                        ),
                        Tile(
                          context: context,
                          type: "secondary",
                          label: "Subscribers",
                          icon: Iconsax.user,
                          data: statistics?['subscribers'] 
                          ?? '-'
                        ),
                      ],

                    )
                  ],
                ),
                SizedBox(height: 20),
                Labels.primary(
                  "Summary",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    minHeight: 100,
                    maxHeight: 300
                  ),
                  decoration: BoxDecoration(
                    color: Color(0XFF051724),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: isLoading ?
                    Container(
                      height: 100,
                      margin: EdgeInsets.zero,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const CircularProgressIndicator()
                        ],
                      ),
                    )
                  : statistics!['summary'].isEmpty ? 
                   Container(
                    height: 100,
                    padding: EdgeInsets.fromLTRB(20, 00, 20, 00),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Iconsax.graph5,
                          size: 40,
                          color: Color(0XFF9A9FA3),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          Message.no_data,
                          style: TextStyle(color: Color(0XFF9A9FA3),
                            fontSize: 14
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                  ),
                   ) 
                  :
                   SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        ...statistics!['summary'].entries.map((s) {
                          return Summary(
                            statistics: statistics!,
                            data: s,
                          );
                        })
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Labels.primary(
                  "Top Podcasts",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
                if(isLoading)
                Container(
                  margin: EdgeInsets.only(
                    // top: MediaQuery.of(context).size.height / 9
                    bottom: 20
                  ),
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: const CircularProgressIndicator(),
                      )
                    ],
                  ),
                )
                else 
                if(statistics?['top_episode'].isEmpty) 
                Container(
                  margin: EdgeInsets.only(
                    // top: MediaQuery.of(context).size.height / 9
                    bottom: 20
                  ),
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Iconsax.menu_1,
                        size: 40,
                        color: Color(0XFF9A9FA3),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        Message.no_data,
                        style: TextStyle(color: Color(0XFF9A9FA3),
                          fontSize: 14
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                )
                else
                Column(
                  children: <Widget>[
                    ...statistics!['top_episode'].map((episode) {
                      return EpisodeTemplate(
                        episode: episode,
                        podcasts: statistics!['top_episode']
                      );
                    })
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}