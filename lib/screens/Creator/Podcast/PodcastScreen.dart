import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Player.dart';

class PodcastScreen extends StatefulWidget {
  final String title;
  final List podcasts;
  const PodcastScreen({
    super.key, 
    required this.title,
    required this.podcasts
  });

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  bool isLoading = false;
  List podcasts = [];

  @override
  void initState() {
    podcasts = widget.podcasts;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          margin: EdgeInsets.only(
            top: 0,
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
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
                              if(podcasts.isEmpty)
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
                                    itemCount: podcasts.length,
                                    itemBuilder: (context, index){
                                      return Container(
                                        margin: EdgeInsets.only(
                                          bottom: 10
                                        ),
                                        child: PlaylistTemplate(
                                          playlist: podcasts[index], ///////////////////////
                                          creator: true,
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
              Player()
            ],
          ),
        ),
      ),
    );
  }
}