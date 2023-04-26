import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/widget/Buttons.dart';

class PodcastResult extends StatefulWidget {
  final List<Episode> podcasts;

  const PodcastResult({super.key, required this.podcasts});

  @override
  State<PodcastResult> createState() => _PodcastResultState();
}

class _PodcastResultState extends State<PodcastResult> {
  var podcasts = [];

  @override
  void initState() {
    /*
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;
    */
    podcasts = widget.podcasts;
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text("Top Results"),
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
                Column(
                  children: [
                    FadeIn(
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
                        itemCount: podcasts.length,
                        itemBuilder: (context, index){
                          return GestureDetector(
                            onTap: () {
                              RouteGenerator.goto(TRACK_PLAYER, {
                                "track": podcasts[index],
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
                                  episode: podcasts[index] ///////////////////////
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
            ),
          ),
        ),
      ),
    );
  }
}