import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:just_audio/just_audio.dart';

class Player extends StatefulWidget {
  final Widget child;
  const Player({ Key? key, required this.child }) : super(key: key);

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final AudioServiceHandler player = AudioServiceHandler();
  bool isPlaying = false;
  bool isVisible = false;
  ProcessingState? state;
  Episode? track;

  @override
  void initState() {
    initPlayer ();

    super.initState();
  }

  void initPlayer() {
    player.streams().listen((dynamic event) async {
      final playState = event['playState'];
      final currentTrack = (player.currentTrack( ));
      final podcast = currentTrack?.extras?['episode']; // get track
      state = playState.processingState;

      setState(() {
        isVisible = state != ProcessingState.idle;
        isPlaying = playState.playing;

        track = Episode
        .fromJson(
          podcast
        );
      });
      //////////////////////////////////////////////////////////////

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
              RouteGenerator.goto(TRACK_PLAYER, <String, dynamic> {
                'track': track,
                'channel':'podcast'
              });
            },
            child: Dismissible(
              key: UniqueKey(),
              confirmDismiss: (direction) async {
                await player.stop();
                return true;
              },
              onDismissed: (DismissDirection direction) {
                // do nothing!
                
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 60,
                color: AppColor.primary,
                padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
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
                            track?.title ?? '-',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            maxLines: 1,
                            margin: EdgeInsets.only(
                              top: 5,
                              bottom: 2
                            )
                          ),
                          Text(
                            track?.podcast ?? '',
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
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        color: AppColor.secondary,
                        borderRadius: BorderRadius.circular (100)
                      ),
                      child: state == ProcessingState.buffering ? 
                      Center(
                        child: SizedBox(
                          width: 10,
                          height: 10,
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
                          ? Icons.play_arrow : Icons.pause, size: 14,
                        )
                      ),
                    )
                  ],
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