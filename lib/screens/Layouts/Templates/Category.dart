import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/models/Category.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/colors.dart';

class CategoryTemplate extends StatelessWidget {
  final Category category;
  final bool compact;

  const CategoryTemplate({
    super.key, 
    required this.category,
    this.compact = false
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        RouteGenerator.goto(CATEGORY_TRACK, {
          "category": category
        });
      },
      child: Container(
        width: 140,
        height: 140,
        margin: EdgeInsets.only(right: compact ? 0 : 10),
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          color: Color(0XFF0D1921),
          borderRadius: BorderRadius.circular(4),

          // image: DecorationImage(
          //   image: NetworkImage(category.logo),
          //   fit: BoxFit.cover
          // ),
          
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            CachedNetworkImage(
              width: double.infinity,
              height: double.infinity,
              imageUrl: category.logo,
              placeholder: (context, url) {
                return Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator()
                  )
                );
              },
              imageBuilder: (context, imageProvider) {
                return FadeIn(
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                );
              },
              errorWidget: (context, url, error) =>  Icon(
                Icons.error
              ),
              fit: BoxFit.cover,
            ),
            FutureBuilder(
              future: Colorly().fromNetwork().get(category.logo),
              builder: (context, snapshot) {          
                if(!snapshot.hasData)
                  return SizedBox.shrink();
    
                Map colors = snapshot.data;
    
                return FadeIn(
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors['vibrantDark'].withOpacity(0.5),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                    ),
                    child: Text(category.name, style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold
                    ), 
                      textAlign: TextAlign.left
                    ),
                  ),
                );
                
              }
            ),
          ],
        ),
      ),
    );
    
  }
}