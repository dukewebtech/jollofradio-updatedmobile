import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:shimmer/shimmer.dart';

class PodcastShimmer extends StatelessWidget {
  final String type;
  final int length;

  const PodcastShimmer({
     Key? key,
     required this.type,
     this.length = 5
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if(type == 'grid'){
      return SizedBox(
        height: 170,
        child: Shimmer.fromColors(
          baseColor: AppColor.primary,
          highlightColor: Color(0XFF0D1921),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: length,
            itemBuilder: (context, index) {
              return Container(
                width: 140,
                height: 170,
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.fromLTRB(5,5,5,0),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                clipBehavior: Clip.hardEdge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 120,
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: Color(0XFF0D1925),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 120,
                            color: AppColor.primary,
                          ),
                          Positioned(
                            left: 5,
                            bottom: 5,
                            child: Container(
                              width: 0,
                              height: 0,
                              color: AppColor.primary,
                              constraints: BoxConstraints(  ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
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
                ),
              );
            }
          ),
        ),
      );
    }

    if(type == 'list'){
      return Shimmer.fromColors(
        baseColor: AppColor.primary,
        highlightColor: Color(0XFF0D1921),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: length,
          itemBuilder: (context, index) {
            return Container(
              width: double.infinity,
              height: 80,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5)
              ),
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
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: width - 150,
                    height: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 10,
                          color: Color(0XFF0D1921),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 100,
                          height: 10,
                          color: Color(0XFF0D1921),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        ),
      );
    }

    return Placeholder();
  }
}