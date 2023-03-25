import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:provider/provider.dart';

class TrendingScreen extends StatefulWidget {
  final List podcasts;
  const TrendingScreen({super.key, required this.podcasts});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  late User user;
  bool isLoading = false;
  List episodes = [];

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    episodes = widget.podcasts;
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text("Trending Podcasts"),
      ),
      body: Center(
        child: Container(
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
                ]
                else ...[
                  Column(
                    children: [
                      if(episodes.isEmpty)
                        Container(
                          height: 300,
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 4
                          ),
                          padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Iconsax.music,
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
                        FadeInUp(
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 100 / 125,
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                            ),
                            physics: 
                            ScrollPhysics(parent: NeverScrollableScrollPhysics(  )),
                            itemCount: episodes.length,
                            itemBuilder: (context, index){
                              return GestureDetector(
                                onTap: () {
                                  RouteGenerator.goto(TRACK_PLAYER, {
                                    "track": episodes[index],
                                    "channel": "podcast"
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom: 10
                                  ),
                                  child: AbsorbPointer(
                                    child: PodcastTemplate(
                                      type: 'grid',
                                      compact: true,
                                      episode: episodes[index] ///////////////////////
                                    ),
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}