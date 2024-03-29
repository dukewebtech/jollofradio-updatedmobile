import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/models/Station.dart';
import 'package:jollofradio/config/services/controllers/User/StreamController.dart';
import 'package:jollofradio/config/services/controllers/User/SubscriptionController.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/screens/Layouts/Templates/Radio.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatefulWidget {
  static String? page;
  final List? playlist;
  final Function(int page)? tabController;
  const LibraryScreen(
    this.tabController, {this.playlist, super.key}
  );

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> 
  with TickerProviderStateMixin {
  late User user;
  late TabController tabController;
  CacheStream cacheManager = CacheStream();
  late String? page;
  late List? playlist;
  Map tabs = {
    "Subscribed": 0,
    "Liked": 1,
    "Stations": 2,
  };
  bool isLoading = true;
  late Map subscriptions;
  List stations = [];

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    super.initState();

    tabController = TabController(
      initialIndex: 0,
      length: 3, 
      vsync: this
    );
    page = LibraryScreen.page;
    playlist = widget.playlist;

    if(page != null){
      tabController.animateTo(tabs[page]);
      LibraryScreen.page = null;
    }

    //cache manager
    (() async {
      await cacheManager.mount({
        'streams': {
          'data': () async {
            return await StreamController.index(); ////////////
          },
          'rules': (data){
            return data['trending'].isNotEmpty;
          },
        },
        'subscriptions': {
          'data': () async {
            return await SubscriptionController.index(); //////
          },
          'rules': (data){
            return data['status'] == 200;
          },
        }
      }, null);

      getFavorites();
      getSubscription();

    }());
  }

  Future<dynamic> getFavorites() async {
    await Storage.get('favRadio',Map).then((stations)  async  {
      if(stations == null)
        return;

      setState(() { 
        this.stations = stations.map((dynamic station) /* */  {
          return Station.fromJson(station);
        }).toList();
      });
    });
  }

  Future<void> getSubscription() async {
    final streams = await cacheManager.stream( ////////////////
      'streams', 
      fallback: () async {
        return StreamController.index();
      },
      callback: StreamController.construct
    );
    final subscriptions = await cacheManager.stream( //////////
      'subscriptions', 
      fallback: () async {
        return SubscriptionController.index();
      },
      callback: SubscriptionController.construct
    );

    this.subscriptions = subscriptions;
    this.subscriptions['likes'] = ( streams['likes'] as List );

    setState(() {
      playlist =  ( playlist ?? this.subscriptions ['likes'] );
      isLoading = false;
    });
  }

  void callback(resource, [Map? data]){
    data = data ?? {};

    if(data.containsKey ('deleted')){
      subscriptions
      ['podcasts'].removeWhere((e) => e.id == ( resource.id ));
    }

    if(data.containsKey ('unliked')){
      subscriptions
      ['likes']   .removeWhere((e) => e.id == ( resource.id ));
    }

    if(data.containsKey ('station')){
      stations    .removeWhere((e) => e.id == ( resource.id ));
    }

    // if(data.containsKey ('mounted')){
      cacheManager.mount({
        'streams': {
          'data': () async {
            return await StreamController.index(); ////////////
          },
          'rules': (data){
            return data['trending'].isNotEmpty;
          },
        },
        'subscriptions': {
          'data': () async {
            return await SubscriptionController.index(); //////
          },
          'rules': (data){
            return data['status'] == 200;
          },
        }
      }, null);
    // }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Color(0XFF0D1921),
                borderRadius: BorderRadius.circular(5)
              ),
              child: TabBar(
                controller: tabController,
                indicator: BoxDecoration(
                  color: Color(0XFF030F18),
                  borderRadius: BorderRadius.circular(5)
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Color(0XFF575C5F),
                tabs: [
                  ...tabs.entries.map<Tab>((tab) {
                    return Tab(child: Text(tab.key));
                  })
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        if(isLoading || subscriptions['podcasts'].isEmpty) ...[
                          Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 3.3
                            ),
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                            child: Column(
                              children: <Widget>[
                                if(isLoading)
                                  Center(
                                    child: const CircularProgressIndicator(),
                                  )
                                else
                                Column(
                                  children: <Widget>[
                                    Icon(
                                      Iconsax.menu,
                                      size: 40,
                                      color: Color(0XFF9A9FA3),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      Message.no_activity,
                                      style: TextStyle(color: Color(0XFF9A9FA3),
                                        fontSize: 14
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ]
                        else ...[
                          FadeIn(
                            child: GridView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              gridDelegate: 
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 100 / 125,
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                              ),
                              physics: ScrollPhysics(
                                parent: NeverScrollableScrollPhysics(parent: null)
                              ),
                              itemCount: subscriptions['podcasts'].length,
                              itemBuilder: (context, index){
                                return PlaylistTemplate(
                                  playlist: subscriptions['podcasts'][index],
                                  callback: callback,
                                );
                              }
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        if(isLoading || subscriptions['likes'].isEmpty) ...[
                          Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 3.3
                            ),
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                            child: Column(
                              children: <Widget>[
                                if(isLoading)
                                  Center(
                                    child: const CircularProgressIndicator(),
                                  )
                                else
                                Column(
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
                                      style: TextStyle(color: Color(0XFF9A9FA3),
                                        fontSize: 14
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ]
                        else ...[
                          FadeIn(
                            child: Column(
                              children: <Widget>[
                                ...subscriptions['likes'].map((ep) => PodcastTemplate(
                                  key: UniqueKey(),
                                  type: 'list',
                                  episode: ep,
                                  podcasts: playlist,
                                  callback: callback
                                ))
                              ],
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        if(isLoading || stations.isEmpty) ...[
                          Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 3.3
                            ),
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                            child: Column(
                              children: <Widget>[
                                if(isLoading)
                                  Center(
                                    child: const CircularProgressIndicator(),
                                  )
                                else
                                Column(
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
                                      style: TextStyle(color: Color(0XFF9A9FA3),
                                        fontSize: 14
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ]
                        else ...[
                          FadeIn(
                            child: Column(
                              children: <Widget>[
                                ...stations.map((dynamic station) => RadioTemplate(
                                  key: UniqueKey(),
                                  station: station,
                                  callback: callback,
                                ))
                              ],
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}