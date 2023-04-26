import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/utils/Helpers/Country.dart';

class Tile extends StatefulWidget {
  final BuildContext context;
  final String type;
  final String label;
  final IconData icon;
  final dynamic data;

  const Tile({ 
    Key? key,
    required this.context,
    required this.type,
    required this.label,
    required this.icon,
    required this.data,
  }) : super(key: key);

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  double width = 0;
  Color? borderColor;
  Color? color;
  Color? backgroundColor;

  @override
  void initState() {
    width = MediaQuery.of(widget.context).size.width;
    borderColor = {
      "primary": AppColor.secondary,
      "secondary": Color(0XFF7c7450).withAlpha( 100 )
    }[widget.type]!;

    color = {
      "primary": Colors.black,
      "secondary": Colors.white
    }[widget.type]!;

    backgroundColor = {
      "primary": AppColor.secondary,
      "secondary": AppColor.primary
    }[widget.type]!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width / 2.4,
      height: 100,
      padding: EdgeInsets.fromLTRB(20,10,20,0),
      decoration: BoxDecoration(
        color: backgroundColor,
        image: DecorationImage(
          image: AssetImage(
            "assets/images/illustration/burst_circle.png"
          ),
          alignment: Alignment.bottomCenter
        ),
        border: Border.all(
          color: borderColor!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.label, style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color
                ),
              ),
              Icon(widget.icon, color: color)
            ],
          ),
          SizedBox(height: 10),
          FadeIn(
            child: Text(
              widget.data.toString(), 
              style: TextStyle(
                color: color,
                fontSize: 25, fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Summary extends StatefulWidget {
  final Map statistics;
  final dynamic data;

  const Summary({ 
    Key? key, 
    required this.statistics,
    required this.data 
  }) : super(key: key);

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  bool isLoading = true;
  double width = 0;
  double percentage = 0;
  double progress = 0;
  dynamic country;

  @override
  void initState() {
    Future(() async {
      country = await Countries.get( widget.data.key );
      setState(() {
        isLoading = false;
      });
    });

    width = MediaQueryData.fromWindow(
      WidgetsBinding.
      instance.window
    ).size.width - (40 /**parent */ + 40 /** body */);

    final int totalPlays = widget.statistics['plays'];
    int summary = widget.statistics['summary'].length;

    percentage = widget.data.value 
    / summary;

    Timer(Duration(milliseconds: 200), (){ ///////////
      setState(() {
         progress = percentage * width;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CachedNetworkImage image = CachedNetworkImage(
      imageUrl: country?['flag'] ?? '',
      placeholder: (context, url) {
        return Center(
          child: SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            )
          )
        );
      },
      errorWidget: (context, url, error) => Icon(
        Icons.error
      ),
      fit: BoxFit.cover,
    );

    return isLoading ? SizedBox() : Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 25,
                height: 25,
                child: image,
              ),
              SizedBox(width: 10),
              Labels.primary(
                widget.data.key,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                margin: EdgeInsets.zero
              ),
              Spacer(),
              Labels.primary(
                "${
                  (percentage * 100).toStringAsFixed(0)
                }%",
                fontSize: 12,
                fontWeight: FontWeight.bold,
                margin: EdgeInsets.zero
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            width: width,
            height: 5,
            decoration: BoxDecoration(
              color: Color(0XFFD9D9D9).withAlpha(50),
              borderRadius: BorderRadius.circular(50)
            ),
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.topLeft,
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              width: progress,
              height: 5,
              color: AppColor.secondary.withAlpha(255),
            ),
          )
        ],
      ),
    );
  }

}