import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AudioServiceHandler extends BaseAudioHandler 
with QueueHandler, SeekHandler {
  // static late AudioSession session;
  // static late AudioPlayer player;
  // static late AudioHandler audioService;

  // AudioServiceHandler(){
  //   final _player = AudioPlayer(
  //     userAgent: 'jollofradio/1.0 (Linux;Android 12) - v2.0',
  //   );
  // }

  static Future<void> init() async {

    //////////////////////////////////////////////////////////
    ///
    //start audio session
    final AudioSessionHandler session = AudioSessionHandler();
    // AudioServiceHandler.session = session;

    if(!await session.start()){

      //throw exception - The audio session refused connection
      
    }

    // audioService = await AudioService.init(
    //   builder: () => AudioServiceHandler(),
    //   config: AudioServiceConfig(
    //     androidNotificationChannelId: 'com.jollofradio.com',
    //     androidNotificationChannelName: 'Audio Service App',
    //     androidNotificationOngoing: true,
    //     androidStopForegroundOnPause: true,
    //     androidNotificationIcon: "ic_notification"
    //   ),
    // );

    //proceed
    
  }
}

class AudioSessionHandler {
  late AudioSession session;

  AudioSessionHandler(){
    start();
  }

  Future<bool> start() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    this.session = session;

    if(await session.setActive(true)) {
      
      // The audio session is started - start listen to events.
      listen();

      return true;

    } else {
      
      // The requests was denied and app should not play audio.

    }

    return false;
  }

  Future<void> listen() async {
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Another app started playing audio and we should 
            // duck.
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            // Another app started playing audio and we should 
            // pause.
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // The interruption has ended and we should unduck
            //
            break;
          case AudioInterruptionType.pause:
            // The interruption ended and we should resume api
            //
          case AudioInterruptionType.unknown:
            // The interruption ended but we should not resume
            //
            break;
        }
      }
    });

    session.devicesChangedEventStream.listen((event) {

      // The audio output device was changed - we can stop or
      // resume the player

    });

    session.becomingNoisyEventStream .listen((event) {

      // The user unplugged the headphones, so we should pause 
      // or lower the volume.

    });

    //////////////////////////////////////////////////////////

  }
}