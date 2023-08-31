import 'dart:async';
import 'dart:convert';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jollofradio/config/models/Station.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/utils/colors.dart';
import 'package:jollofradio/config/services/controllers/StationController.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Slider.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher_string.dart';

class StreamScreen extends StatefulWidget {
  final Station radio;
  final String channel;

  const StreamScreen({
    super.key,
    required this.radio,
    required this.channel
  });

  @override
  State<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> 
with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ColorTween? _colorTween;
  Animation<Color?>? _colorTweenAnimation;
  Color defaultColor = AppColor.primary;

  AudioServiceHandler player = AudioServiceHandler();
  CacheStream cacheManager = CacheStream();
  late Station radio;
  late String channel;
  bool _tuning = false;
  bool _fav = false;
  late dynamic stations;

  @override
  void initState() {
    channel = widget.channel;       ///////////////////////
    radio = widget.radio;

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this
    );

    Future.delayed(
      Duration(seconds: 1), () => { ///////////////////////
      getEffects()
    });

    syncAllStations();
    initializeRadio();

    super.initState();
  }

  Future<void> getEffects() async {
    var logo = radio.logo;
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

  Future<dynamic> getFavorites() async {
    
    //favorites
    await Storage.get('favRadio',Map).then((stations)/**/ {
      if(stations == null)
        return;

      _fav = stations.any((item){
        return item['title'] == radio.title;
      });

      setState(() { });  
    });

  }

  Future<dynamic> syncAllStations() async {

    final stations = await cacheManager.stream( ///////////
      'stations', 
      fallback: () async {
        return StationController.index();
      },
      callback: StationController.construct
    );

    this.stations = [
      ...stations['local'], 
      ...stations['international'],
    ];

  }

  Future initializeRadio() async {
    MediaItem? currentTrack = player.currentTrack(); //////
    var station = "";
    bool isRadio = 
    currentTrack?.extras?.containsKey('station') ?? false ;

    if(isRadio){
      station = currentTrack?.extras? ['station']['title'];
    }
    
    if(!isRadio || station != radio.title) {
      //fire loader UI
      /*
      setState(() => isLoading = true) ; // inform UI state
      */

      //mount playlist
      await player.stop();
      await player.setPlaylist([
        MediaItem(
          id: radio.id.toString(),
          title: radio.title,
          album: radio.signal(),
          artist: radio.signal(),
          artUri: Uri.parse(radio.logo),
          duration: Duration(),
          extras: {
            "url": radio.link,
            "station": radio.toJson()
          }
        )
      ]);

      player.play();

      setState(() {
        _tuning = false;
      });
    }

    player.streams().listen((dynamic event) {
      final MediaItem? currentTrack = player.currentTrack();
      if(mounted) {
        setState(() {
          if(_tuning) return;
          radio = Station.fromJson(
            currentTrack?.extras!['station']
          );     
        });
      }
    });

    getFavorites();
    
    ///////////////////////////////////////////////////////
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
                                  imageUrl: radio.logo,
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
                                  'duration': Duration(),
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
                                              radio.title,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              maxLines: 2
                                            ),
                                          ),
                                          Labels.secondary(
                                            radio.signal()
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
                                            thumbShape: SliderComponentShape.noThumb,
                                          ),
                                          child: Slider(  
                                            min: 0,
                                            max: 100,
                                            value: 0,
                                            thumbColor: Colors.white,
                                            onChanged: (value) {
                                              // player.seek(
                                              //   Duration(milliseconds: value.round())
                                              // );
                                            },  
                                          )
                                        ),
                                      ],
                                    ),
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
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(), //edge patch
                          tooltip: "Twitter",
                          onPressed: () async {
                            final twitter = radio.social ( 'twitter' );
                            if(twitter == null)
                              return;

                            await launchUrl(
                              Uri.parse(twitter),
                              mode: 
                              LaunchMode.externalNonBrowserApplication
                            );
                          },
                          icon: Icon(
                            FontAwesomeIcons.twitter, 
                            color: radio.social('twitter') == ( null )
                            ? Colors.grey : Colors.white
                          ),
                        ),
                        IconButton(
                          tooltip: "Favorite",
                          onPressed: () async {
                            var stations = await Storage.get('favRadio',Map);
                            stations = stations ?? [];

                            if(!_fav){

                              stations.add(radio.toJson());

                            }
                            else{

                              stations.removeWhere((item){

                                return item['title'] == radio.title; //flush

                              });

                            }

                            Storage.set(
                              'favRadio',jsonEncode(stations)
                            );
                            setState(() {
                              _fav = !_fav;
                            });
                          },
                          icon: Icon(
                            !_fav ? Iconsax.heart : Iconsax.heart5, 
                            color: !_fav ? Colors.white : AppColor.secondary
                          ),
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
                        IconButton(
                          tooltip: "Tune Station",
                          onPressed: () {
                            if(stations != null && (stations is List)==true){
                              stations.shuffle();
                              setState(() {
                                _tuning = true;
                                radio = stations.first;
                                initializeRadio();
                              });
                            }
                          },
                          icon: Icon(
                            Iconsax.radar_1,
                            color: Colors.white
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(), ////////////////////
                          tooltip: "Share",
                          onPressed: () async {
                            await Share.share(
                              shareLink(type: 'station', data: radio) ///////
                            );
                          },
                          icon: Icon(
                            Icons.share, 
                            color: Colors.white
                          ),
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
}