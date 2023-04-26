import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Category.dart';
import 'package:jollofradio/config/models/Test/PodcastFactory.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/CategoryController.dart';
import 'package:jollofradio/config/services/controllers/HomeController.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Category.dart';
import 'package:jollofradio/screens/Layouts/Shimmers/Podcast.dart';
import 'package:jollofradio/screens/Layouts/Templates/Category.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/utils/date.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/helpers/Factory.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
// import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Function(int page)? tabController;
  const HomeScreen(this.tabController, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // late User user;
  late Map streams;
  bool isLoading = true;
  bool refresh = false;

  List recently = PodcastFactory().get(0, 3);
  List podcasts = PodcastFactory().get(0, 3);
  List userLikes = PodcastFactory().get(3, 3);
  CacheStream cacheManager = CacheStream();

  @override
  void initState() {
    /*
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;
    */

    //cache manager
    (() async {
      await cacheManager.mount({
        'streams': {
          'data': () async {
            return await HomeController.index({ 'limit': 20 });
          },
          'rules': (data){
            return data['trending'].isNotEmpty;
          },
        },
        'category': {
          'data': () async {
            return await CategoryController.index(); // fetching
          },
          'rules': (data) => data.isNotEmpty,
        }
      }, Duration(
        seconds: 20
      ));

      fetchStreams() ;

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
        return HomeController.index({ 
          'limit': 20
        });
      },
      callback: HomeController.construct
    );

    this.streams = streams;

    streams['likes'].shuffle();

    setState(() {
      isLoading = false;
      refresh = false;
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
                         RouteGenerator.goto(SIGNIN, {
                          //
                         });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0XFF0D1921),
                          borderRadius: BorderRadius.circular(100)
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Icon(
                          Iconsax.user,
                          color: Color(0XFF828282),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
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
                        "Picked for you",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          RouteGenerator.goto(TRENDING, {
                            "episodes": streams['latest'] ?? []
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
                        if(isLoading) ... [
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        ]
                        else
                        if(streams['latest'].isEmpty) ... [
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
                          ...Factory(streams['latest'])
                          .get(0, 5).map(
                                    (episode) => /** */ PodcastTemplate (
                            type: 'grid',
                            episode: episode,
                            podcasts: streams['latest'],
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
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}