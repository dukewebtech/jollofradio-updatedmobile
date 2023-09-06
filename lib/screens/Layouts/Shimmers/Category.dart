import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:shimmer/shimmer.dart';

class CategoryShimmer extends StatelessWidget {
  final int length;

  const CategoryShimmer({
     Key? key,
     this.length = 5
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 140,
      child: Shimmer.fromColors(
        baseColor: AppColor.primary,
        highlightColor: Color(0XFF0D1921),
        child: ListView.builder(
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: length,
          itemBuilder: (context, index) {
            return Container(
              width: 140,
              height: 140,
              margin: EdgeInsets.only(right: 10),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: Color(0XFF0D1921),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }
        ),
      ),
    );
  }
}