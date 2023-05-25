import 'package:animate_do/animate_do.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/Creator/PodcastController.dart';
import 'package:jollofradio/config/services/controllers/User/PlaylistController.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Podcast.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Player.dart';
import 'package:jollofradio/widget/Shared.dart';
import 'package:share_plus/share_plus.dart';

class ManageScreen extends StatefulWidget {
  final Podcast podcast;
  const ManageScreen({super.key, required this.podcast});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  late Podcast podcast;
  AudioServiceHandler player = AudioServiceHandler();
  late PlaybackState playerState;
  bool isLoading = true;
  List<MediaItem> tracks = [];
  MediaItem? currentTrack;
  List<Episode> episodes = [];
  Map<bool, dynamic> status = {
    true: {
      "label": 'Approved',
      "color": Colors.green
    },
    false: {
      "label": 'Unapproved',
      "color": Color(0XFF12222D)
    }
  };

  @override
  void initState() {
    podcast = widget.podcast;
    
    initPlayer ();
    getPlaylist();

    super.initState();
  }

  Future<void> initPlayer() async {
    audioHandler.playbackState.listen((PlaybackState state) {
      playerState = state;
      currentTrack = player.currentTrack();  //updating track

      if(mounted) {
        setState(() {});
      }
    });
  }

  bool onTrack(Episode episode) {
    String episodeId = episode.id.toString();//fetch track id

    if(currentTrack?.id == episodeId){
      if(playerState.playing == true){
        return true;
      }
    }
    return false;
  }

  Future<void> getPlaylist() async {
    int id = podcast.id;
    setState(() {
      isLoading = true;
    });

    await PlaylistController.show(id).then((playlist) async {
      if(playlist != null){        
        setState(() {
          podcast = playlist;
          episodes = playlist.episodes!;
          isLoading = false;
        });
        
        /*
        episodes = playlist.episodes!.map<Episode>((episode){
          return episode;
        }).toList();
        */
      }
    });
  }

