import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/screens/Creator/HomeScreen.dart';
import 'package:jollofradio/screens/Creator/PodcastScreen.dart';
import 'package:jollofradio/screens/Creator/SubscrScreen.dart';
import 'package:jollofradio/screens/Creator/AdvertScreen.dart';
import 'package:jollofradio/screens/Creator/EpisodeScreen.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/widget/Player.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:provider/provider.dart';

class CreatorLayout extends StatefulWidget {
  const CreatorLayout({ Key? key }) : super(key: key);

  @override
  State<CreatorLayout> createState() => _CreatorLayoutState();
}

class _CreatorLayoutState extends State<CreatorLayout> 
                                      with SingleTickerProviderStateMixin {
  int currentPage = 0 ;
  late TabController tabController = TabController(length: 5, vsync: this);
  late Timer socket;
  CacheStream cacheManager = CacheStream();

  void controller( int page ) {
    setState(() {
      currentPage = page;
    });
  }

  late List<Widget> screens = [
    HomeScreen(),
    PodcastScreen(),
    SubscriberScreen(),
    AdvertScreen(),
    EpisodeScreen(),
  ];

  @override
  void initState() {
    socket = Timer.periodic(Duration(seconds: 60), (Timer ticker)  async {
      var user = await Storage.get('user');
      if(user == null) return;

      Map data = {
        'userType': 'creator'
      };
      await AuthController.service(data)
      .then((data) async {
        if(data.isEmpty) return;

        var user = data['user'];
        Provider.of<CreatorProvider>(context, listen: false).login( user );
        
        /*
        cacheManager.unmount();
        cacheManager.mount({
          'streams': {
            'data': () async {
              return data['streams'];
            },
            'rules': (data){
              return data['trending'].isNotEmpty;
            },
          },
          'category': {
            'data': () async { },
            'rules': (data) => data.isNotEmpty,
          }
        });
        */
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    socket.cancel();
    super.dispose();
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: WillPopScope(
        onWillPop: () async {
          if(currentPage > 0){
            setState(() => currentPage = 0); //redirect to the: homescreen
            return false;
          }
          return true;
        },
        child: screens[currentPage],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          color: Color(0XFF051724),
          border: Border(
            top: BorderSide(
              color: Color(0XFF223337)
            )
          )
        ),
        child: Player(
          child: BottomNavigationBar(
            currentIndex: currentPage,
            items: [
              BottomNavigationBarItem(
                label: "Dashboard",
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.graph
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.graph
                  ),
                )
              ),
              BottomNavigationBarItem(
                label: "Podcasts",
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.music_library_2
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.music_library_2
                  ),
                )
              ),
              BottomNavigationBarItem(
                label: "Subscribers",
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.people5
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.people5
                  ),
                )
              ),
              BottomNavigationBarItem(
                label: "Monetization",
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.money
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.money
                  ),
                )
              ),
              BottomNavigationBarItem(
                label: "Episodes",
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.menu
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Icon(
                    Iconsax.menu
                  ),
                )
              ),
            ],
            onTap: (page) {
              setState(() => /* goto */ currentPage = /*redirect */ ( page ));
            },
          ),
        ),
      ),
    );
  }
}