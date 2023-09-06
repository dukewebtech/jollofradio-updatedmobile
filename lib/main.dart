import 'dart:io';
import 'package:jollofradio/config/services/core/NotificationService.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:jollofradio/config/themes/Stylesheet.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

// void main() => runApp(const MyApp());
Future main() async {
  //configure device & system properties
  WidgetsBinding widget = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
    widgetsBinding: widget
  );
  Firebase.initializeApp();

  //ensure device is init on "portraits"
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ])
  .then((_) async {
    AudioServiceHandler.init({
      'userAgent': "Jollofradio/1.0 (Linux;Android 12) - v2.0 player",
      'channelId': "com.jollofradio.app",
      'channelName': "Audio Service App",
    });
    NotificationService.initialize(
      sound: true
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => CreatorProvider()),
        ],
        child: const MyApp()
      )
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState(){

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Timer(Duration(milliseconds: 1000),() => FlutterNativeSplash.remove());
    
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) /*listener*/ {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.resumed:
        break;

      case AppLifecycleState.detached:
        audioHandler.stop();
        exit(0);
        // break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = true;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jollof Radio',
      theme: Stylesheet.lightTheme(),
      initialRoute: SPLASH,
      navigatorKey: navigator,
      onGenerateRoute: RouteGenerator.init,
      builder: (context, child) {
        final scaleSize = MediaQuery.of(context).textScaleFactor.clamp    (
          0.5, 1.0
        );

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: scaleSize),
          child: child!,
        );
      },
    );
  }
}