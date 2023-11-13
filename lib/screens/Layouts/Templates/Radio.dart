import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jollofradio/config/models/Station.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RadioTemplate extends StatefulWidget {
  final Station station;
  final dynamic callback;

  const RadioTemplate({
    super.key,
    required this.station,
    this.callback
  });

  @override
  State<RadioTemplate> createState() => _RadioTemplateState();
}

class _RadioTemplateState extends State<RadioTemplate> {
  bool _fav = false;
  late Station station;

  @override
  void initState() {
    station = widget.station;
    getFavorites();

    super.initState();
  }

  Future<dynamic> addToFavorites() async {
    await Storage.get('favRadio',Map).then((stations)  {
      stations = stations ?? [];

      if(!_fav){

        stations.add(station.toJson());

      }
      else{
        stations.removeWhere((item){

          return item['title'] == station.title; //select

        });

        if(widget.callback != (null)) {
          widget.callback!(station, {
            "station": true
          });
        }
      }

      Storage.set(
        'favRadio', jsonEncode(stations)
      );

      setState(() {
        _fav = !_fav;
      });
    });
  }

  Future<dynamic> getFavorites() async {
    await Storage.get('favRadio',Map).then((stations)  {
      if(stations == null)
        return;

      _fav = stations.any((item){
        return item['title'] == station.title;
      });

      setState(() { });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
      
    return GestureDetector(
      onTap: () => RouteGenerator.goto(RADIO_PLAYER, {
        "radio": station,
        "channel": "station"
      }),
      child: Container(
        width: double.infinity,
        height: 90,
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Color(0XFF12222D),
          borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(5)
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                  memCacheWidth: 150,
                  memCacheHeight: 150,
                imageUrl: station.logo,
                placeholder: (context, url) {
                  return Image.asset(
                    'assets/images/loader.png',
                    fit: BoxFit.cover,
                    cacheWidth: 150,
                    cacheHeight: 150,
                  );
                },
                errorWidget: (context, url, error) =>  Icon(
                  Icons.error
                ),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width - 145,
              height: 70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                          child: Labels.primary(
                            station.title,
                            maxLines: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            margin: EdgeInsets.only(bottom: 5)
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: width - 240,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    station.state+", "+station.country, 
                                  style: TextStyle(
                                    color: Color(0XFF9A9FA3),
                                    fontSize: 12,
                                  ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    station.frequency.toString(), style: TextStyle(
                                    color: Color(0XFF9A9FA3),
                                    fontSize: 10
                                  )),
                                ],
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: 80,
                              // margin: EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => addToFavorites(),
                                    child: !_fav ? Icon(
                                      Iconsax.heart, 
                                      color: Color(0XFF575C5F),
                                      size: 18,
                                    ) : Icon(
                                      Iconsax.heart5, 
                                      color: AppColor.secondary,
                                      size: 18,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await Share.share(
                                        shareLink(
                                          type: 'station', data: station
                                        )
                                      );
                                    },
                                    child: Icon(
                                      FontAwesomeIcons.share, 
                                      color: Color(0XFF575C5F),
                                      size: 18,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final twitter = /**/station.social('twitter');

                                      if(twitter != null){

                                        await launchUrl(Uri.parse(twitter));
                                        return;
                                        
                                      }
                                      
                                      return Toaster.info(
                                        "No Twitter handle available at the moment."
                                      );
                                      
                                    },
                                    child: ImageIcon(
                                      AssetImage("assets/images/icons/x-white.png"),
                                      size: 12,
                                      color: Color(0XFF575C5F),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}