import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/Creator/PodcastController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Podcast.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/helpers/Factory.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Shared.dart';
import 'package:provider/provider.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({ Key? key }) : super(key: key);

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  late Creator user;
  bool isLoading = true;
  CacheStream cacheManager = CacheStream();
  Map<String, dynamic> podcasts = {
    "all": [],
    "pending": [],
    "top": [],
  };

  @override
  void initState() {
    var auth = Provider.of<CreatorProvider>(context,listen: false);
    user = auth.user;

    //cache manager
    (() async {
      await cacheManager.mount({
        '_podcasts': {
          'data': () async {
            return await PodcastController.index(); /////////////
          },
          'rules': (data){
            return data.isNotEmpty;
          },
        },
      }, Duration(
        seconds: 10
      ));

      getPodcasts();

      Timer.periodic(Duration(seconds: 5), (Timer timer) async { 
        // getPodcasts();
      });

    }());

    super.initState();
  }

  Future<void> getPodcasts() async {
    // setState(() {
    //   isLoading = true;
    // });

    final podcasts = await cacheManager.stream( ////////////////
      '_podcasts', 
      fallback: () async {
        return PodcastController.index();
      },
      callback: PodcastController.construct
    );

    this.podcasts['all'] = 
    podcasts['podcasts'];

    //un-approved
    this.podcasts['pending'] = 
    podcasts['pending'];

    //top podcast
    this.podcasts['top'] = 
    podcasts['topChart'];

    /*
    todaySubs = subscribers.where((dynamic user) {   //callback!
      String subDate = user['created_at']
      .split('T')[0];

      return subDate == Date().format("yyyy-MM-dd"); //test date
    }).toList();
    */

    if(mounted)
    setState(() {
      isLoading = false;
    });
  }

  @override
  dispose() {
    // cacheManager.unmount({'podcasts'});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Color(0XFF0D1921),
                  borderRadius: BorderRadius.circular(6),
                ),
                clipBehavior: Clip.hardEdge,
                child: CachedNetworkImage(
                  imageUrl: user.banner,
                  placeholder: (context, url) {
                    return Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: const CircularProgressIndicator()
                      )
                    );
                  },
                  imageBuilder: (context, imageProvider) {
                    return Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    );
                  },
                  errorWidget: (context, url, error) => Icon(
                    Icons.error
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                child: Stack(
                  children: [
                    Buttons.primary(
                      label: "Add New Podcast",
                      onTap: () => uploadDialog(),
                    ),
                    Positioned(
                      top: 12,
                      left: MediaQuery.of(context).size.width / 2 - (
                        110
                      ),
                      child: Icon(
                        Iconsax.add,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Labels.primary(
                      "My Podcasts",
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    if(podcasts['all'].length > 3)
                    GestureDetector(
                      onTap: () async {
                        RouteGenerator.goto(CREATOR_PODCAST, {
                          "title": "Podcasts",
                          "podcasts":  podcasts['all']
                        });
                      },
                      child: Labels.secondary(
                        "See All"
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if(isLoading || podcasts['all']!.isEmpty) ...[
                        if(isLoading)
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        else
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.music,
                            ),
                          )
                      ] 
                      else ...[
                        ...Factory(podcasts['all']!)
                        .get(0, 5).map(
                                  (podcast) => /**/ PlaylistTemplate(
                          key: UniqueKey(),
                          playlist: podcast,
                          compact: true,
                          creator: true,
                        ))
                      ]
                    ],
                  )
                )
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Labels.primary(
                      "Unapproved",
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    if(podcasts['pending'].length > 3)
                    GestureDetector(
                      onTap: () async {
                        RouteGenerator.goto(CREATOR_PODCAST, {
                          "title": "Unapproved",
                          "podcasts":  podcasts['pending']
                        });
                      },
                      child: Labels.secondary(
                        "See All"
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if(isLoading || podcasts['pending']!.isEmpty) ...[
                        if(isLoading)
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        else
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.music,
                            ),
                          )
                      ] 
                      else ...[
                        ...Factory(podcasts['pending']!)
                        .get(0, 5).map(
                                  (podcast) => /**/ PlaylistTemplate(
                          key: UniqueKey(),
                          playlist: podcast,
                          compact: true,
                          creator: true,
                        ))
                      ]
                    ],
                  )
                )
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Labels.primary(
                      "Top Podcasts",
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    if(podcasts['top'].length > 3)
                    GestureDetector(
                      onTap: () async {
                        RouteGenerator.goto(CREATOR_PODCAST, {
                          "title": "Top Podcasts",
                          "podcasts":  podcasts['top']
                        });
                      },
                      child: Labels.secondary(
                        "See All"
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if(isLoading || podcasts['top']!.isEmpty) ...[
                        if(isLoading)
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        else
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.music,
                            ),
                          )
                      ] 
                      else ...[
                        ...Factory(podcasts['top']!)
                        .get(0, 5).map(
                                  (podcast) => /**/ PlaylistTemplate(
                          key: UniqueKey(),
                          playlist: podcast,
                          compact: true,
                          creator: true,
                        ))
                      ]
                    ],
                  )
                )
              ),
              SizedBox(height: 20)
            ]
          ),
        )
      )
    );
  }

  Future uploadDialog() async {
    return showDialog(
      context: context, 
      builder: (context) {
        
        return FadeInUp(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(10)
                ),
                clipBehavior: Clip.hardEdge,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          width: 280,
                          child: Text(
                            "How do you want to add your podcast?",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                RouteGenerator.goto(CREATOR_PODCAST_NEW, {
                                  "type": "import",
                                  "callback": getPodcasts
                                });
                              },
                              child: Container(
                                width: 120,
                                height: 70,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color(0XFF0D1921),
                                  border: Border.all(
                                    color: Color(0XFF373328),
                                    width: 0.5
                                  ),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Text(
                                  "RSS Link", style: TextStyle(fontSize: 12
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                RouteGenerator.goto(CREATOR_PODCAST_NEW, {
                                  "type": "create",
                                  "callback": getPodcasts
                                });
                              },
                              child: Container(
                                width: 120,
                                height: 70,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color(0XFF0D1921),
                                  border: Border.all(
                                    color: Color(0XFF373328),
                                    width: 0.5
                                  ),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Text(
                                  "Manual upload", style: TextStyle(fontSize: 12
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        
      },
    );
  }

}