import 'package:animate_do/animate_do.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/controllers/User/PlaylistController.dart';
import 'package:jollofradio/config/services/controllers/User/SubscriptionController.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Podcast.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

class EpisodeScreen extends StatefulWidget {
  final Podcast playlist;
  const EpisodeScreen({super.key, required this.playlist});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  late Podcast playlist;
  late ConfettiController confettiController;
  AudioServiceHandler player = AudioServiceHandler();
  late PlaybackState playerState;
  bool isLoading = true;
  bool _fav = false;
  MediaItem? currentTrack;

  @override
  void initState() {
    playlist = widget.playlist;
    _fav = playlist.subscribed;
    confettiController = ConfettiController(duration: Duration(
      seconds: 1
    ));

    initPlayer ();
    getPlaylist();

    super.initState();
  }

  @override
  void dispose() {
    confettiController.dispose();

    super.dispose();
  }

  Future<void> initPlayer() async {
    audioHandler.playbackState.listen((PlaybackState state) {

      currentTrack = player.currentTrack(); // updating track

    });
  }

  Future<void> getPlaylist() async {
    int id = playlist.id;

    await PlaylistController.show(id).then((playlist) async {
      if(playlist != null){
        setState(() {
          this.playlist = playlist;
          isLoading =  false;
        });
      }
    });
  }

  Future<void> playPodcast() async {
    var podcast = currentTrack?.extras?['episode']['podcast'];

    if(podcast != playlist.title){
      await player.setPlaylist(playlist.episodes.map((item) {

        return MediaItem(
          id: item.id.toString(),
          title: item.title,
          album: item.podcast,
          artist: item.creator.username(),
          artUri: Uri.parse(item.logo),
          extras: {
            "url": item.source,
            "episode": item.toJson()
          }
        );

      }).toList());

      player.play();
    }
    else{
      if(!player.isPlaying())
        player.play();
      
      else 
        player.pause();
      
    }
  }

  Future<void> _doSubscribe() async {
    bool subscribing = !_fav;
    Map data = {
      'podcast_id': playlist.id
    };

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
          "You've subscribed to podcast: ${ playlist.title }"
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
                child: CachedNetworkImage(
                  imageUrl: playlist.logo,
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
              Labels.primary(
                "About",
                fontSize: 18,
                margin: EdgeInsets.only(bottom: 5)
              ),
              Wrap(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      playlist.description ?? "No description currently ${
                        ""
                      }available on this podcast at the moment.", ////////
                      style: TextStyle(
                        color: Color(0XFFBBBBBB),
                        fontSize: 14
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if(textOverflow(
                    playlist.description ?? '',
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
                            title: Text(playlist.title, style: TextStyle(
                              color: AppColor.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            )),
                            content: Text(
                              playlist.description ?? '',
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
                            playlist.title, style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFFFFFFFF)
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "by ${playlist.creator.username()}", 
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0XFFBBBBBB)
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
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
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: playlist.episodes.isEmpty==true ? 
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
                                  ['episode']['podcast'] != playlist.title) {
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
                                        color: AppColor.primary,
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
                                    color: playlist.episodes
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
                                'Listen to: ${playlist.title} on Jollof Radio', 
                                subject: 'Listen to: ${
                                  playlist.title
                                } on Jollof Radio for FREE');
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
                    "${playlist.episodes.length} Episode(s)",
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
                    if(playlist.episodes.isEmpty)
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
                              ...playlist
                                .episodes.map((episode) => PodcastTemplate(
                                key: UniqueKey(),
                                type: 'list',
                                episode: episode,
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
    );
  }
}