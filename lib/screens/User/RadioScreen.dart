import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/StationController.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Radio.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/helpers/Factory.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:provider/provider.dart';

class RadioScreen extends StatefulWidget {
  final Function(int page)? tabController;
  const RadioScreen(this.tabController, {super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  late User user;
  bool isLoading = true;
  Map stations = {};
  List localRadio = [];
  List intlRadio = [];
  CacheStream cacheManager = CacheStream();

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    //cache manager
    (() async {
      await cacheManager.mount({
        'stations': {
          'data':  () async {
            return await StationController.index();
          },
          'rules': (data){
            return data['local'].isNotEmpty;
          },
        },
      }, null);

      getRadioStation();

    }());
    
    super.initState();
  }

  Future<void> getRadioStation() async {
    final stations = await cacheManager.stream( ///////////////
      'stations', 
      fallback: () async {
        return StationController.index();
      },
      callback: StationController.construct
    );

    this.stations = stations;
    localRadio = Factory((stations['local'] as List)).get( ////
      0,
      stations['international'].
      isNotEmpty ? 3 : 6
    );
    intlRadio = Factory( (stations['international'])).get(0,3);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: AppBar().preferredSize.height + 00,
          left: 20, 
          right: 20
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(isLoading) ...[
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 2.6
                ),
                padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: const CircularProgressIndicator(),
                    )
                  ],
                ),
              )
            ]
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Labels.primary(
                    "Local Broadcasts",
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                  if(localRadio.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      RouteGenerator.goto(STATIONS, {
                        "title": "Local Broadcasts",
                        "stations": stations['local']
                      });
                    },
                    child: Labels.secondary(
                      "See All"
                    ),
                  )
                ],
              ),
              SizedBox(height: 05),
              Column(
                children: [
                  if(localRadio.isEmpty)
                    Container(
                      height: 300,
                      padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Iconsax.radar5,
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
                    )
                  else
                    FadeIn(
                      child: Column(
                        children: <Widget>[
                          ...localRadio.map((radio) => RadioTemplate(
                            station: radio,
                          ))
                        ],
                      ),
                    )
                ],
              ),
              SizedBox(height: 20),
              if(localRadio.length < 4) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Labels.primary(
                      "International FM",
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    if(intlRadio.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        RouteGenerator.goto(STATIONS, {
                          "title": "International FM",
                          "stations": stations['international']
                        });
                      },
                      child: Labels.secondary(
                        "See All"
                      ),
                    )
                  ],
                ),
                SizedBox(height: 05),
                Column(
                  children: [
                    if(intlRadio.isEmpty)
                      Container(
                        height: 300,
                        padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Iconsax.radar5,
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
                      )
                    else
                      FadeIn(
                        child: Column(
                          children: <Widget>[
                            ...intlRadio.map((radio) => RadioTemplate(
                              station: radio,
                            ))
                          ],
                        ),
                      )
                  ],
                ),
              ]
            ]
          ],
        ),
      ),
    );
  }
}