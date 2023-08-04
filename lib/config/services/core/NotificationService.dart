// ignore_for_file: avoid_print
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
    flutterLocalNotification = FlutterLocalNotificationsPlugin();

  static Future<void> initialize({
    bool sound = false
  }) async {
    Storage.set('_nSound', sound);
    
    AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings(
      '@drawable/ic_notification'
    );

    DarwinInitializationSettings iosInitializationSettings /**/ =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {
        //
      },
    );

    final InitializationSettings initializationSettings = 
    InitializationSettings(
      iOS: iosInitializationSettings,
      android: androidInitializationSettings
    );

    await flutterLocalNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (dynamic notification) {
        //
      },
    );


    //Background
    FirebaseMessaging.onBackgroundMessage(backgroundMsgHandler);


    //onLaunch
    /**
     * When the app is completely closed (not in the background) 
     * and opened directly from the push notification
     */
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      print('getInitialMessage data: ${event?.data}');
    });


    //onMessage
    /**
     * When the app is open and it receives a push notification
     */
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showNotification(message);
    });
    

    //onResume
    /**
     * When the app is in the background and is opened directly 
     * from the push notification.
     */
    FirebaseMessaging.onMessageOpenedApp.listen( (RemoteMessage 
    message) {
      print('onMessageOpenedApp data: ${message.data}');
    });
  }

  static Future<String> getToken() async {
    var token = await FirebaseMessaging.instance.getToken().then(
      (token) => token);

      return token ?? "";
  }

  static Future<dynamic> notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        "Jollof Radio",
        "Jollof Radio",
        priority: Priority.high,
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        largeIcon: DrawableResourceAndroidBitmap( //////////////
          "ic_notification"
        ),
        styleInformation: MediaStyleInformation ( //////////////
          htmlFormatContent: true,
          htmlFormatTitle: true,
        ),
        playSound: true,
      ),
      iOS: DarwinNotificationDetails()
    );
  }

  static Future showNotification(dynamic message) async {
    NotificationDetails notification=await notificationDetails(
      //
    );

    if(message is Map){
      message = ( message /*local map*/ );

      await flutterLocalNotification.show(
          message.hashCode,
          message['title'],
          message['body'],
          notification,
          // payload: message.data["message"] //additional log
      );
      return;
    } else {
      message = ( message.notification! );

      await flutterLocalNotification.show(
          message.hashCode,
          message.title,
          message.body,
          notification,
          // payload: message.data["message"] //additional log
      );
    }
  }
  
  static Future<void> subscribe (String topic) async {
    print("Subscribing to $topic...");

    await FirebaseMessaging.instance.subscribeToTopic (
      topic
    )
    .then((value) => {
      print ("Successfully subscribed to this Topic: $topic.")
    });
  }

  static Future<void> unsubscribe(String topic) async {
    print("Unsubscribing from $topic...");

    await FirebaseMessaging.instance.unsubscribeFromTopic(
      topic
    )
    .then((value) => {
      print ("Successfully detached from this Topic: $topic.")
    });
  } 
}

Future backgroundMsgHandler(RemoteMessage message) async {
  bool sound = await Storage.get ('_nSound', bool) ?? false;
  FlutterTts flutterTts = FlutterTts(
    //
  );
  flutterTts.setLanguage( "en-GB" ) ;

  if(sound){
    flutterTts.speak(message.notification!.body.toString());
  }
  
  if (message.notification == null) {
    NotificationService.showNotification(message); //invoke
  }

  return Future<void>.value();  // returning a null callback
}