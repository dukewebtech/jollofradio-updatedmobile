import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Category.dart';
import 'package:jollofradio/config/models/Test/PodcastFactory.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/CategoryController.dart';
import 'package:jollofradio/config/services/controllers/StationController.dart';
import 'package:jollofradio/config/services/controllers/User/StreamController.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Category.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Playlist.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Podcast.dart';
import 'package:jollofradio/screens/Layouts/Templates/Category.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/screens/Layouts/Templates/Radio.dart';
import 'package:jollofradio/screens/User/LibraryScreen.dart';
import 'package:jollofradio/utils/date.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/helpers/Factory.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Function(int page)? tabController;
  const HomeScreen(this.tabController, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User user;
  late Map streams;
  late List stations;
  bool isLoading = true;
  bool refresh = false;

  List recently = PodcastFactory().get(0, 3);
  List podcasts = PodcastFactory().get(0, 3);
  List userLikes = PodcastFactory().get(3, 3);
  CacheStream cacheManager = CacheStream();

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    //cache manager
    (() async {
      await cacheManager.mount({
        'streams': {
          'data': () async {
            return await StreamController.index({ 'limit': 20 });
          },
          'rules': (data){
            return data['trending'].isNotEmpty;
          },
        },
        'stations': {
          'data':  () async {
            return await StationController.index();  // stations
          },
          'rules': (data){
            return data['local'].isNotEmpty;
          },
        },
        'category': {
          'data': () async {
            return await CategoryController.index(); // fetching
          },
          'rules': (data) => data.isNotEmpty,
        },
      }, Duration(
        seconds: 20
      ));

      fetchStreams() ;
      fetchStation() ;

    }());

    super.initState();
  }

  @override
  dispose() {
    // cacheManager.unmount();
    super.dispose();
  }

  Future<void> fetchStreams() async {
    setState(() {
      isLoading = true;
    });

    final streams = await cacheManager.stream( ////////////////
      'streams', 
      refresh: refresh,
      fallback: () async {
        return StreamController.index({ 
          'limit': 20
        });
      },
      callback: StreamController.construct
    );

    this.streams = streams;

    streams['likes'].shuffle();

    setState(() {
      isLoading = false;
      refresh = false;
    });
  }

  Future<void> fetchStation() async {
    // setState(() {
    //   isLoading = true;
    // });

    final stations = await cacheManager.stream( ///////////////
      'stations', 
      fallback: () async {
        return StationController.index();
      },
      callback: StationController.construct
    );

    this.stations = [
      ...stations['local'],
      ...stations['international']
    ];
    this.stations.shuffle();

    // setState(() {
    //   isLoading = false;
    // });
  }

  void callback(episode, [Map? data]) async {
    data = data ?? {};

    await StreamController.delete({'episode_id' : episode.id})
    .then((value) async {
      refresh = true;
      fetchStreams();
    });
  }

  Future<List<Category>> category() async {
    final category = await cacheManager.stream( ///////////////
      'category', 
      fallback: () async {
        return CategoryController.index();
      },
      callback: (data) async {
        return CategoryController.construct(
          data
        );
      }
    );
    
    return category;

    /*
    return await CategoryController.index().then((categories) {
      //prefetch instance
      List cat = categories.map((e) => e.toJson()).toList(  ) ;
      Storage.set(
        'category', 
        jsonEncode (cat)
      );
      this.categories = categories;
      return categories;
    });
    */
  }

  bool hasNotifications(){
    bool unread = false;
    final List notifications = user.notifications.map((alert) {
      if(alert['status'] == 'unread'){
        unread = true;
      }
    }).toList();

    return unread;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;
    
    return Scaffold(
      appBar: null,
      body: LiquidPullToRefresh(
        showChildOpacityTransition: false,
        height: 120,
        backgroundColor: AppColor.secondary,
        onRefresh: () async => {
          await Future.delayed(Duration(seconds: 1), () async {
            setState(() {
              fetchStreams();
            });
          })
        },
        child: Container(
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
                Row(
                  children: <Widget>[
                    Labels.primary(
                      "Good " +Date().timezone(),
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        RouteGenerator.goto(NOTIFICATION, {
                          "user": user
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0XFF0D1921),
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Iconsax.notification,
                              color: Color(0XFF828282),
                              size: 16,
                            ),
                            if(hasNotifications())
                            Positioned(
                              top: 5,
                              right: 2,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Color(0XFFFF4242),
                                  borderRadius: BorderRadius.circular(100)
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                         RouteGenerator.goto(PROFILE, {
                          "user": user
                         });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Color(0XFF0D1921),
                          borderRadius: BorderRadius.circular(100)
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: user.photo,
                            placeholder: (context, url) {
                              return Center(
                                child: SizedBox(
                                  width: 15,
                                  height: 15,
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Labels.primary(
                  "Recently Played",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
                SizedBox(
                  height: 70,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        if(isLoading || streams['recent'].isEmpty)  ... [

                          if(!isLoading && streams['recent'].isEmpty)
                            Container(
                              alignment: Alignment.center,
                              width: width - 40,
                              padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    Message.no_activity,
                                    style: TextStyle(
                                      color: Color(0XFF9A9FA3),
                                      fontSize: 14
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            )
                          else
                            PlaylistShimmer(
                              type: 'recent', 
                              length: 3
                            )
                        ] 
                        else ...[
                          ...Factory(streams['recent'])
                          .get(0, 5).map(
                                    (episode) => /** */ PodcastTemplate (
                            type: 'play',
                            episode: episode,
                            podcasts: streams['recent'],
                            callback: callback,
                          ))
                        ]
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),              
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Labels.primary(
                        "Top Categories",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () async {
                          RouteGenerator.goto(CATEGORY, {
                            "categories": await category()
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
                      crossAxisAlignment: /**/CrossAxisAlignment.start,
                      children: <Widget>[
                        FutureBuilder(
                          future: category(),
                          builder: (context, snapshot) {
                            List<Category>? categories = snapshot.data;
                            if(!snapshot.hasData || 
                            snapshot.data!.isEmpty){                            
                              return const CategoryShimmer(
                                length: 3
                              );
                            }
                            return Row(
                              children: [
                                ...Factory(categories as List<Category>)
                                .get(0, 5).map<Widget>((category) {
                                  return CategoryTemplate(
                                    category: category,
                                  );
                                }).toList()
                              ]
                            );
                          },
                        ),
                      ]
                    )
                  )
                ),
                SizedBox(height: 40),
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Labels.primary(
                        "Top this week",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          RouteGenerator.goto(TRENDING, {
                            "episodes": streams['trending'] ?? []
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
                        if(isLoading || streams['trending'].isEmpty)... [
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        ] 
                        else ...[
                          ...Factory(streams['trending'])
                          .get(0, 5).map(
                                    (episode) => /** */ PodcastTemplate (
                            type: 'grid',
                            episode: episode,
                            podcasts: streams['trending'],
                          ))
                        ]
                      ],
                    )
                  )
                ),
                SizedBox(height: 40),
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Labels.primary(
                        "New Release",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          RouteGenerator.goto(NEW_RELEASE, {
                            "podcasts": streams['release'] ?? []
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
                        if(isLoading || streams['release'].isEmpty)... [
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        ] 
                        else ...[
                          ...Factory(streams['release'])
                          .get(0, 5).map(
                                    (podcast) => /** */ PlaylistTemplate (
                            playlist: podcast,
                            compact: true
                          ))
                        ]
                      ],
                    )
                  )
                ),
                SizedBox(height: 40),
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Labels.primary(
                        "From your Likes",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          LibraryScreen.page = 'Liked';
                          widget.tabController!(1);
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
                        if(isLoading) ... [
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        ]
                        else
                        if(streams['likes'].isEmpty) ... [
                          Container(
                            alignment: Alignment.center,
                            width: width - 40,
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Iconsax.heart,
                                  size: 40,
                                  color: Color(0XFF9A9FA3),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  Message.no_activity,
                                  style: TextStyle(
                                    color: Color(0XFF9A9FA3),
                                    fontSize: 14
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          )
                        ]
                        else ...[
                          ...Factory(streams['likes'])
                          .get(0, 5).map(
                                    (episode) => /** */ PodcastTemplate (
                            type: 'grid',
                            episode: episode,
                            podcasts: streams['likes'],
                          ))
                        ]
                      ],
                    )
                  )
                ),
                SizedBox(height: 40),
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Labels.primary(
                        "Radio Stations",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.tabController!(3);
                        },
                        child: Labels.secondary(
                          "See All"
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if(isLoading) ... [
                          PodcastShimmer(
                            type: 'list',
                            length: 3
                          )
                        ]
                        else
                        if(stations.isEmpty) ... [
                          Container(
                            alignment: Alignment.center,
                            width: width - 40,
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 40),
                            child: Column(
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
                                  style: TextStyle(
                                    color: Color(0XFF9A9FA3),
                                    fontSize: 14
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          )
                        ]
                        else ...[
                          ...Factory(stations)
                          .get(0, 5).map((radio) => /** */ RadioTemplate(
                            station: radio,
                          ))
                        ]
                      ],
                    )
                  )
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}