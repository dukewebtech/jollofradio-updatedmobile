import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/services/controllers/User/PlaylistController.dart';
import 'package:jollofradio/config/services/controllers/User/StreamController.dart';
import 'package:jollofradio/config/services/controllers/HomeController.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/colors.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/scope.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Shared.dart';
import 'package:jollofradio/widget/Slider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

class PlayerScreen extends StatefulWidget {
  final Episode track;
  final String channel;
  final List? playlist;

  const PlayerScreen({
    super.key,
    required this.track,
    required this.channel,
    this.playlist
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> 
with SingleTickerProviderStateMixin {
  bool isLoading = true;
  late AnimationController _controller;
  ColorTween? _colorTween;
  Animation<Color?>? _colorTweenAnimation;
  Color defaultColor = AppColor.primary;

  AudioServiceHandler player = AudioServiceHandler();
  dynamic user;
  late bool loggedIn = false;
  Podcast? podcast;
  late Episode track;
  late String channel;
  late List? playlist;
  int currentIndex = 0;
  List<MediaItem> tracks = [];
  bool _fav = false;
  bool consent = false;

  TextEditingController controller = TextEditingController();
  bool isSaving = false;
  bool showCreate = false;
  dynamic _setState;
  String? selectedLabel;
  List<String> dropdown = [];

  @override
  void initState() {
    channel = widget.channel;       ///////////////////////
    track = widget.track;
    playlist = widget.playlist;
    _fav = track.liked;

    (() async {
      user = await auth();
      if(user == null){
        setState(() {
         isLoading = false; 
        });
      }

      if(await auth() != null && await isCreator()==false){
        loggedIn = true;
        List playlist = user[
          'playlist'
        ] as List;
        dropdown = playlist.map<String>( (e) => e['name'] )
        .toList();
      }
    })();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this
    );

    Future.delayed(
      Duration(seconds: 1), () => { ///////////////////////
      getEffects()
    });

    getPodcast();
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

  MediaItem setTrackItems(Episode track) {
    return MediaItem(
      id: track.id.toString(),
      title: track.title,
      album: track.podcast,
      artist: track.creator?.username() ?? '', //null check
      artUri: Uri.parse(track.logo),
      duration: Duration(),
      extras: {
        "url": track.source,
        "episode": track.toJson()
      }
    );
  }

  Future initializeAudio() async {
    MediaItem? currentTrack = player.currentTrack(); //////
    final playlist = player.getPlaylist() ;

    //set playlist
    // /*
    if(widget.playlist != null){
      Storage.set(
        'podcasts',jsonEncode(widget.playlist ?? <int>[])
      );
    }
    // */

    //transforming
    if(widget.playlist == null){
      tracks.add(setTrackItems(track));
    }
    else{
      var newTracks = widget.playlist!.map((dynamic item) {
        return setTrackItems(
          item
        );
      }).toList();
      tracks = ( newTracks );
    }
    
    /*
    if(podcast != track.podcast || podcast == track.podcast 
    && playlist.length == 1 
    && currentTrack?.title !=track.title) {
    */
    currentIndex = tracks.indexWhere( (i)=> // fetch index!
    i.id == track.id.toString());

    setState(() {
      //
    });
    
    bool onTrack = tracks.every((element) {
      //
      /*
      return playlist.any(
        (e) => e.id == element.id) == true; // check tracks
      */
      return playlist.any((e){
        return 
        e.id == element.id 
        && ( e.extras!['url'] == element.extras!['url'] ) ;
      });
      //
    });

    if((!onTrack || onTrack == false)){
      //fire loader UI
      /*
      setState(() => isLoading = true) ; // inform UI state
      */

      //mount playlist
      await player.stop();
      await player.setPlaylist(tracks);

      await player.skipToQueueItem (    //skip to the track
        currentIndex
      );
      player.play();

      /*
      await player.setPlaylist([
        MediaItem(
          id: track.id.toString(),
          title: track.title,
          album: track.podcast,
          artist: track.creator?.username() ?? '', //: null
          artUri: Uri.parse(track.logo),
          duration: Duration(),
          extras: {
            "url": track.source,
            "episode": track.toJson()
          }
        )
      ]);
      */
    }
    else{
      if(currentTrack?.title != track.title){
        if(playlist.length > 1){
          int index = playlist.indexWhere(
            (media) => media.id == track.id.toString (   ) 
          );

          if(index >= 0){
            await player.skipToQueueItem(
              index
            );
            player.play();
          }
        }
      }
    }

    //trackng stream
    if(currentTrack?.title != track.title ) {

      stream(track);
    
    }

    player.streams().listen((dynamic event) {
      final MediaItem? currentTrack = player.currentTrack();
      if(mounted) {
        setState(() {
          track = Episode.fromJson(
            currentTrack?.extras!['episode']
          );

          currentIndex = tracks.indexOf(
            currentTrack!
          );
        });
      }
    });
  }

  Future stream(Episode track) async {
    if(!await isCreator())
    await Storage.get('guest',bool).then((dynamic guest){
      
      if(guest == true){
        
        HomeController.stream({'episode_id':  track.id});

      }
      else{
        
        StreamController.create({'episode_id': track.id});

      }
    });
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

      stream(track);
      
      currentIndex = tracks.indexOf(media);//set cur. index
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

      return currentIndex != 0; //checks if index not first
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

  void callback(Map args /* ={} */) {
    _setState = args['state'];

    if(args['label'] != null) {
      selectedLabel = args['label'];
    }
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

  Future<void> getPodcast() async {
    int id = track.podcastId;

    await PlaylistController.show(id).then((playlist)async{
      if(playlist != null){
        var episode = playlist.episodes?.firstWhere(( e ) {

          return e.id == track.id;
          
        }, orElse: () => track);

        setState(() {
          podcast = playlist;
          // track = episode!; //prevent rebuild & flicker
          _fav = episode!.liked;
          isLoading = false;
        });
      }
    });
  }

  Future<void> _savePlaylist() async {
    if(isSaving) return;
    setState(() {
      isSaving = true;
    });

    final name = selectedLabel ?? controller.text.trim();
    Map data = {
      'playlist_name': name,
      'episode_id': track.id
    };

    if(selectedLabel == null 
    && name.isEmpty){
      setState(() => isSaving = false);
      Toaster.error("You have not selected a playlist");
      return;
    }

    await PlaylistController.create(data).then((created) 
    async{
      setState(() => isSaving = false);
      if(!created){
        Toaster.error(
          "Oops! while saving playlist, please try again"
        );
      }
      Toaster.success("Episode added to playlist: $name");

      controller.clear();
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () => Navigator.of(context).pop(),
      minRadius: 0,
      maxRadius: 0,
      dragSensitivity: 1.0,
      maxTransformValue: .8,
      direction: DismissiblePageDismissDirection.down,
      backgroundColor: _colorTweenAnimation == (null) 
        ? defaultColor : _colorTweenAnimation!.value!,
      
      // dismissThresholds: {
      //   DismissiblePageDismissDirection.down: .2,
      // },

      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: _colorTweenAnimation == (null) ? 
            defaultColor
            : _colorTweenAnimation!.value,
            appBar: AppBar(
              leading: Buttons.back(),
              actions: [
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: isLoading ? 
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    )
                  )
                  : IconButton(
                    onPressed: () async => showMoreOptions(), 
                    icon: Icon(Iconsax.more)
                  ),
                )
              ],
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
                          SizedBox(height: 10),
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
                                    return Image.asset(
                                      'assets/images/loader.png',
                                      fit: BoxFit.cover,
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
                                      child: GestureDetector(
                                      onTap: () {
                                        if(podcast == null){
                                          Toaster.error(
                                            "Fail to load the podcast at the moment!"
                                          );
                                          return;
                                        }

                                        RouteGenerator.goto(PODCAST, {
                                          "podcast": podcast
                                        });
                                      },
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
                                                maxLines: 2,
                                              ),
                                            ),
                                            Labels.secondary(
                                              track.podcast,
                                            ),
                                          ],
                                        ),
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
      ),
    );
  }

  Future showMoreOptions() async {
    return showModalBottomSheet(
      context: context,
        builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: 200
          ),
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if(loggedIn)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                minLeadingWidth: 10,
                leading: Icon(
                  !_fav ? 
                  Iconsax.heart : Iconsax.heart5,
                  size: 14,
                  color: !_fav 
                         ? Colors.grey : AppColor.secondary,  //////////////
                ),
                title: Text(
                  !_fav ? "Like" : "Unlike",
                  style: TextStyle(
                    fontSize: 14
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _doSubscribe();
                },
              ),
              if(loggedIn)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                minLeadingWidth: 10,
                leading: const Icon(Iconsax.music, size: 14), //////////////
                title: Text(
                  "Add to Playlist",
                  style: TextStyle(
                    fontSize: 14
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  playlistModal(
                    context: context,
                    label: selectedLabel,
                    playlist: dropdown,
                    controller: controller,
                    fn: _savePlaylist,
                    callback: callback
                  );
                }
              ),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                minLeadingWidth: 10,
                leading: const Icon(Icons.share, size: 14),   //////////////
                title: Text(
                  "Share",
                  style: TextStyle(
                    fontSize: 14
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await Share.share(
                    shareLink(type: 'episode', data: track)  //////////////
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> safetyDialog() async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            if(!consent){
              Future((){
                RouteGenerator.goBack(); // reject call to invoke playback
              });
            }
            return true;
          },
          child: AlertDialog(
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
                Text("To turn off this warning - goto your profile set${""
                  }tings and enable 'Explicit Content'",
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
                  consent = true;
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
                  "Cancel", style: const TextStyle(color: Colors.black) ,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}