import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/Creator/PodcastController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Podcast.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/helpers/Factory.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';
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
  Map<String, List> podcasts = {
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
        'podcasts': {
          'data': () async {
            return await PodcastController.index(); /////////////
          },
          'rules': (data){
            return data.isNotEmpty;
          },
        },
      }, null);

      getPodcasts();

    }());

    super.initState();
  }

  Future<void> getPodcasts() async {
    final podcasts = await cacheManager.stream( ////////////////
      'podcasts', 
      fallback: () async {
        return PodcastController.index();
      },
    );

    print(podcasts);

    this.podcasts['all'] = podcasts;

    //un-approved
    this.podcasts['pending'] = podcasts;

    //top podcast
    this.podcasts['top'] = podcasts;



    /*
    todaySubs = subscribers.where((dynamic user) {   //callback!
      String subDate = user['created_at']
      .split('T')[0];

      return subDate == Date().format("yyyy-MM-dd"); //test date

    }).toList();
    */

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
                margin: EdgeInsets.only(bottom: 20),
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
                      onTap: () {
                        
                        //

                      },
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
              // SizedBox(height: 20),
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
                    GestureDetector(
                      onTap: () async {
                        RouteGenerator.goto(CREATOR_PODCAST, {
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
                      if(isLoading || podcasts['all']!.isEmpty)... [
                        PodcastShimmer(
                          type: 'grid',
                          length: 3
                        )
                      ] 
                      else ...[
                        ...Factory(podcasts['all']!)
                        .get(0, 5).map(
                                  (podcast) => /** */ PlaylistTemplate (
                          playlist: podcast,
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
                    GestureDetector(
                      onTap: () async {
                        RouteGenerator.goto(CREATOR_PODCAST, {
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
                      if(isLoading || podcasts['pending']!.isEmpty)... [
                        PodcastShimmer(
                          type: 'grid',
                          length: 3
                        )
                      ] 
                      else ...[
                        ...Factory(podcasts['pending']!)
                        .get(0, 5).map(
                                  (podcast) => /** */ PlaylistTemplate (
                          playlist: podcast,
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
                    GestureDetector(
                      onTap: () async {
                        RouteGenerator.goto(CREATOR_PODCAST, {
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
                      if(isLoading || podcasts['top']!.isEmpty)... [
                        PodcastShimmer(
                          type: 'grid',
                          length: 3
                        )
                      ] 
                      else ...[
                        ...Factory(podcasts['top']!)
                        .get(0, 5).map(
                                  (podcast) => /** */ PlaylistTemplate (
                          playlist: podcast,
                        ))
                      ]
                    ],
                  )
                )
              ),
            ]
          ),
        )
      )
    );
  }
}