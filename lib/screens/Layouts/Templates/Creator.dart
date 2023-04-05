import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/widget/Labels.dart';

class CreatorTemplate extends StatelessWidget {
  final Creator creator;
  const CreatorTemplate({super.key, required this.creator});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(),
      clipBehavior: Clip.hardEdge,
      child: GestureDetector(
        onTap: () {
          RouteGenerator.goto(CREATOR_PROFILE, {
            "creator": creator
          });
        },
        child: Column(
          children: <Widget>[
            Container(
              width: 140,
              height: 140,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  width: 5,
                  color: Color(0XFF12222D)
                )
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: creator.photo,
                placeholder: (context, url) {
                  return Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator()
                    )
                  );
                },
                imageBuilder: (context, imageProvider) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(100),
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
              creator.username(),
              fontWeight: FontWeight.bold,
              margin: EdgeInsets.only(bottom: 5)
            ),
            Text(
              "${creator.podcasts?.length} Podcasts", 
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.4)
              ),
            )
          ],
        ),
      )
    );
  }
}