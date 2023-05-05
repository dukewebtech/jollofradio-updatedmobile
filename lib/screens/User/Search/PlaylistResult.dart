import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Player.dart';

class PlaylistResult extends StatefulWidget {
  final List<Podcast> playlist;

  const PlaylistResult({super.key, required this.playlist});

  @override
  State<PlaylistResult> createState() => _PlaylistResultState();
}

class _PlaylistResultState extends State<PlaylistResult> {
  var playlist = [];

  @override
  void initState() {
    /*
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;
    */
    playlist = widget.playlist;
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text("Podcasts"),
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
                                itemCount: playlist.length,
                                itemBuilder: (context, index){
                                  return GestureDetector(
                                    onTap: () {
                                      RouteGenerator.goto(PODCAST, {

                                        "podcast": playlist[index],

                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        bottom: 10
                                      ),
                                      child: AbsorbPointer(
                                        child: PlaylistTemplate(
                                          playlist: playlist[index] ///////////////////////
                                          
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
              Player()
            ],
          ),
        ),
      ),
    );
  }
}