import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/screens/Public/HomeScreen.dart';
import 'package:jollofradio/screens/Public/RadioScreen.dart';
import 'package:jollofradio/screens/Public/SearchScreen.dart';
import 'package:jollofradio/widget/Player.dart';

class PublicLayout extends StatefulWidget {
  const PublicLayout({ Key? key }) : super(key: key);

  @override
  State<PublicLayout> createState() => _PublicLayoutState();
}

class _PublicLayoutState extends State<PublicLayout> 
                                      with SingleTickerProviderStateMixin {
  int currentPage = 0 ;
  late TabController tabController = TabController(length: 5, vsync: this);

  void controller( int page ) {
    setState(() {
      currentPage = page;
    });
  }

  late List<dynamic> screens = [
    HomeScreen(controller),
    null,
    SearchScreen(controller),
    RadioScreen(controller),
    null,
  ];
    
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
              if(screens[page] == null){
                signInDialog();
                return;
              }
              
              setState(() => /* goto */ currentPage = /*redirect */ ( page ));
            },
          ),
        ),
      ),
    );
  }

  Future signInDialog() async {
    return showDialog(
      context: context, 
      builder: (context) {
        return FadeInUp(
          child: Center(
            child: Container(
              width: 300,
              height: 280,
              decoration: BoxDecoration(
                color: AppColor.primary,
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/splash/logo_dark.png"//set background cover
                  ),
                  opacity: 0.2,
                  fit: BoxFit.cover
                ),
                borderRadius: BorderRadius.circular(10)
              ),
              clipBehavior: Clip.hardEdge,
              child: Scaffold(
                backgroundColor: AppColor.primary.withAlpha(50),
                body: Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Labels.primary(
                        "Sign In", 
                        fontSize: 25, 
                        fontWeight: FontWeight.bold
                      ),
                      Labels.secondary(
                        "To manage all your services with a personalized ${ //
                          ""
                        } account. Signup is free and takes less than 60 ${ //
                          ""
                        }seconds 😉",
                        fontSize: 14,
                        maxLines: 3
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Buttons.primary(
                        label: "Create a free account",
                        onTap: () {
                          Navigator.pop(context);
                          RouteGenerator.goto(ONBOARDING); // redirect signup
                        },
                      ),
                      SizedBox(
                        height: 20,
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.loose,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: -10,
                              child: Labels.secondary(
                                "Signin",
                                onTap: () {
                                  Navigator.pop(context);
                                  RouteGenerator.goto(SIGNIN); ///////////////
                                }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),    
            ),
          ),
        );
      },
    );
  }
}