import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/utils/colors.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';

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
  late ColorTween _colorTween;
  late Animation<Color?> _colorTweenAnimation;
  Color beginColor = Colors.transparent;
  Color endColor = AppColor.primary;

  late Episode track;
  late String channel;
  bool isLoading = false;
  bool isPlaying = false;
  bool _fav = false;
  dynamic currentTrack;
  double _seek = 2.0;
  String startPos = '0:00';
  String duration = '0:00';

  @override
  void initState() {
    channel = widget.channel;     /////////////////////////
    track = widget.track;

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this
    );

    _colorTween = ColorTween(
      begin: beginColor, end: endColor
    );

    _colorTweenAnimation = _colorTween.animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.easeIn //////
        )
    );

    _controller.forward();

    super.initState();
  }

  void paint(beginColor, endColor) {
    // setState(() {
      _colorTween = ColorTween(
        begin: beginColor, end: endColor
      );

      _colorTweenAnimation = _colorTween.animate(
        CurvedAnimation(
          parent: _controller, curve: Curves.easeIn //////
        )
      );

    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Colorly().fromNetwork().get(track.logo),
      builder: (context, snapshot) {
        dynamic colors = snapshot.data;

        if(snapshot.hasData){
          paint(
            Colors.transparent, 
            colors['primary']
          );

          Timer(Duration(milliseconds: 500), () async {
            _controller.forward();
          });
        }

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, snapshot) {
            return Scaffold(
              backgroundColor: _colorTweenAnimation.value,
              appBar: AppBar(
                leading: Buttons.back(),
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter, 
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
                                    color: Colors.black,
                                    colorBlendMode: BlendMode.softLight
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
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
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 2,
                                      overlayShape: SliderComponentShape.noOverlay,
                                      trackShape: CustomTrackShape()
                                    ),
                                    child: Slider(  
                                      min: 0,  
                                      max: 100,  
                                      value: _seek,
                                      activeColor: AppColor.secondary,
                                      thumbColor: Colors.white,
                                      onChanged: (value) {  
                                        setState(() {  
                                          _seek = value;
                                        });  
                                      },  
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(startPos, style: TextStyle(fontSize: 12)),
                                      Text(duration, style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  SizedBox(height: 50),
                                ],
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
                            constraints: BoxConstraints(),
                            tooltip: "Repeat",
                            onPressed: () {
                              //
                            },
                            icon: Icon(
                              Iconsax.repeat,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            tooltip: "Previous Track",
                            onPressed: () {
                              //
                            },
                            icon: Icon(
                              Iconsax.backward,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColor.secondary,
                              borderRadius: BorderRadius.circular(100)
                            ),
                            child: isLoading ? Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: AppColor.primary,
                                  )
                                ),
                              ) : IconButton(
                              tooltip: !isPlaying ? 'Play' : 'Pause',
                              onPressed: () {
                                setState(() {
                                  isPlaying = !isPlaying;
                                });
                              },
                              icon: Icon(
                                !isPlaying ? Icons.play_arrow : Icons.pause,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: "Forward Track",
                            onPressed: () {
                              //
                            },
                            icon: Icon(
                              Iconsax.forward,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            tooltip: "Add to Favorites",
                            onPressed: () {
                              setState(() {
                                _fav = !_fav;
                              });
                            },
                            icon: !_fav ? Icon(
                              Iconsax.heart,
                              color: Colors.white,
                            ) : Icon(
                              FontAwesomeIcons.solidHeart, ////////////////
                              color: AppColor.secondary, //////////////////
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
        );
      }
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme . trackHeight !;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (
      parentBox.size.height - trackHeight
    ) / 2;
    final double trackWidth = parentBox.size.width; ///////

    return Rect.fromLTWH(
      trackLeft, trackTop,  trackWidth, trackHeight ///////
    );

  }

}