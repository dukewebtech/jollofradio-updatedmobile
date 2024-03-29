import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/User/PlaylistController.dart';
import 'package:jollofradio/config/services/controllers/User/SubscriptionController.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Podcast.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/utils/scope.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

class EpisodeScreen extends StatefulWidget {
  final Podcast podcast;
  const EpisodeScreen({super.key, required this.podcast});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  late Podcast podcast;
  late ConfettiController confettiController;
  AudioServiceHandler player = AudioServiceHandler();
  PlaybackState? playerState;
  bool isLoading = true;
  bool _fav = false;
  List<MediaItem> tracks = [];
  MediaItem? currentTrack;
  List<Episode> episodes = [];

  @override
  void initState() {
    super.initState();
    podcast = widget.podcast;
    _fav = podcast.subscribed;
    confettiController = ConfettiController(duration: Duration(
      seconds: 1
    ));

    getPlaylist();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  Future<void> initPlayer() async {
    audioHandler.playbackState.listen((PlaybackState state) {
      var track = player.currentTrack(); //updating new track
      if( track != currentTrack){
        if(mounted)
        setState(() {
          currentTrack = track;
        });
      }

      if(state.processingState 
      != playerState?.processingState){

        playerState = state;
        /*
        Toaster.info("Audio state remounted! tracking ttl.");
        */
        if(mounted) {
          setState(() {});
        }
        
      }
    });
  }

  bool onTrack(Episode episode) {
    String episodeId = episode.id.toString();//fetch track id

    if(currentTrack?.id == episodeId){
      if(playerState?.playing == true){
        return true;
      }
    }
    return false;
  }

  Future<void> getPlaylist() async {
    int id = podcast.id;

    await PlaylistController.show(id).then((playlist) async {
      if(playlist != null){
        setState(() {
          podcast = playlist;
          episodes = playlist.episodes!;
          isLoading = false;
        });

        Future.delayed(
          Duration(seconds: 0), () {
            initPlayer();
          }
        );

        /*
        episodes = playlist.episodes!.map<Episode>((episode){
          return episode;
        }).toList();
        */
      }
    });
  }

  Future<void> playPodcast() async {
    if(podcast.episodes!.isEmpty) 
      return;
    
    /*
    @deprecated
    var podcast = currentTrack?.extras?['episode']?['podcast'];
    if(podcast != playlist.title){
    */
    final playlist = player.getPlaylist() ;
    podcast.episodes!.map( (dynamic item) {
      item = MediaItem(
        id: item.id.toString(),
        title: item.title,
        album: item.podcast,
        artist: item.creator?.username() ?? '', //null check
        artUri: Uri.parse(item.logo),
        extras: {
          "url": item.source,
          "episode": item.toJson()
        }
      );
      tracks.add(item);
    }).toList();

    bool onTrack = tracks.every((element) {
      //
      return playlist.any(
        (e) => e.id == element.id) == true; // check tracks
      //
    });

    if((!onTrack || onTrack == false)){
      Storage.set(
        'podcasts',jsonEncode(podcast.episodes ?? < int >[])
      );

      await player.stop();
      await player.setPlaylist(tracks);
      player.play();
    }
    else{
      if(!player.isPlaying())
        player.play();
      
      else 
        player.pause();

        ////////////////////////////////////////////////////
    }
  }

  Future<void> _doSubscribe() async {
    bool subscribing = !_fav;
    Map data = {
      'podcast_id': podcast.id
    };

    if(await auth() == null){
      return Toaster.info(
        "You need to sign in to subscribe to this podcast. "
      );
    }

    setState(() {
      _fav = !_fav;
    });

    if(subscribing){
      confettiController.play();
      await SubscriptionController.create(data).then((status){
        if(!status){
          setState(() => _fav = !_fav);
          return;
        }
        Toaster.info(
          "You've subscribed to podcast: ${ podcast.title }"
        );
      });
    }
    if(!subscribing){    
      await SubscriptionController.delete(data).then((status){
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        margin: EdgeInsets.only(bottom: 20),
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
                        child: isLoading ? 
                        Image.asset(
                          'assets/images/loader.png',
                          fit: BoxFit.cover,
                        ) :
                        CachedNetworkImage(
                          memCacheWidth: 300,
                          memCacheHeight: 200,
                          imageUrl: podcast.logo,
                          placeholder: (context, url) {
                            return Image.asset(
                              'assets/images/loader.png',
                              fit: BoxFit.cover,
                              cacheWidth: 300,
                              cacheHeight: 200,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Labels.primary(
                            podcast.title,
                             maxLines: 2,
                            fontSize: 18,
                            margin: EdgeInsets.only(bottom: 5)
                          ),
                          Text.rich(
                            TextSpan(
                              text: "by ",
                              children: <InlineSpan>[
                                TextSpan(
                                  text: podcast
                                    .creator?.username() ?? 'Jollof Radio',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.secondary.withOpacity(
                                      0.8
                                    )
                                  ),
                                  recognizer: 
                                  TapGestureRecognizer()
                                  ..onTap = (){
                                    if((podcast.creator == null) == true)
                                      return;

                                    RouteGenerator.goto(CREATOR_PROFILE, {
                                      "creator": podcast.creator,
                                    }); 
                                  },
                                )
                              ],
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0XFFBBBBBB)
                              ),
                            )
                          ),
                          SizedBox(height: 20),
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
                                  Container(
                                    width: 160,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50)
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: !_fav ? 
                                    ElevatedButton.icon(
                                      onPressed: () => _doSubscribe(), 
                                      icon: Icon(
                                        Iconsax.notification,
                                        size: 16,
                                        color: AppColor.secondary,
                                      ),
                                      label: Text(
                                        "Susbscribe", style: TextStyle(
                                          color: AppColor.secondary
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 1,
                                            color: AppColor.secondary
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            50
                                          )
                                        ),
                                        backgroundColor: Colors.transparent
                                      ),
                                    )
                                    :
                                    ElevatedButton.icon(
                                      onPressed: () => _doSubscribe(), 
                                      icon: Icon(
                                        Iconsax.notification,
                                        size: 16,
                                        color: AppColor.primary,
                                      ),
                                      label: Text(
                                        "Susbscribed", style: TextStyle(
                                          color: AppColor.primary
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.secondary
                                      ),
                                    )
                                    ,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 105,
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  /*
                                  GestureDetector(
                                    onTap: () => _doSubscribe(),
                                    child: !_fav ? Icon(
                                      Iconsax.notification, 
                                      color: Color(0XFF575C5F),
                                      size: 18,
                                    ) : Icon(
                                      Iconsax.notification5,
                                      color: AppColor.secondary,
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                    child: ConfettiWidget(
                                      confettiController: confettiController,
                                      shouldLoop: false,
                                      blastDirectionality: BlastDirectionality.explosive,
                                      maximumSize: Size(5, 5),
                                      minimumSize: Size(5, 5),
                                      maxBlastForce: 5,
                                      minBlastForce: 1,
                                      emissionFrequency: 0.02,
                                      numberOfParticles: 10,                            
                                      gravity: 1,
                                    ),
                                  ),
                                  */
                                  Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: podcast.episodes!.isEmpty==true ? 
                                      Color(0XFF0D1921) : AppColor.secondary,
                                      borderRadius: BorderRadius.circular(100)
                                    ),
                                    child: StreamBuilder<Map>(
                                      stream: player.streams(),
                                      builder: (context, snapshot) {
                                        final state = snapshot.data?['playState'];
                                        bool playing = state?.playing ?? false;
                                        var processingState = state?.processingState;
                                        if(
                                          playing == true && currentTrack?.extras?
                                          ['episode']?['podcast'] != podcast.title) {
                                            playing = false;
                                            processingState = ProcessingState.ready;
                                        }

                                        List loading = [
                                          ProcessingState.loading,
                                          ProcessingState.buffering,
                                        ];

                                        if(loading.contains(processingState) == true 
                                        || isLoading){
                                          return Center(
                                            child: SizedBox(
                                              width: 15,
                                              height: 15,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: podcast.episodes!.isEmpty ? 
                                                AppColor.secondary : AppColor.primary
                                              )
                                            ),
                                          );
                                        }

                                        return IconButton(
                                          padding: EdgeInsets.all(2.5),
                                          tooltip: playing == false ? 'Play' : 'Pause',
                                          onPressed:()=> playPodcast(),
                                          icon: Icon(
                                            !playing ? Icons.play_arrow : Icons.pause,
                                            color: podcast.episodes!
                                            .isEmpty ? Colors.white : Colors.black,
                                            size: 20,
                                          ),
                                        );
                                      }
                                    )
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  GestureDetector(
                                    onTap: () async{
                                      await Share.share(
                                        shareLink(
                                          type: 'podcast', data: podcast
                                        )
                                      );
                                    },
                                    child: Icon(
                                      FontAwesomeIcons.share, 
                                      color: Color(0XFF575C5F),
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
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