  Future _action(String type) async {
    await Future((){});

    if(type == 'edit'){
      RouteGenerator.goto(CREATOR_PODCAST_NEW, { //redirect...
        "type": "edit",
        "podcast": podcast,
        "callback": getPlaylist
      });
    }

    if(type == 'share'){
      return await Share.share(
        shareLink(
          type: 'podcast', data: podcast
        )
      );
    }

    if(type == 'delete'){
      int id = podcast.id;

      void mountStream(){
        CacheStream().mount({
          '_podcasts': {
            'data': () async {
              return await PodcastController.index(); //////
            },
            'rules': (data){
              return data.isNotEmpty;
            },
          },
        }, null);
      }

      return deleteModal(
        context: context,
        title: Message.build(Message.delete_item, /* * */  {
          "item": "podcast",
          "source": "account"
        }),
        state: null,
        callback: () async {
          Navigator.pop(context);
          Toaster.info("Deleting podcast... please wait.") ;

          await PodcastController.delete(id).then((status) {

            mountStream();
            RouteGenerator.goBack();

          });
        }
      );
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
                      Container(
                        width: double.infinity,
                        height: 200,
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Color(0XFF0D1921),
                          borderRadius: BorderRadius.circular(6),
                          /*
                          image: DecorationImage(
                            image: AssetImage("assets/uploads/creators/photo.png"),
                            fit: BoxFit.cover
                          ),
                          */
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          imageUrl: podcast.logo,
                          placeholder: (context, url) {
                            return Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator()
                              )
                            );
                          },
                          imageBuilder: (context, imageProvider) {
                            return ZoomIn(
                              child: Image(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                          errorWidget: (context, url, error) => Icon(
                            Icons.error
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Labels.primary(
                            "About",
                            fontSize: 18,
                            margin: EdgeInsets.only(bottom: 5)
                          ),
                          if(!isLoading)
                          FadeIn(
                            child: Container(
                              width: 80,
                              height: 15,
                              decoration: BoxDecoration(
                                color: status[podcast.approved]['color'],
                                borderRadius: BorderRadius.circular(50)
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                status[podcast.approved]['label'], 
                                style: TextStyle(
                                  fontSize: 10
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Wrap(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              podcast.description ?? Message.no_desc,
                              style: TextStyle(
                                color: Color(0XFFBBBBBB),
                                fontSize: 14
                              ),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if(textOverflow(
                            podcast.description ?? '',
                            TextStyle(
                              fontSize: 14
                            ),
                            maxLines: 5, 
                            maxWidth: MediaQuery.of(context).size.width.toDouble()
                          ))
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context, 
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(podcast.title, style: TextStyle(
                                      color: AppColor.primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                    )),
                                    content: Text(
                                      podcast.description ?? '',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text("See more", style: TextStyle(
                              color: AppColor.secondary
                            ))
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    podcast.title, style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFFFFFFFF)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: PopupMenuButton(
                                color: AppColor.primary,
                                itemBuilder: (context) {
                                  List<Map> popupActions = [
                                    {
                                      "id": "edit",
                                      "label": "Edit Podcast",
                                      "icon": Iconsax.edit_2, //////////////
                                      "color": Colors.white
                                    },
                                    {
                                      "id": "share",
                                      "label": "Share",
                                      "icon": Iconsax.share, //////////////
                                      "color": Colors.white
                                    },
                                    {
                                      "id": "delete",
                                      "label": "Delete",
                                      "icon": Iconsax.trash,  //////////////
                                      "color": Colors.red
                                    },
                                  ];

                                  return popupActions.map<PopupMenuItem>((e){
                                    return PopupMenuItem(
                                      value: e['id'],
                                      onTap: () {
                                        _action(e['id']);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            e['icon'], 
                                            size: 14, color: /**/ e['color'],
                                          ),
                                          SizedBox(width: 20),
                                          Text(
                                            e['label'], 
                                            style: TextStyle(
                                              color: e['color'],
                                              fontSize: 14
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                  
                                },
                                child: Icon(
                                  Icons.more_horiz, color: Color(0XFF9A9FA3)
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (width - 40) / 2.1,
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                RouteGenerator.goto(
                                  CREATOR_EPISODE_NEW, {
                                    "type": "create",
                                    "podcast": podcast,
                                    "callback": getPlaylist
                                  }
                                );
                              }, 
                              icon: Icon(
                                Iconsax.add, color: Colors.black
                              ), 
                              label: Text(
                                "Add Episode", style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              ))
                            ),
                          ),
                          // SizedBox(
                          //   width: 20,
                          // ),
                          SizedBox(
                            width: (width - 40) / 2.1,
                            height: 40,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent
                              ),
                              onPressed: () {
                                Toaster.info("Service coming soon..");
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Go live', style: TextStyle()),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Iconsax.microphone_2,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          Text(
                            "All Episodes", style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFFBBBBBB)
                            ),
                          ),
                          Spacer(),
                          if(!isLoading)
                          Labels.secondary(
                            "${podcast.episodes!.length} Episode(s)",
                            margin: EdgeInsets.zero
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            if(isLoading) ...[
                              PodcastShimmer(
                                type: 'list', length: 3,
                              )
                            ]
                            else
                            if(podcast.episodes!.isEmpty)
                              FadeIn(
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
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
                                ),
                              )
                            else
                              ...[
                                FadeInUp(
                                  child: Column(
                                    children: [
                                      ...podcast
                                        .episodes!.map((episode) => PodcastTemplate(
                                        key: UniqueKey(),
                                        type: 'list',
                                        playing: onTrack(episode),
                                        episode: episode,
                                        podcasts: episodes,
                                        creator: true,
                                        callback: getPlaylist,
                                      ))
                                    ],
                                  ),
                                )
                              ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Player()
          ],
        ),
      ),
    );
  }
}