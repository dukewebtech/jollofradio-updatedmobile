import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Playlist.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/config/services/controllers/User/PlaylistController.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Player.dart';

class PlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  const PlaylistScreen({super.key, required this.playlist});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late Playlist playlist;

  @override
  void initState() {
    playlist = widget.playlist;

    super.initState();
  }

  void callback(record, [Map? data]){
    data = data ?? {};

    if(data.containsKey ('deleted')){
      playlist.collection.removeWhere((e) => e.id == (record.id));

      CacheStream().mount({
        'playlist': {
          'data': () async {
            return await PlaylistController.index();
          },
          'rules': (data) => data.isNotEmpty,
        }
      }, null);
    }
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text(playlist.name),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: 0,
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: 20, 
                  right: 20
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(playlist.collection.isNotEmpty)
                      Row(
                        children: [
                          Labels.secondary(
                            "${playlist.collection.length} Collection",
                            margin: EdgeInsets.zero
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            if(playlist.collection.isEmpty)
                              Container(
                                width: double.infinity,
                                height: 300,
                                margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 4.4
                                ),
                                padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Iconsax.folder_2,
                                      size: 40,
                                      color: Color(0XFF9A9FA3),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      Message.no_playlist,
                                      style: TextStyle(color: Color(0XFF9A9FA3),
                                        fontSize: 14
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              )
                            else
                              ...playlist.collection.map((ep) => PodcastTemplate(
                                key: UniqueKey(),
                                type: 'list',
                                episode: ep,
                                podcasts: playlist.collection,
                                playlist: playlist,
                                onPlaylist: true,
                                callback: callback
                              ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Player()
          ],
        ),
      ),
    );
  }
}