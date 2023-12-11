import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Category.dart';
import 'package:jollofradio/config/models/Episode.dart';
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
import 'package:jollofradio/widget/Shared.dart';
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
  List categories = [];
  List stations = [];
  late Future category;
  Map streams = {
    'toppick': [],
    'latest': [],
    'trending': [],
    'library': [],
    'podcast': [],
    'release': [],
    'playlist': [],
  };
  bool isLoading = true;
  bool reload = false;
  bool refresh = false;

  List recently = PodcastFactory().get(0, 3);
  List podcasts = PodcastFactory().get(0, 3);
  List userLikes = PodcastFactory().get(3, 3);
  CacheStream cacheManager = CacheStream();

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    super.initState();

    category = /**/getCategory();

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

      fetchStreams();
      fetchStation();
      
    }());
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

    if(reload){
      await Future.delayed(Duration(seconds: 1),(){ /** **/ });
    }

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
      reload = false;
      refresh = false;
    });
  }

  Future<void> fetchStation() async {
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

    setState(() {
      // isLoading = false;
    });
  }

  void callback(episode, [Map? data]) async {
    data = data ?? {};

    /*

    streams['recent'].removeWhere((dynamic e) => e == episode);
    setState(() {  });

    */
    
    await StreamController.delete({'episode_id' : episode.id})
    .then((value) async {

      // refresh = true;
      // fetchStreams();
      
    });
  }

  Future<List<Category>> getCategory() async {
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

    categories = category;

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
    user = context.watch<UserProvider>().user; // listens state
    
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;
    
    return Scaffold(
      appBar: null,
      body: LiquidPullToRefresh(
        showChildOpacityTransition: false,
        height: 120,
        backgroundColor: AppColor.secondary,
        onRefresh: () async => {
          // await Future.delayed(Duration(seconds: 1), () {
            setState(() {
              reload = true;
              fetchStreams();
            })
          // })
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
                          "user": user, 
                          "callback": (user){
                            setState(() {
                              
                              this.user = user;
                              
                            });
                          }
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
                            "categories": categories
                          });
                        },
                        child: Labels.secondary("See All"),
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
                          future: category,
                          builder: (context, snapshot) {
                            List<Category>? categories = snapshot.data;
                            if(isLoading == true || !snapshot.hasData || 
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
                SizedBox(height: 20),
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Labels.primary(
                        "Daily Top",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          RouteGenerator.goto(TRENDING, {
                            "title": "Daily Top",
                            "episodes": streams['trending'] ?? []
                          });
                        },
                        child: Labels.secondary("See All"),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if(isLoading) ...[
                          PodcastShimmer(
                            type: 'list',
                            length: 3
                          )
                        ]
                        else
                        if(streams['trending'].isEmpty) ...[
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.music,
                            ),
                          )
                        ]
                        else ...[
                          ...Factory(streams['trending'])
                          .get(0, 5).map(
                                    (episode) => /** */ PodcastTemplate (
                            type: 'list',
                            episode: episode,
                            podcasts: streams['trending'],
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
                        "Your Subscribed",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          LibraryScreen.page = 'Subscribed';
                          widget.tabController!(1);
                        },
                        child: Labels.secondary("See All"),
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
                        if(isLoading) ...[
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        ] 
                        else
                        if(streams['library'].isEmpty) ...[
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.menu_1,
                            ),
                          )
                        ]
                        else ...[
                          ...Factory(streams['library'])
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
                SizedBox(height: 20),
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
                        child: Labels.secondary("See All"),
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
                        if(isLoading) ...[
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        ]
                        else
                        if(streams['likes'].isEmpty) ...[
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.heart,
                              message: Message.no_activity,
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
                SizedBox(height: 20),
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Labels.primary(
                        "Shuffled Pod 247",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          RouteGenerator.goto(TRENDING, {
                            "title": "Shuffled Pod 247",
                            "episodes": streams['toppick'] ?? []
                          });
                        },
                        child: Labels.secondary("See All"),
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
                        if(isLoading)... [
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        ] 
                        else
                        if(streams['toppick'].isEmpty) ...[
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.music,
                            ),
                          )
                        ]
                        else ...[
                          ...Factory(streams['toppick'])
                          .get(0, 5).map(
                                    (episode) => /** */ PodcastTemplate (
                            type: 'grid',
                            episode: episode,
                            podcasts: streams['toppick'],
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
                        "Radio 247",
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
                        if(isLoading) ...[
                          PodcastShimmer(
                            type: 'list',
                            length: 3
                          )
                        ]
                        else
                        if(stations.isEmpty) ...[
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.radar5,
                              message: Message.no_data,
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
                SizedBox(height: 20),
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Labels.primary(
                        "New Podcasters",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          RouteGenerator.goto(JOLLOF_LATEST, {
                            "title": "New Podcasters",
                            "podcasts": streams['podcast'] ?? []
                          });
                        },
                        child: Labels.secondary("See All"),
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
                        if(isLoading) ...[
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        ] 
                        else
                        if(streams['podcast'].isEmpty) ...[
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.user,
                            ),
                          )
                        ]
                        else ...[
                          ...Factory(streams['podcast'])
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
                SizedBox(height: 20),
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Labels.primary(
                        "New Releases",
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),
                      GestureDetector(
                        onTap: () {
                          RouteGenerator.goto(NEW_RELEASE, {
                            "title": "New Releases",
                            "episodes": streams['release'] ?? []
                          });
                        },
                        child: Labels.secondary("See All"),
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
                        if(isLoading) ...[
                          PodcastShimmer(
                            type: 'grid',
                            length: 3
                          )
                        ] 
                        else
                        if(streams['release'].isEmpty) ...[
                          Container(
                            width: width - 40,
                            alignment: Alignment.center,
                            child: EmptyRecord(
                              icon: Iconsax.music,
                            ),
                          )
                        ]
                        else ...[
                          ...Factory(streams['release'])
                          .get(0, 5).map(
                                    (podcast) => /** */ PodcastTemplate(
                            type: 'grid',
                            episode: podcast,
                            podcasts: streams['release'],
                          ))
                        ]
                      ],
                    )
                  )
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
                            callback: callback
                          ))
                        ]
                      ],
                    ),
                  ),
                ),
                if(!isLoading && streams['playlist'].isNotEmpty)
                  ...streams['playlist'].entries.map( (playlist) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      SizedBox(
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Labels.primary(
                              playlist.key,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                            GestureDetector(
                              onTap: () {
                                RouteGenerator.goto(NEW_RELEASE, {
                                  "title": playlist.key,
                                  "episodes": playlist.value['episodes'].map(
                                    (e) => Episode.fromJson(e)).toList()
                                });
                              },
                              child: Labels.secondary("See All"),
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
                              if(playlist.value['episodes'].isEmpty)... [
                                EmptyRecord()
                              ] 
                              else ...[
                                ...Factory(playlist.value['episodes'])
                                .get(0, 5).map(
                                          (podcast) => /** */ PodcastTemplate(
                                  type: 'grid',
                                  episode: Episode.fromJson(
                                    podcast
                                  ),
                                  podcasts: playlist.value['episodes'].map(
                                    (e) => Episode.fromJson(e)).toList(   ),
                                ))
                              ]
                            ],
                          )
                        )
                      ),
                    ],
                  )).toList(),

                SizedBox(height: 20),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}