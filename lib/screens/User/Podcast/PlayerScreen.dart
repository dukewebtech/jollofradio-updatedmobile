import 'dart:async';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/services/controllers/User/StreamController.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/utils/colors.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Slider.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  final Episode track;
  final String channel;

  const PlayerScreen({
    super.key,
    required this.track,
    required this.channel
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> 
with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ColorTween? _colorTween;
  Animation<Color?>? _colorTweenAnimation;
  Color defaultColor = AppColor.primary;

  AudioServiceHandler player = AudioServiceHandler();
  late Episode track;
  late String channel;
  bool _fav = false;

  @override
  void initState() {
    channel = widget.channel;       ///////////////////////
    track = widget.track;
    _fav = track.liked;

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this
    );

    Future.delayed(
      Duration(seconds: 1), () => { ///////////////////////
      getEffects()
    });

    _verifyPlayback();

    super.initState();
  }

  Future<void> getEffects() async {
    var logo = track.logo;
    Colorly().fromNetwork().get(logo).then((colors) async {
      _colorTween = ColorTween(
        begin: defaultColor, 
        end: colors['primary']
      );

      _colorTweenAnimation = _colorTween!.animate(  //////
        CurvedAnimation(
            parent: _controller, 
            curve: Curves.easeIn
          )
      )..addListener(() {
        setState(() {});
      });

      _controller.forward();

    });////////////////////////////////////////////////////
  }

  Future<void> _verifyPlayback() async {
    //context wait
    await Future.delayed(const Duration(milliseconds:500));

    //get the user
    final user = await Storage.get(
      'user', Map
    );

    //check safety
    bool explicitContent = track.meta ['explicit_content'];

    //public users
    if(user == null)
      return initializeAudio();


    if(explicitContent){
      bool enabled = user['settings']?['explicit_content'] 
      ?? false;

      if(!enabled){
        if(player.currentTrack()?.title == (track.title)){
          return;
          
        }

        return safetyDialog();

      }
    }
    initializeAudio(); ////////////////////////////////////

  }

  Future initializeAudio() async {
    MediaItem? currentTrack = player.currentTrack(); //////
    var podcast = "";
    bool isPodcast = 
    currentTrack?.extras?.containsKey('episode') ?? false ;

    if(isPodcast){
      podcast = currentTrack?.extras?['episode']['podcast'];
    }
    final playlist = player.getPlaylist( ) ;
    
    if(podcast != track.podcast || podcast == track.podcast 
    && playlist.length == 1 
    && currentTrack?.title != track.title) {
      //fire loading
      /*
      setState(() => isLoading = true) ; // inform UI state
      */

      //mount playlist      
      await player.setPlaylist([
        MediaItem(
          id: track.id.toString(),
          title: track.title,
          album: track.podcast,
          artist: track.creator.username(),
          artUri: Uri.parse(track.logo),
          duration: Duration(),
          extras: {
            "url": track.source,
            "episode": track.toJson()
          }
        )
      ]);

      player.play();

      //track stream
      StreamController.create ({ 'episode_id': track.id });
      //
    }

    if(podcast == track.podcast) {
      if(currentTrack?.title != track.title){
        if(playlist.length > 1){
          int index = playlist.indexWhere(
            (media) => media.id == track.id.toString (   ) 
          );

          if(index >= 0){
            player.skipToQueueItem(
              index
            );
          }
        }
      }
    }

    player.streams().listen((dynamic event) {
      final MediaItem? currentTrack = player.currentTrack();
      if(mounted) {
        setState(() {
          track = Episode.fromJson(
            currentTrack?.extras!['episode']
          );     
        });
      }
    });
    
    ///////////////////////////////////////////////////////
  }

  Future skipTrack(mode) async {
    late MediaItem media;

    if(mode == 'prev'){
      if(!canSkip('prev')) 
        return;

      media = player.previousTrack();
      player.skipToPrevious();
    }
    if(mode == 'next'){
      if(!canSkip('next')) 
        return;

      media = player.nextTrack();
      player.skipToNext();
    }

    setState(() {
      track = Episode.fromJson(
        media.extras!['episode']
      );     
    });
  }

  bool canSkip(String mode) {
    final playlist = player.getPlaylist(); //total playlist
    String id = track.id.toString();
    int first = 0;
    int last = playlist.length - 1 ;
    
    if(mode == 'prev') {
      if(!playlist.asMap(  ).containsKey(
        first
      ))
        return false;

      return ( playlist[first] != player.currentTrack( ) );
    } 
    if(mode == 'next') {
      if(!playlist.asMap(  ).containsKey(
        last
      ))
        return false;

      return ( playlist[last ] != player.currentTrack( ) );
    }
    return false;
  }

  Future<void> _doSubscribe() async {
    bool liked = !_fav;
    Map data = {
      'episode_id': track.id
    };

    setState(() {
      _fav = !_fav;
    });

    await StreamController.engage(data).then((status)async{
      if(liked && !status){
        setState(() => _fav = !_fav);
      }
    });    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: _colorTweenAnimation == (null) ? 
          defaultColor
          : _colorTweenAnimation!.value,
          appBar: AppBar(
            leading: Buttons.back(),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, 
                end: Alignment.bottomCenter, 
                colors: [
                  Colors.transparent, 
                  Color.fromRGBO(0, 0, 0, .1), 
                  Color.fromRGBO(0, 0, 0, .5)
                ], 
                stops: [0.0, 0.1, 0.8]
              ),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
              margin: EdgeInsets.only(
                top: 00,
                left: 20, 
                right: 20
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 320,
                          decoration: BoxDecoration(
                            color: Color(0XFF0D1921),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              CachedNetworkImage(
                                imageUrl: track.logo,
                                placeholder: (context, url) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator()
                                    )
                                  );
                                },
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error
                                ),
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: StreamBuilder<Map>(
                            stream: player.streams(),
                            builder: (context, snapshot) {
                              final streams = snapshot.data ?? <String, Duration>{
                                'duration': Duration(milliseconds: 1000),
                                'position': Duration(),
                              };
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 90,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          constraints: BoxConstraints(
                                            maxHeight: 60
                                          ),
                                          child: Labels.primary(
                                            track.title,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            maxLines: 2
                                          ),
                                        ),
                                        Labels.secondary(
                                          track.podcast
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Stack(
                                    fit: StackFit.loose,
                                    children: [
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 2,
                                          overlayShape: SliderComponentShape.noOverlay,
                                          trackShape: CustomTrackShape(),
                                          activeTrackColor: AppColor.secondary,
                                          inactiveTrackColor: Colors.white24,
                                        ),
                                        child: Slider(  
                                          min: 0,  
                                          max: 
                                          streams['duration'].inMilliseconds.toDouble(),  
                                          value: min(
                                            streams[
                                              'position'
                                            ].inMilliseconds.toDouble(), 
                                            streams[
                                              'duration'
                                            ].inMilliseconds.toDouble()
                                          ),
                                          thumbColor: Colors.white,
                                          onChanged: (value) async {
                                            await player.seek(
                                              Duration(  milliseconds: value.round()  )
                                            ); 
                                            player.play();
                                          },  
                                        )
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: 
                                       MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        formatTime(
                                          streams['position']
                                        ), 
                                        style: TextStyle(fontSize: 12)
                                      ),
                                      Text(
                                        formatTime(
                                          streams['duration']
                                        ), 
                                        style: TextStyle(fontSize: 12)
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 50),
                                ],
                              );
                            }
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      StreamBuilder<Map>(
                        stream: player.streams(),
                        builder: (context, snapshot) {
                          final stream = snapshot.data?['loopMode'] 
                          ?? LoopMode.off;

                          final repeatMode = {
                            LoopMode.off: {
                              "task" : AudioServiceRepeatMode.all,
                              "label": "Repeat All"
                            },
                            LoopMode.all: {
                              "task" : AudioServiceRepeatMode.one,
                              "label": "Repeat One"
                            },
                            LoopMode.one: {
                              "task" : AudioServiceRepeatMode.none,
                              "label": "Repeat Off"
                            },
                          };

                          final repeatIcon = {
                            LoopMode.all: Icon(
                              Iconsax.repeat, color: Colors.white
                            ),
                            LoopMode.one: Icon(
                              Icons.repeat_one, color: Colors.white
                            ),
                            LoopMode.off: Icon(
                              Iconsax.repeat, color: Colors.white54
                            ),
                          }[stream]!;

                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(), //edge patch
                            tooltip: "Repeat",
                            onPressed: () {
                              player.setRepeatMode(
                                repeatMode[stream]!['task']! 
                                as AudioServiceRepeatMode 
                              );
                              Toaster.info(
                                repeatMode[stream]!['label'].toString()
                              );
                            },
                            icon: repeatIcon,
                          );
                        }
                      ),
                      StreamBuilder<Map>(
                        stream: player.streams(),
                        builder: (context, snapshot) {
                          return IconButton(
                            tooltip: "Previous Track",
                            onPressed: () async => await skipTrack('prev'),
                            icon: Icon(
                              Iconsax.backward,
                              color: 
                              canSkip('prev') ? Colors.white : Colors.grey,
                            ),
                          );
                        }
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          borderRadius: /* */ BorderRadius.circular(100)
                        ),
                        child: StreamBuilder<Map>(
                          stream: player.streams(),
                          builder: (context, snapshot) {
                            final state = snapshot.data?['playState'];
                            final playing = state?.playing ?? false;
                            final processingState = state?.processingState 
                            ?? ProcessingState.loading;

                            List loading = [
                              ProcessingState.loading,
                              ProcessingState.buffering,
                            ];

                            if(loading.contains(processingState) == true){
                              return Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: AppColor.primary,
                                  )
                                ),
                              );
                            }

                            return IconButton(
                              tooltip: playing == false ? 'Play' : 'Pause',
                              onPressed: () {
                                setState(() {
                                  if( !playing ){
                                    player.play ();
                                  }
                                  else{
                                    player.pause();
                                  }                                  
                                });
                              },
                              icon: Icon(
                                !playing ? Icons.play_arrow : Icons.pause,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                      StreamBuilder<Map>(
                        stream: player.streams(),
                        builder: (context, snapshot) {
                          return IconButton(
                            tooltip: "Forward Track",
                            onPressed: () async => await skipTrack('next'),
                            icon: Icon(
                              Iconsax.forward,
                              color: 
                              canSkip('next') ? Colors.white : Colors.grey,
                            ),
                          );
                        }
                      ),
                      StreamBuilder<Map>(
                        stream: player.streams(),
                        builder: (context, snapshot) {
                          final stream = snapshot.data?['shuffleMode'] 
                          ?? false;

                          final shuffleMode = {
                            true: {
                              "task" : AudioServiceShuffleMode.none,
                              "label": "Shuffle Off"
                            },
                            false: {
                              "task" : AudioServiceShuffleMode.all ,
                              "label": "Shuffle On"
                            },
                          };

                          final shuffleIcon = {
                            true: Icon(
                              Iconsax.shuffle, color: (Colors.white)
                            ),
                            false: Icon(
                              Iconsax.shuffle, color: (Colors.grey )
                            ),
                          }[stream]!;

                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(), //edge patch
                            tooltip: "Shuffle",
                            onPressed: () {
                              player.setShuffleMode(
                                shuffleMode[stream]!['task']! 
                                as AudioServiceShuffleMode 
                              );
                              Toaster.info(
                                shuffleMode[stream]!['label'].toString()
                              );
                            },
                            icon: shuffleIcon,
                          );
                        }
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Future<void> safetyDialog() async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Heads up!", style: /**/TextStyle(
            color: Colors.red,
            fontSize: 15,
            fontWeight: FontWeight.bold
          )),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "This podcast might contains explicit content, hard ${""
                }language or unappeali${
                    ""
                  }ng materials.",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text("To turn off this warning - goto profile settings ${
                  ""
                }and enable 'Explicit Content'",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent
              ),
              onPressed: () {
                Navigator.pop(context);
                initializeAudio();
              },
              child: Text("Continue playback", style:/**/ TextStyle()),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent
              ),
              onPressed: () {
                RouteGenerator.goBack(2);
              },
              child: Text(
                "Cancel", style: const TextStyle(color: Colors.black)
              ),
            )
          ],
        );
      },
    );
  }
}