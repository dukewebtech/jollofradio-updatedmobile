import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/screens/Auth/AccountScreen.dart';
import 'package:jollofradio/screens/Auth/InterestScreen.dart';
import 'package:jollofradio/screens/Auth/ProfileScreen.dart';
import 'package:jollofradio/screens/Auth/SettingScreen.dart';
import 'package:jollofradio/screens/Auth/SiginInScreen.dart';
import 'package:jollofradio/screens/Auth/SignUpScreen.dart';
import 'package:jollofradio/screens/Layouts/User.dart';
import 'package:jollofradio/screens/User/Category/CategoryScreen.dart';
import 'package:jollofradio/screens/User/Category/SelectionScreen.dart';
import 'package:jollofradio/screens/User/HomeScreen.dart';
import 'package:jollofradio/screens/User/LibraryScreen.dart';
import 'package:jollofradio/screens/User/Notification/NotificationScreen.dart';
import 'package:jollofradio/screens/User/PlaylistScreen.dart';
import 'package:jollofradio/screens/User/Podcast/CreatorScreen.dart';
import 'package:jollofradio/screens/User/Podcast/EpisodeScreen.dart';
import 'package:jollofradio/screens/User/Podcast/PlayerScreen.dart';
import 'package:jollofradio/screens/User/Podcast/PlaylistScreen.dart' as track;
import 'package:jollofradio/screens/User/Podcast/ReleaseScreen.dart';
import 'package:jollofradio/screens/User/Podcast/TrendingScreen.dart';
import 'package:jollofradio/screens/User/RadioScreen.dart';
import 'package:jollofradio/screens/User/Search/PlaylistResult.dart';
import 'package:jollofradio/screens/User/Search/PodcastResult.dart';
import 'package:jollofradio/screens/User/Search/ResultScreen.dart';
import 'package:jollofradio/screens/User/SearchScreen.dart';
import 'package:jollofradio/screens/User/Station/StationScreen.dart';
import 'package:jollofradio/screens/User/Station/StreamScreen.dart';
import 'package:jollofradio/screens/Welcome/SplashScreen.dart';
import 'package:jollofradio/screens/Error/ErrorScreen.dart';
import 'package:jollofradio/screens/Welcome/StartupScreen.dart';
import 'package:jollofradio/screens/Layouts/WebViewURI.dart';


class ScreenProvider {
  static MaterialPageRoute route(String? route, data){

    switch(route){
      case SPLASH:
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case ONBOARDING:
        return MaterialPageRoute(builder: (context) => StartupScreen());

      case SIGNIN:
        return MaterialPageRoute(builder: (context) => SiginInScreen());

      case SIGNUP:
        return MaterialPageRoute(builder: (context) => SiginUpScreen(
          userType: data['account'],
        ));

      case SIGNUP_ONBOARD:
        return MaterialPageRoute(builder: (context) => InterestScreen(
          token: data['token'],
        ));

      case PROFILE:
        return MaterialPageRoute(builder: (context) => ProfileScreen(
          user: data['user'],
        ));

      case PROFILE_EDIT:
        return MaterialPageRoute(builder: (context) => AccountScreen(
          user: data['user'],
          title: data['title'],
          mode: data['mode'],
        ));


      // User
      case DASHBOARD:
        return MaterialPageRoute(builder: (context) => UserLayout());

      case HOME:
        return MaterialPageRoute(builder: (context) => HomeScreen(
          null
        ));

      case LIBRARY:
        return MaterialPageRoute(builder: (context) => LibraryScreen(
          null
        ));

      case SEARCH:
        return MaterialPageRoute(builder: (context) => SearchScreen(
          null
        ));

      case RADIO:
        return MaterialPageRoute(builder: (context) => RadioScreen(
          null
        ));

      case STATIONS:
        return MaterialPageRoute(builder: (context) => StationScreen(
          title: data['title'],
          stations: data['stations'],
        ));

      case CATEGORY:
        return MaterialPageRoute(builder: (context) => CategoryScreen(
          categories: data['categories'],
        ));

      case CATEGORY_TRACK:
        return MaterialPageRoute(builder: (context) => SelectionScreen(
          category: data['category'],
        ));

      case TRENDING:
        return MaterialPageRoute(builder: (context) => TrendingScreen(
          episodes: data['episodes'],
        ));

      case NEW_RELEASE:
        return MaterialPageRoute(builder: (context) => ReleaseScreen(
          podcasts: data['podcasts'],
        ));

      case PLAYLIST:
        return MaterialPageRoute(builder: (context) => PlaylistScreen(
          null
        ));

      case SEARCH_PAGE:
        return MaterialPageRoute(builder: (context) => ResultScreen(
          query: data['query']
        ));

      case SEARCH_PODCAST:
        return MaterialPageRoute(builder: (context) => PodcastResult(
          podcasts: data['podcasts']
        ));

      case SEARCH_PLAYLIST:
        return MaterialPageRoute(builder: (context) => PlaylistResult(
          playlist: data['playlist']
        ));

      case PLAYLIST_TRACK:
        return MaterialPageRoute(builder: (context) => track.PlaylistScreen(
          playlist: data['playlist'],
        ));

      case CREATOR_PROFILE:
        return MaterialPageRoute(builder: (context) => CreatorScreen(
          creator: data['creator']
        ));

      case PODCAST:
        return MaterialPageRoute(builder: (context) => EpisodeScreen(
          playlist: data['playlist']
        ));

      case TRACK_PLAYER:
        return MaterialPageRoute(builder: (context) => PlayerScreen(
          track: data['track'],
          channel: data['channel'],
        ));

      case RADIO_PLAYER:
        return MaterialPageRoute(builder: (context) => StreamScreen(
          radio: data['radio'],
          channel: data['channel'],
        ));

      case SETTINGS:
        return MaterialPageRoute(builder: (context) => SettingScreen());

      case NOTIFICATION:
        return MaterialPageRoute(builder: (context) => NotificationScreen(
          user: data['user'],
        ));


      // Creators
      //

      case WEBVIEW:
        return MaterialPageRoute(builder: (context) => WebViewScreen(
          url: data['url'],
          title: data['title'],
          file: data['file'],
          navigationDelegate: data['callback'],
          onClose: data['onClose'],
        ));

      default:
        return MaterialPageRoute(builder: (context) => ErrorScreen(code: 
            404
          )
        );
    }
  }
}