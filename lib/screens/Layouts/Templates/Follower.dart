import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
// import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/widget/Labels.dart';

class FollowerTemplate extends StatefulWidget {
  final Map follower;
  const FollowerTemplate({ 
    Key? key, 
    required this.follower
  }) : super(key: key);

  @override
  State<FollowerTemplate> createState() => _FollowerTemplateState();
}

class _FollowerTemplateState extends State<FollowerTemplate> {
  late Map follower;

  @override
  void initState() {
    follower = widget.follower;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /* RouteGenerator.goto('/subscribers/:id', { <> }); */
        
      },
      child: Container(
        width: double.infinity,
        height: 70,
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Color(0XFF12222D)
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                width: double.infinity,
                imageUrl: follower['photo'],
                  placeholder: (context, url) {
                    return Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator()
                      )
                    );
                  },
                  errorWidget: (context, url, error) =>  Icon(
                    Icons.error
                  ),
                  fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${
                        follower['firstname']
                      } ${
                        follower['lastname' ]
                      }",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(
                      height: 5
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 130,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Labels.secondary(
                            "${
                              follower['collection'].length
                            } Collections",
                            fontSize: 12
                          ),
                          Icon(
                            Iconsax.arrow_right_1,
                            color: AppColor.secondary,
                            size: 14,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            )
          ]
        ),
      )
    );
  }

}