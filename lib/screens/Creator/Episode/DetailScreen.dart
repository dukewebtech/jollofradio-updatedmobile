import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/Creator/EpisodeController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Shared.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  final Episode episode;
  final dynamic callback;

  const DetailScreen({ 
    Key? key,
    required this.episode,
    this.callback
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Creator user;
  bool isLoading = true;  
  late Episode episode;

  @override
  void initState() {
    var auth = Provider.of<CreatorProvider>(context,listen: false);
    user = auth.user;

    episode = widget.episode;
    _getEpisode();

    super.initState();
  }

  Future<void> _getEpisode() async {
    await EpisodeController.show(episode).then((episode) async {

      if(episode == null){
        RouteGenerator.goBack();
        return Toaster.error("We couldn't fetch that episode 😟");
      }

      setState(() {
        this.episode = episode;
        isLoading = false;        
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        // title: Text(episode.podcast),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.podcast, 
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.bold,
                      )
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      episode.title, 
                      style: TextStyle(
                        color: AppColor.secondary,
                        letterSpacing: .5,
                        fontSize: 14, fontWeight: FontWeight.bold,
                      )
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      height: 180,
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(
                        bottom: 40
                      ),
                      decoration: BoxDecoration(
                        color: Color(0XFF051724),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("About", style: TextStyle(
                            fontSize: 18,
                          )),
                          SizedBox(
                            height: 10
                          ),
                          Text(
                            episode.description ?? 
                            Message.no_desc, style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.white
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Labels.primary(
                      "Stats",
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Tile(
                          context: context,
                          type: "secondary",
                          label: "Likes",
                          icon: Iconsax.heart5,
                          data: episode.streams['likes'],
                          color: AppColor.secondary,
                        ),
                        Tile(
                          context: context,
                          type: "secondary",
                          label: "Playlist Adds",
                          icon: Iconsax.add,
                          data: episode.streams['playlist'] 
                          ?? '-',
                          color: AppColor.secondary,
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
                          label: "Plays",
                          icon: Iconsax.play_circle5,
                          data: episode.streams['plays'],
                          color: AppColor.secondary,
                        ),
                        Tile(
                          context: context,
                          type: "secondary",
                          label: "Impression",
                          icon: Iconsax.music_filter,
                          data: episode.streams['replays'],
                          color: AppColor.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Buttons.primary(
                label: "Edit Episode",
                onTap: () => RouteGenerator.goto(CREATOR_EPISODE_NEW, {
                  "type": "update",
                  "episode": episode,
                  "callback": widget.callback
                }),
              ),
            ]
          ]
        )
      )
    );
  }
}