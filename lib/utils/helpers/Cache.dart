import 'dart:async';
import 'dart:convert';
import 'package:jollofradio/utils/helpers/Storage.dart';

class CacheStream {
  Map _streams = {};
  Timer? _timer;
  bool mounted = false;

  Future<void> mount(
    Map<String, Map<String, dynamic>> streams, Duration? 
    refresh)  async {
    _streams = streams;
    mounted = true;

    //register stream
    _store();

    //mount listeners
    if(refresh != null){
    _timer?.cancel();
    _timer = Timer.periodic(refresh, (tick) => _store());
    }
  }

  Future<void> unmount([Set? streams]) 
    async {
    List garbage = [];

    if(streams != null 
    && streams.isEmpty)
      _streams.forEach( (stream, dynamic source ) async {
        garbage.add(
          stream
        );
        Storage.delete(stream);
      });

    if(streams != null 
    && streams.isNotEmpty){
      for(var stream in streams){
        garbage.add(
          stream
        );
        Storage.delete(stream);
      }
    }

    print(garbage.toString()+' successfully unmounted!');

    mounted = false;
    _timer?.cancel();
  }

  Future<void> _store([String? cache]) async {
    if(!mounted 
    || _streams.isEmpty)
      return;

    await Future.forEach(_streams.entries, (obj) async {
      final stream = obj.key;
      final object = obj.value;
      
      if( cache != null && stream != cache)
        return;

      try {
        final data = await object['data']();
        final rules = object['rules'];

        //apply rules
        if(rules != null){
          if(await rules(data) as bool != true) return;
        }

        //stores data
        Storage.set(
          stream, json.encode(
            data
          )
        );
        print("'$stream' mounted on the cache loader.");

      } catch(e) {

        print( e.toString() );

      }
    });
  }

  Future<dynamic> stream(
    String stream, {bool? refresh, Function( )? fallback,
    dynamic callback}) async {
    dynamic data;

    try {
      if(refresh != null && refresh == (true)) // rebuild
        await _store(stream);

      final getStream = await Storage.get( stream, Map );
      if(getStream == null)
        throw Exception("stream '$stream' not mounted!");

      data = (getStream);

      if(callback != null){
        print("Initiating callback on stream: $stream.");

        data = await callback( // transforms the response
          data
        );
      }
    } catch(e) {
      print(e.toString());

      if(fallback != null){
        print("switching stream to fallback protocol..");

        data = await fallback();
      }
    }

    return data;

    /////////////////////////////////////////////////////
    
  }
  
}