import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jollofradio/config/models/Station.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RadioTemplate extends StatelessWidget {
  final Station station;

  const RadioTemplate({
    super.key,
    required this.station
  });

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
      
    return Container(
      width: double.infinity,
      height: 80,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color(0XFF12222D),
        borderRadius: BorderRadius.circular(5)
      ),
      child: GestureDetector(
        onTap: () => RouteGenerator.goto(TRACK_PLAYER, {
          "track": station,
          "channel": "station"
        }),
        child: Row(
          children: <Widget>[
            Container(
              width: 80,
              height: 70,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(5)
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: station.logo,
                placeholder: (context, url) {
                  return Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      )
                    )
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
              width: MediaQuery.of(context).size.width - 150,
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
                            Column(
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
                            Spacer(),
                            Container(
                              width: 60,
                              margin: EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () async {

                                      await Share.share(
                                        'Listen to: ${station.title} on Jollof Radio', 
                                        subject: 'Listen to: ${
                                          station.title
                                        } on Jollof Radio for FREE'
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

                                      Map? social = station.handles; //fetch handles
                                      if( social != null
                                      && social.containsKey('twitter')){

                                        String url = station. handles! [
                                          'twitter'
                                        ];

                                        await launchUrl(Uri.parse(url)); //redirects
                                        return;

                                      }
                                      
                                      return Toaster.info(
                                        "No Twitter handle available at the moment."
                                      );
                                      
                                    },
                                    child: Icon(
                                      FontAwesomeIcons.twitter, 
                                      color: AppColor.secondary,
                                      size: 18,
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