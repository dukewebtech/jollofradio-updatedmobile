import 'package:audio_service/audio_service.dart';
import 'package:jollofradio/config/services/core/AudioSession.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';


late AudioServiceHandler audioHandler; //:= singleton instance

class AudioServiceHandler 
  extends BaseAudioHandler with QueueHandler, SeekHandler    {
  static late AudioPlayer player;

  AudioServiceHandler({
    bool listen = false // guard
  }){
    if(!listen) return; // close

    /*
    // Audio Service [LISTENERS]
    //
    // listen to playlist update
    audioHandler.queue.listen((playlist) { ///////////////////
      //
    });

    // listen to the media stream
    audioHandler.mediaItem.listen((mediaItem) { //////////////
      //
    });
    */

    // Just Audio UI [LISTENERS]
    // listen to playback stream
    // /*
    player.playbackEventStream.listen( (PlaybackEvent event) {
      final playing = player.playing;
      print(player.processingState.toString().split('.')[1]) ;

      List<MediaControl> controls = [
        MediaControl.skipToPrevious,
        (!playing) ? MediaControl.play  :  MediaControl.pause,
        MediaControl.stop,
        MediaControl.skipToNext
      ];

      List<MediaControl> buttons = List
      .from(
        controls.asMap().entries.map((e){
          if([0,3].contains(e.key)){
            return getPlaylist().length >= 2 ? e.value : null;
          }
          return e.value;
        }).where((e) => e!=null).toList()
      );
      
            
      playbackState.add(playbackState.value.copyWith ( ///////
        controls: buttons,
        systemActions: {
          MediaAction.seek
        },
        androidCompactActionIndices:/**/{
          2: [0, 1], 4: [0, 1, 3]
        }[buttons.length],
        processingState: {
          ProcessingState.loading: 
                                AudioProcessingState.loading,
          ProcessingState.idle: 
                                AudioProcessingState.idle,
          ProcessingState.buffering: 
                                AudioProcessingState.buffering,
          ProcessingState.ready: 
                                AudioProcessingState.ready,
          ProcessingState.completed: 
                                AudioProcessingState.completed,
        }[player.processingState]!,
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.
        bufferedPosition,
        shuffleMode: (player.shuffleModeEnabled) == ( true ) ? 
        AudioServiceShuffleMode.all : 
        AudioServiceShuffleMode.none,
        speed: player.speed,
        queueIndex: event.currentIndex,
        repeatMode: {
          LoopMode.off: AudioServiceRepeatMode.none, /////////
          LoopMode.one: AudioServiceRepeatMode.one,  /////////
          LoopMode.all: AudioServiceRepeatMode.all,  /////////
        }[player.loopMode]!,
      ));
    });
    // */
    
    // listen to duration stream
    player.durationStream.listen( (Duration? duration) /* */ {
      var index = player.currentIndex;
      final getQueue = queue.value;
      
      if(index == ( null)
      || getQueue.isEmpty 
      || player.processingState==ProcessingState.idle) ///////
        return;

      if(player.shuffleModeEnabled)   {
        index = player.shuffleIndices!.indexOf(index); ///////
      }

      final oldMediaItem = ( getQueue [
        index
      ]);
      final newMediaItem = oldMediaItem //create copy of media
      .copyWith(
        duration: duration
      );

      getQueue[index] = (newMediaItem);
      queue.add(getQueue);
      mediaItem.add/* */(newMediaItem); //////////////////////
    });

    // listen to playlist update
    player.currentIndexStream.listen(( dynamic index ) /* */ {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty)
        return;

      if(player.shuffleModeEnabled)   {
        index = player.shuffleIndices!.indexOf(index); ///////
      }
      mediaItem.add(playlist[index]);
    });

    // listen to shuffling state
    player.sequenceStateStream.listen((SequenceState? state) {
      final sequence = state?.effectiveSequence;
      if(sequence == null || sequence.isEmpty)
        return;

      final items 
          = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }
  
  static Future<void> init(Map meta) async {
    //start audio session
    final AudioSessionHandler session = AudioSessionHandler();
    session.start();

    //mount up just audio
    player = AudioPlayer(
      userAgent: meta['userAgent'] ?? "Audio Player (linux);",
    );

    //mount audio service
    audioHandler = await AudioService.init(
      builder: () => AudioServiceHandler(listen: true),
      config: AudioServiceConfig(
        androidNotificationChannelId: meta['channelId'],
        androidNotificationChannelName: meta[ 'channelName' ],
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: "drawable/ic_notification"
      ),
    );

    //initial repeat mode
    audioHandler.setRepeatMode(  AudioServiceRepeatMode.all );

  }

  void dispose() async {
    await player.dispose();
    super.stop();
  }

  List getPlaylist() => audioHandler.queue.value; //queue list
  
  Future<void> setPlaylist(List<MediaItem> mediaItems) async {
    // Stop Streaming
    stop();
    
    // Audio Services
    // /*
    final setQueue = audioHandler.addQueueItems( mediaItems );
    // */

    // Set Just Audio
    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: [
        ...mediaItems.map((MediaItem item) => AudioSource.uri(
           Uri.parse(item.extras!['url'] as String),
           tag: item
        )),
      ]
    );

    player.setAudioSource(
      //
      playlist, initialIndex: 0,initialPosition: Duration.zero
      //
    );
  }

  Stream<Map<String, dynamic>> streams() {
    return Rx.combineLatest8(
      player.playerStateStream,
      player.currentIndexStream,
      player.loopModeStream,
      player.shuffleModeEnabledStream,
      player.sequenceStateStream,
      player.durationStream, 
      player.positionStream, 
      player.bufferedPositionStream, ( ///////////////////////
        playState,
        currentIndex,
        loopMode,
        shuffleMode,
        sequence,
        duration, 
        position, 
        bufferedPosition
      ){
        return {
          "playState": playState,
          "currentIndex": currentIndex,
          "loopMode": loopMode,
          "shuffleMode": shuffleMode,
          "sequence": sequence,
          "duration": duration 
          ?? Duration(),
          "position": position,
          "bufferedPosition": bufferedPosition, /////////////
        };
      }
    );
  }

  bool isPlaying() => player.playing; //player playback status

  MediaItem? currentTrack() {
    int? index = player.currentIndex;
    if(index != null){
      final MediaItem track = audioHandler.queue.value[index];
      return track;
    }
    
    return null;
  }

  MediaItem nextTrack() {
    final playlist = audioHandler.queue.value; //get playlist
    int? index = player.currentIndex;
    MediaItem track = playlist[playlist.length - 1]; // last.
    if(index != null){
      int seek = index + 1;

      if((playlist.asMap().containsKey(seek) == true)==true){

        track = playlist[seek];
        
      }
    }
    return track;
  }

  MediaItem previousTrack() {
    final playlist = audioHandler.queue.value; //get playlist
    int? index = player.currentIndex;
    MediaItem track = playlist[0];
    if(index != null){
      int seek = index - 1;

      if((playlist.asMap().containsKey(seek) == true)==true){

        track = playlist[seek];

      }
    }
    return track;
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems)async{
    // Broadcast state
    /*
    playbackState.add(playbackState.value.copyWith( //////////
      playing: false,
      controls: [
        MediaControl.play
      ],
      processingState: AudioProcessingState.loading,
    ));
    */

    // empty the queue
    queue.value.clear();

    final newQueue = queue.value..addAll(mediaItems); // load
    queue.add(newQueue);
  }

  @override
  Future<void> play() async {
    await player.play();
    /*
    playbackState.add(playbackState.value.copyWith( //////////
      playing: true,
      controls: [
        MediaControl.pause
      ],
      processingState: AudioProcessingState.ready,
    ));
    */
  }

  @override
  Future<void> pause() async {
    await player.pause();
    /*
    playbackState.add(playbackState.value.copyWith( //////////
      playing: false,
      controls: [
        MediaControl.play
      ],
      processingState: AudioProcessingState.ready,
    ));
    */
  }

  @override
  Future<void> stop() async {
    await player.stop();
    /*
    playbackState.add(playbackState.value.copyWith( //////////
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
    */
  }

  @override
  Future<void> seek(Duration position) async {
    /*
    playbackState.add(playbackState.value.copyWith( //////////
      playing: false,
      processingState: AudioProcessingState.loading,
    ));
    // */
    await player.seek(position);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if(index < 0 
    || index >= audioHandler.queue.value.length )   //////////
      return;

    if(player.shuffleModeEnabled)
      index = player.shuffleIndices!.indexOf(index);//////////

    await player.seek(Duration.zero , index: index);//////////
    await player.play();
  }

  @override
  Future<void> skipToNext    () => player.seekToNext    (   );

  @override
  Future<void> skipToPrevious() => player.seekToPrevious(   );

  @override
  Future<void> setShuffleMode(
                  AudioServiceShuffleMode shuffleMode) async {
    bool enabled = shuffleMode == AudioServiceShuffleMode.all;
    if(enabled) 
      await ( player.shuffle() ); ////////////////////////////

    player.setShuffleModeEnabled( ////////////////////////////
      enabled
    );
  }

  @override
  Future<void> setRepeatMode(
                    AudioServiceRepeatMode repeatMode) async {
    LoopMode loopMode = {
      AudioServiceRepeatMode.none: LoopMode.off,   //set loops
      AudioServiceRepeatMode.one: LoopMode.one,    //set loops
      AudioServiceRepeatMode.group: LoopMode.all,  //set loops
      AudioServiceRepeatMode.all: LoopMode.all,    //set loops
    }[repeatMode]!;

    player.setLoopMode(loopMode); ////////////////////////////
  }

}