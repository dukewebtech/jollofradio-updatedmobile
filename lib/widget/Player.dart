import 'dart:async';
import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/models/Station.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:just_audio/just_audio.dart';

bool firstrun = false;

class Player extends StatefulWidget {
  final Widget? child;
  static dynamic user;
  const Player({ Key? key, this.child }) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  Color trackColor = AppColor.primary;
  final AudioServiceHandler player = AudioServiceHandler();
  bool isPlaying = false;
  bool isVisible = false;
  bool onClicked = false;
  dynamic playState;
  dynamic user;
  dynamic track;
  String title = "-";
  String subtitle = "-";
  List playlist = [];
  Map route = {
    "name": TRACK_PLAYER,
    "track": null,
    "cahnnel": null
  };

  @override
  void initState() {
    user = Player.user;
    initPlayer ();
    
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  void initPlayer() async {
    //playlist
    await Future(() async {
      var getTracks = await Storage.get('podcasts');
      if(getTracks != null){
        playlist = jsonDecode(getTracks);
      }
    });

    //last track
    Storage.get('lastTrack',Map).then((item)async {
      if(item == null||firstrun||playlist.isEmpty)
        return;

      firstrun = true;
      final track = item['track'];
      bool isPodcast = track['extras'].containsKey(
        'episode'
      ) ?? false;
      Duration duration = Duration();

      if(!isPodcast){
        await player.setPlaylist([/** */ MediaItem(
          id: track['id'],
          title: track['title'],
          album: track['album'],
          artist: track['artist'],
          artUri: Uri.parse(track['artUri']),
          extras: track['extras'],
        )]);
      }
      else{
        await player.setPlaylist(playlist.map( ////
          (item){
          Episode episode = Episode.fromJson(item);
          if(item['id']==track['id']){
            duration = Duration(
              milliseconds: track['duration']  ////
            );
          }
          return MediaItem(
            id: episode.id.toString(),
            title: episode.title,
            album: episode.podcast,
            artist: episode.creator?.username()??'',
            artUri: Uri.parse(
              episode.logo
            ),
            duration: duration,
            extras: {
              "url": episode.source,
              "episode": episode.toJson()
            }
          );
        }).toList());

        ///////////////////////////////////////////
        int index = player.getPlaylist().indexWhere
        ((e) => e.id == track['id'] ); ////////////

        player.skipToQueueItem(index); //skip track
        player.seek(
          Duration(milliseconds: track['position'])
        );
      }
        if(user!=null && user.setting('autoplay')){
          // player.play();
        }
    });

    //fetch & store
    player.streams().listen((dynamic event) async {
      final playState = event['playState'];
      final currState = playState.processingState;

      final currentTrack = (player.currentTrack( ));
      dynamic track = "";
      bool isPodcast = 
      currentTrack?.extras?.containsKey ('episode') 
      ?? false ;
      if(isPodcast){
        track = Episode.fromJson(
          currentTrack?.extras? ['episode'] // cast
        );
        title = track.title;
        subtitle = track.podcast.toString();
        route = {
          "name": TRACK_PLAYER,
          "track": track, "channel": "podcast"
        };
      }
      else {
        track = Station.fromJson(
          currentTrack?.extras? ['station'] // cast
        );
        title = track.title;
        subtitle = track.frequency.toString()
        +' FM';
        route = {
          "name": RADIO_PLAYER, 
          "radio": track, "channel": "station"
        };
      }

      //color effect
      if(this.track?.title != currentTrack?.title){
        trackColor = AppColor.primary;
        /*
        Colorly().from('network').get(track?.logo)
        .then((color){
          trackColor = 
          color?['primary']  ?? (AppColor.primary);
        });
        */
      }

      if(playState != this.playState 
      || track?.id != this.track?.id){//state check
        if(!mounted) return;
        print('state rebuild fired!');
        setState(() {
          this.track = track;
          this.playState = playState;
          isVisible = 
                 currState != ProcessingState.idle;
          isPlaying = playState.playing;
        });
      }

      //track stream
      Map media = <String, Map>{
        "track": {
          "id": currentTrack?.id.toString(),
          "title": currentTrack?.title ?? '-',
          "album": currentTrack?.album ?? '-',
          "artist": currentTrack?.artist,
          "artUri": currentTrack?.artUri.toString(),
          "duration": currentTrack?.duration
          ?.inMilliseconds,
          "extras": currentTrack?.extras,
          "position": event['position']
          .inMilliseconds,
        }
      };
      
      Timer(Duration(seconds: 5), () =>{        
        if(isPlaying)
        Storage.set(
          'lastTrack', jsonEncode(media) // saving...
        )
      });
    });
  }

  Future openTrackPlayer() async {
    var playlist = await Storage.get('podcasts'); //tracks
    if(playlist != null){
      playlist = jsonDecode(playlist);
    }    
    RouteGenerator.goto(route['name'], <String, dynamic> {
      ...route,
      "playlist": playlist?.map<Episode>((dynamic track) {
        return Episode.fromJson(track);
      }).toList()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          visible: isVisible,
          child: Dismissible(
            key: UniqueKey(),
            confirmDismiss: (direction) async {
              await player.stop();
              await Storage.delete('lastTrack');
              return true;
            },
            onDismissed: (DismissDirection direction) {
              //do nothing!
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              color: trackColor,
              child: Container(
                color: Colors.black.withAlpha(50),
                padding: EdgeInsets.fromLTRB(22,5,20,5),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async => await openTrackPlayer(),
                      child: Container(
                        width: 60,
                        height: 50,
                        color: Color(0XFF0D1921),
                        margin: EdgeInsets.only(right: 10),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          height: double.infinity,
                          imageUrl: track?.logo ?? '-',
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
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async => await openTrackPlayer(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Labels.primary(
                              title,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              maxLines: 1,
                              margin: EdgeInsets.only(
                                top: 5,
                                bottom: 2
                              )
                            ),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: AppColor.secondary.withOpacity(
                                  0.8
                                ),
                                fontSize: 12
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        /*
                        if(state == ( ProcessingState.buffering ) )
                          return;
                        !isPlaying ? player.play() : player.pause();
                        */
                        if(!isPlaying){
                          player.play();
                          onClicked = true;
                        }
                        else{
                          player.pause();
                          onClicked = false;
                        }
                        setState(() => isPlaying  =  (!isPlaying));
                      },
                      child: Builder(
                        builder: (context) {
                          final state = playState.processingState;
                          return Container(
                            width: 35,
                            height: 35,
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: AppColor.secondary,
                              borderRadius: BorderRadius.circular (100)
                            ),
                            child: state != ProcessingState.ready 
                                && state != ProcessingState.completed ? 
                            Center(
                              child: SizedBox(
                                width: 15,
                                height: 15,
                                child: /* */ CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.primary,
                                )
                              ),
                            ) :
                            Icon(
                              !isPlaying ? 
                              Icons.play_arrow : Icons.pause, size: 20,
                            ),
                          );
                        }
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        
        widget.child ?? SizedBox()

      ],
    );
  }
}