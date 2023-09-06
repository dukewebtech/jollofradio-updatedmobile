import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:shimmer/shimmer.dart';

class PlaylistShimmer extends StatelessWidget {
  final String type;
  final int length;

  const PlaylistShimmer({
     Key? key,
     required this.type,
     this.length = 5
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if(type == 'recent'){
      return ListView.builder(
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: length,
        itemBuilder: (context, index) {
          return Container(
            width: width / 1.3,
            height: double.infinity,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Color(0XFF0D1921)
            ),
            child: Shimmer.fromColors(
              baseColor: AppColor.primary,
              highlightColor: Color(0XFF0D1921),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 150,
                        height: 5,
                        color: AppColor.primary,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: 50,
                        height: 5,
                        color: AppColor.primary,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
      );
    }

    return Placeholder();
    
  }
}