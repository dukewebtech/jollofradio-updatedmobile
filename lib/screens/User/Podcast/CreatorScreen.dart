import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/services/controllers/User/SubscriptionController.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/helpers/Factory.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:provider/provider.dart';

class CreatorScreen extends StatefulWidget {
  final Creator creator;
  const CreatorScreen({super.key, required this.creator});

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  late User user;
  bool isLoading = true;
  late Creator creator;
  late bool subscribed;
  String subscribers = "0";
  List podcasts = [];
  List topPick = [];
  List latest = [];

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    creator = widget.creator;
    subscribers = /* */ numberFormat(creator.followers!.length);
    subscribed = creator.subscribed(user);
    
    for(var podcast in creator.episodes!){
      podcasts.add(
        Episode.fromJson(podcast)
      );
    }

    //fetchs top picks
    topPick = podcasts;
    topPick.sort((a, b) {
      int e1 = a.streams['plays']; ////////////////////////////
      int e2 = b.streams['plays']; ////////////////////////////

      return e2.compareTo(e1);
    });

    //reversing object
    latest = Factory( podcasts.reversed.toList( ) ).get (0, 5);

    //limit data model
    topPick = Factory(topPick).get(0,5);
    latest = Factory(latest).get(0,5);

    setState(() {
      isLoading = false;
    });

    super.initState();
  }

  Future<void> _doSubscribe() async {
    bool subscribing = !subscribed;
    Map data = {
      'creator_id': creator.id
    };

    setState(() {
      subscribed = !subscribed;
    });

    if(subscribing){
      await SubscriptionController.create(data).then((status){
        if(!status){
          setState(() => subscribed = !subscribed);
        }
      });
      return;
    }
    if(!subscribing){    
      await SubscriptionController.delete(data).then((status){
        if(!status){
          // setState(() => _fav = !_fav);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;

    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back()
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: 0,
          left: 20, 
          right: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(isLoading) ...[
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2.6
                  ),
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: const CircularProgressIndicator(),
                      )
                    ],
                  ),
                )
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: creator.photo,
                        placeholder: (context, url) {
                          return Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator()
                            )
                          );
                        },
                        errorWidget: (context, url, error) => Icon(
                          Icons.error
                        ),
                        fit: BoxFit.cover,
                        color: Colors.black,
                        colorBlendMode: BlendMode.softLight
                      ),
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.bottomLeft,
                        color: Colors.black.withAlpha(50),
                        padding: EdgeInsets.all(10),
                        child: Labels.primary(
                          creator.username(),
                          maxLines: 2,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          margin: EdgeInsets.zero
                        )
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "$subscribers Subscribers", 
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0XFF9A9FA3)
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        height: 40,
                        // child: Buttons.primary(
                        //   label: !subscribed ? "Follow" : "Subscribed"
                        // )
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _doSubscribe();
                            }, 
                            icon: Icon(
                              !subscribed ? Icons.person_add : Icons.check, 
                              color: AppColor.primary
                            ), 
                            label: Text(
                              !subscribed ? "Follow Creator" : "Unfollow",
                              style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold  //////////////
                              ),
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Labels.primary(
                  "Top Podcasts",
                  fontSize: 18,
                ),
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if(topPick.isEmpty)
                          Container(
                            width: width - 40,
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Iconsax.document,
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
                          ...[
                            FadeIn(
                              child: Row(
                                children: [
                                  ...topPick.map((episode) => PodcastTemplate(
                                    type: 'grid',
                                    episode: episode
                                  ))
                                ],
                              ),
                            )
                          ]
                      ]
                    )
                  )
                ),
                SizedBox(height: 20),
                Labels.primary(
                  "New Release",
                  fontSize: 18,
                ),
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if(latest.isEmpty)
                          Container(
                            width: width - 40,
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Iconsax.document,
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
                          ...[
                            FadeIn(
                              child: Row(
                                children: [
                                  ...latest.map((episode) => PodcastTemplate(
                                    type: 'grid',
                                    episode: episode
                                  ))
                                ],
                              ),
                            )
                          ]
                      ]
                    )
                  )
                ),
                SizedBox(height: 60),
                Container(
                  width: double.infinity,
                  height: 180,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: AssetImage("assets/uploads/creators/banner.png"),
                      fit: BoxFit.cover
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withAlpha(0),
                    padding: EdgeInsets.fromLTRB(20,30,20,0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Labels.primary(
                          "About",
                          fontSize: 20,
                        ),
                        SizedBox(height: 10),
                        Text(
                          creator.about ?? "No description currently ${
                            ""
                          }available about this creator at the moment.",
                          style: TextStyle(
                            color: Color(0XFFBBBBBB),
                            fontSize: 14
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    )
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}