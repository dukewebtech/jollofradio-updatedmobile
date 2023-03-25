import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/screens/User/HomeScreen.dart';
import 'package:jollofradio/screens/User/LibraryScreen.dart';
import 'package:jollofradio/screens/User/PlaylistScreen.dart';
import 'package:jollofradio/screens/User/RadioScreen.dart';
import 'package:jollofradio/screens/User/SearchScreen.dart';

class UserLayout extends StatefulWidget {
  const UserLayout({ Key? key }) : super(key: key);

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> 
                                      with SingleTickerProviderStateMixin {
  int currentPage = 0 ;
  late TabController tabController = TabController(length: 5, vsync: this);

  void controller( int page ) {
    setState(() {
      currentPage = page;
    });
  }

  late List<Widget> screens = [
    HomeScreen(controller),
    LibraryScreen(controller),
    SearchScreen(controller),
    RadioScreen(controller),
    PlaylistScreen(controller)
  ];

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {

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
        child: BottomNavigationBar(
          currentIndex: currentPage,
          items: [
            BottomNavigationBarItem(
              label: "Discover",
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Iconsax.home_1
                ),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Iconsax.home_1
                ),
              )
            ),
            BottomNavigationBarItem(
              label: "My Library",
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
              label: "Search",
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Iconsax.search_normal_1
                ),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Iconsax.search_normal_1
                ),
              )
            ),
            BottomNavigationBarItem(
              label: "Radio",
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Iconsax.radio
                ),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Iconsax.radio
                ),
              )
            ),
            BottomNavigationBarItem(
              label: "Playlist",
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Iconsax.music_square
                ),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Icon(
                  Iconsax.music_square
                ),
              )
            ),
          ],

          onTap: (page) {
            setState(() => /* goto */ currentPage = /*redirect */ ( page ));
          },
          
        ),
      ),
    );
  }
}