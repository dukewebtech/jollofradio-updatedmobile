import 'package:audio_session/audio_session.dart';
import 'package:jollofradio/config/services/core/AudioService.dart';


class AudioSessionHandler {
  late AudioServiceHandler player;
  late AudioSession session;

  Future<bool> start([AudioSessionConfiguration? config])async{
    
    final session = await AudioSession.instance ; /////////////
    await session.configure(
      config ?? AudioSessionConfiguration.music() /////////////
    );

    player = AudioServiceHandler(   ) ;
    this.session = session;

    if(await session.setActive(true)) {
      
      // The audio session is started - start listen to events.
      listen();

      print('started listening on audio session.');

      return true;

    } else {
      print('fail to listen to the audio session');
      
      // The requests was denied and app should not play audio.

    }

    return false;
  }

  Future<void> listen() async {
    session.interruptionEventStream.listen( ( event )  async {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Another app started playing audio and we should 
            // duck
            await player.pause();
            break;

          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            // Another app started playing audio and we should 
            // pause.
            await player.pause();
            break;
        }
      } else {

        switch (event.type) {
          case AudioInterruptionType.duck:
            // The interruption has ended and we should unduck
            // await player.play();
            break;

          case AudioInterruptionType.pause:
            // The interruption ended and we should resume api
            // await player.play();
            break;

          case AudioInterruptionType.unknown:
            // The interruption ended but we should not resume
            await player.stop();
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