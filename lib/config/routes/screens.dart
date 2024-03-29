import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/Constants.dart';

import 'package:jollofradio/screens/Layouts/Public.dart';
import 'package:jollofradio/screens/Layouts/User.dart';
import 'package:jollofradio/screens/Layouts/Creator.dart';
import 'package:jollofradio/screens/Layouts/WebView.dart';

import 'package:jollofradio/screens/Auth/AccountScreen.dart';
import 'package:jollofradio/screens/Auth/InterestScreen.dart';
import 'package:jollofradio/screens/Auth/ProfileScreen.dart';
import 'package:jollofradio/screens/Auth/SettingScreen.dart';
import 'package:jollofradio/screens/Auth/SiginInScreen.dart';
import 'package:jollofradio/screens/Auth/SignUpScreen.dart';
import 'package:jollofradio/screens/Auth/ForgotScreen.dart';
import 'package:jollofradio/screens/Auth/ConfirmScreen.dart';
import 'package:jollofradio/screens/Auth/ResetScreen.dart';
import 'package:jollofradio/screens/Auth/VerifyScreen.dart';

import 'package:jollofradio/screens/Creator/Podcast/PodcastScreen.dart';
import 'package:jollofradio/screens/Creator/Episode/CreateScreen.dart';
import 'package:jollofradio/screens/Creator/Episode/DetailScreen.dart';
import 'package:jollofradio/screens/Creator/Podcast/ManageScreen.dart';
import 'package:jollofradio/screens/Creator/Podcast/UploadScreen.dart';

import 'package:jollofradio/screens/User/Category/CategoryScreen.dart';
import 'package:jollofradio/screens/User/Category/SelectionScreen.dart';
import 'package:jollofradio/screens/User/HomeScreen.dart';
import 'package:jollofradio/screens/User/LibraryScreen.dart';
import 'package:jollofradio/screens/User/Notification/NotificationScreen.dart';
import 'package:jollofradio/screens/User/PlaylistScreen.dart';
import 'package:jollofradio/screens/User/Podcast/CreatorScreen.dart';
import 'package:jollofradio/screens/User/Podcast/EpisodeScreen.dart';
import 'package:jollofradio/screens/User/Podcast/LatestScreen.dart';
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

class ScreenProvider {
  static MaterialPageRoute route(String? route, data){

    switch(route){
      case SPLASH:
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case ONBOARDING:
        return MaterialPageRoute(builder: (context) => StartupScreen());

      case SIGNIN:
        return MaterialPageRoute(builder: (context) => SiginInScreen(
          email: data['email'],
        ));

      case SIGNUP:
        return MaterialPageRoute(builder: (context) => SiginUpScreen(
          userType: data['account'],
        ));

      case SIGNUP_ONBOARD:
        return MaterialPageRoute(builder: (context) => InterestScreen(
          type: data['type'],
          token: data['token'],
          email: data['email'],
          social: data['social']
        ));

      case FORGOT:
        return MaterialPageRoute(builder: (context) => ForgotScreen());

      case VERIFY:
        return MaterialPageRoute(builder: (context) => ConfirmScreen());

      case RESET_PASSWORD:
        return MaterialPageRoute(builder: (context) => ResetScreen(
          otp: data['otp'],
        ));

      case VERIFY_ACCOUNT:
        return MaterialPageRoute(builder: (context) => VerifyScreen(
          email: data['email'],
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

      // Public
      case PUBLIC:
        return MaterialPageRoute(builder: (context) => PublicLayout());

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
          title: data['title'],
          episodes: data['episodes'],
        ));

      case JOLLOF_LATEST:
        return MaterialPageRoute(builder: (context) => LatestScreen(
          title: data['title'],
          podcasts: data['podcasts'],
        ));

      case NEW_RELEASE:
        return MaterialPageRoute(builder: (context) => ReleaseScreen(
          title: data['title'],
          episodes: data['episodes'],
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
          podcast: data['podcast']
        ));

      case TRACK_PLAYER:
        return MaterialPageRoute(builder: (context) => PlayerScreen(
          track: data['track'],
          channel: data['channel'],
          playlist: data['playlist'],
        ));

      case RADIO_PLAYER:
        return MaterialPageRoute(builder: (context) => StreamScreen(
          radio: data['radio'],
          channel: data['channel'],
        ));

      case SETTINGS:
        return MaterialPageRoute(builder: (context) => SettingScreen(
          user: data['user'],
        ));

      case NOTIFICATION:
        return MaterialPageRoute(builder: (context) => NotificationScreen(
          user: data['user'],
          callback: data['callback'],
        ));

      // Creators
      case CREATOR_DASHBOARD:
        return MaterialPageRoute(builder: (context) => CreatorLayout());

      case CREATOR_PODCAST:
        return MaterialPageRoute(builder: (context) => PodcastScreen(
          title: data['title'],
          podcasts: data['podcasts'],
        ));

      case CREATOR_PODCAST_NEW:
        return MaterialPageRoute(builder: (context) => UploadScreen(
          type: data['type'],
          callback: data['callback'],
          podcast: data['podcast'],
        ));

      case CREATOR_PODCAST_ID:
        return MaterialPageRoute(builder: (context) => ManageScreen(
          podcast: data['podcast'],
        ));

      case CREATOR_EPISODE:
        return MaterialPageRoute(builder: (context) => DetailScreen(
          episode: data['track'],
          callback: data['callback'],
        ));

      case CREATOR_EPISODE_NEW:
        return MaterialPageRoute(builder: (context) => CreateScreen(
          type: data['type'],
          podcast: data['podcast'],
          episode: data['episode'],
          callback: data['callback'],
          history: data['history'] ?? 2
        ));

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