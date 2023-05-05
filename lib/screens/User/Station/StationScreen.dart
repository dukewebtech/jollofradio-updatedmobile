import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Radio.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Player.dart';

class StationScreen extends StatefulWidget {
  final String title;
  final List stations;
  const StationScreen({
    super.key, 
    required this.title,
    required this.stations
  });

  @override
  State<StationScreen> createState() => _StationScreenState();
}

class _StationScreenState extends State<StationScreen> {
  late List stations;
  @override
  void initState() {
    stations = widget.stations;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text(widget.title),
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
                      if(stations.isEmpty) ...[
                        Container(
                          height: 300,
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 4
                          ),
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
                      ]
                      else ...[
                        ...stations.map((radio) => RadioTemplate(
                          station: radio,
                        ))
                      ]
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