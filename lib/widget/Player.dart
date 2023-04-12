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
import 'package:jollofradio/utils/colors.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:just_audio/just_audio.dart';

class Player extends StatefulWidget {
  final Widget child;
  const Player({ Key? key, required this.child }) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  Color trackColor = AppColor.primary;
  final AudioServiceHandler player = AudioServiceHandler();
  bool isPlaying = false;
  bool isVisible = false;
  ProcessingState? state;
  dynamic track;
  String title = "-";
  String subtitle = "-";
  Map route = {
    "name": TRACK_PLAYER,
    "track": null,
    "cahnnel": null
  };

  @override
  void initState() {
    initPlayer ();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  void initPlayer() {
    //get last track
    Storage.get('lastTrack',Map).then((item)async {
      if(item == null || item == false)
        return;

      final track = item['track'];
      bool isPodcast = track.containsKey('episode');

      await player.setPlaylist([MediaItem(
        id: track['id'],
        title: track['title'],
        album: track['album'],
        artist: track['artist'],
        artUri: Uri.parse(track['artUri']),
        duration: Duration(
          milliseconds: isPodcast 
          ? track['duration']:0
        ),
        extras: track['extras'],
      )]);

      player.seek(
        Duration(
          milliseconds: track['position']
        )
      );
    });

    //fetch & store
    player.streams().listen((dynamic event) async {
      final playState = event['playState'];
      state = playState.processingState;

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
        // print('color effect executed!');

        trackColor = AppColor.primary;
        Colorly().from('network').get(track?.logo)
        .then((color){
          trackColor = 
          color?['primary'] ?? AppColor.primary;
        });
      }
            
      if(mounted)
      setState(() {
        isVisible = state != ProcessingState.idle;
        isPlaying = playState.playing;
        this.track = track;
      });

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
      
      Timer(Duration(seconds: 1), () =>{
        // print('storage api executed!'),
        
        if(isPlaying)
        Storage.set(
          'lastTrack', jsonEncode(media) // saving...
        )
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Visibility(
          visible: isVisible,
          child: GestureDetector(
            onTap: () {
              RouteGenerator.goto(route['name'], <String, dynamic> {
                ...route
              });
            },
            child: Dismissible(
              key: UniqueKey(),
              confirmDismiss: (direction) async {
                await player.stop();
                await Storage.delete('lastTrack');
                return true;
              },
              onDismissed: (DismissDirection direction) {
                // do nothing!
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
                      Container(
                        width: 60,
                        height: 50,
                        color: Color(0XFF0D1921),
                        margin: EdgeInsets.only(right: 10),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          height: double.infinity,
                          imageUrl: track?.logo ?? '-',
                          placeholder: (context, url) {
                            return Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator()
                              )
                            );
                          },
                          errorWidget: (context, url, error) =>  Icon(
                            Icons.error
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
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
                      Container(
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.primary,
                            )
                          ),
                        ) :
                        IconButton(
                          onPressed: () {
                            if(state == ( ProcessingState.buffering ) )
                              return;

                            !isPlaying ? player.play() : player.pause();
                          },
                          icon: Icon(!isPlaying 
                            ? Icons.play_arrow : Icons.pause, size: 18,
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        widget.child

      ],
    );
  }
}