import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:share_plus/share_plus.dart';

class EpisodeTemplate extends StatefulWidget {
  final Map episode;
  final List? podcasts;

  const EpisodeTemplate({
    super.key,
    required this.episode,
    this.podcasts
  });

  @override
  State<EpisodeTemplate> createState() => _EpisodeTemplateState();
}

class _EpisodeTemplateState extends State<EpisodeTemplate> {
  late Episode episode;
  List? podcasts;

  @override
  void initState() {
    /*
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;
    */
    var data = (widget.episode);
    
    episode = toEpisode( data );
    podcasts = widget.podcasts;

    super.initState(); 
  }

  Episode toEpisode(Map data) { ///////////////////////////////
    return Episode.fromJson({
      "id": data['id'],
      "creator": null,
      "title": data['title'],
      "slug": data['slug'],
      "logo": data['logo'],
      "description": data['description'],
      "source": data['source'],
      "duration": data['duration'],
      "streams": data['streams'],
      "meta": data['meta'],
      "podcast": data['podcast']['title'],
      "podcast_id": data['podcast']['id'],
      "liked": false,
      "created_at": data['created_at'],
    });
    
  }

  Future<void> _share() async {
    await Share.share(
      shareLink(
        type: 'episode', data: episode
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;

    return GestureDetector(
      onTap: () => RouteGenerator.goto(CREATOR_EPISODE, {
        "track": episode,
        "channel": "podcast",
        "playlist": podcasts?.map((e) => toEpisode(e)).toList()
      }),
      child: Container(
        width: double.infinity,
        height: 90,
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Color(0XFF12222D),
          borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(5)
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: episode.logo,
                placeholder: (context, url) {
                  return Image.asset(
                    'assets/images/loader.png',
                    fit: BoxFit.cover,
                  );
                },
                errorWidget: (context, url, error) =>  Icon(
                  Icons.error
                ),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width - 150,
              height: 70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                          child: Labels.primary(
                            episode.title,
                            maxLines: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            margin: EdgeInsets.only(bottom: 5)
                          ),
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Played: ${episode.streams['plays']} times", 
                                style: TextStyle(
                                  color: Color(0XFF9A9FA3),
                                  fontSize: 12
                                ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text("${episode.streams['stats']} devices", 
                                style: TextStyle(
                                  color: Color(0XFF9A9FA3),
                                  fontSize: 10
                                )),
                              ],
                            ),
                            Spacer(),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  PopupMenuButton(
                                    color: AppColor.primary,
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          onTap: () {
                                            Future((){
                                              RouteGenerator.goto(TRACK_PLAYER, {
                                                "track": episode,
                                                "channel": "podcast",
                                                "playlist": podcasts?.map((e) => 
                                                toEpisode(e)).toList()
                                              });
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.play_arrow, 
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 10),
                                              Text("Play", style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14
                                              )),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () async => await _share(),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.share, 
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 10),
                                              Text("Share", style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14
                                              )),
                                            ],
                                          ),
                                        )
                                      ];
                                    },
                                    child: Icon(
                                      Icons.more_horiz, color: Color(0XFF9A9FA3)
                                    )
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}