import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/models/Playlist.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/Creator/EpisodeController.dart';
import 'package:jollofradio/config/services/controllers/User/PlaylistController.dart';
import 'package:jollofradio/config/services/controllers/User/StreamController.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/string.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Shared.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PodcastTemplate extends StatefulWidget {
  final String type;
  final Episode episode;
  final List? podcasts;
  final bool compact;
  final Playlist? playlist;
  final bool onPlaylist;
  final bool playing;
  final dynamic callback;
  final bool creator;

  const PodcastTemplate({
    super.key,
    required this.type,
    required this.episode,
    this.podcasts,
    this.playlist,
    this.onPlaylist = false,
    this.compact = false,
    this.callback,
    this.playing = false,
    this.creator = false,
  });

  @override
  State<PodcastTemplate> createState() => _PodcastTemplateState();
}

class _PodcastTemplateState extends State<PodcastTemplate> {
  late dynamic user;
  late Episode episode;
  List? podcasts;
  Playlist? playlist;
  bool _fav = false;
  bool isSaving = false;
  bool showCreate = false;
  bool isVisible = true;
  dynamic _setState;
  String? selectedLabel;
  TextEditingController controller = TextEditingController();
  List<String> dropdown = [];

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    episode = widget.episode;
    podcasts = widget.podcasts;
    _fav = episode.liked;

    if(widget
    .onPlaylist==true){
      playlist = widget.playlist;
    }
    if(user != null){
      dropdown 
      = (user as User).playlist.map<String>( (e) => e['name'] )
      .toList();
    }

    super.initState(); 
  }

  void callback(Map args /* ={} */) {
    _setState = args['state'];

    if(args['label'] != null) {
      selectedLabel = args['label'];
    }
  }

  Future<void> _doSubscribe() async {
    if(user == null) return ;
    
    bool liked = !_fav;
    Map data = {
      'episode_id': episode.id
    };

    setState(() {
      _fav = !_fav;
    });

    if(widget.callback != (null)) {
      if(!liked)
        widget.callback!(episode, {
          "unliked": true
        });
    }

    // if(liked){
      await StreamController.engage(data).then((status){
        if(liked && !status){
          setState(() => _fav = !_fav);
        }
      });
      return;
    // }
  }

  Future<void> _share() async {
    await Share.share(
      shareLink(
        type: 'episode', data: episode //share-able link
      )
    );
  }

  Future<void> _savePlaylist() async {
    if(isSaving) return;
    setState(() {
      isSaving = true;
    });

    final name = selectedLabel ?? controller.text.trim();
    Map data = {
      'playlist_name': name,
      'episode_id': episode.id
    };

    if(selectedLabel == null 
    && name.isEmpty){
      setState(() => isSaving = false);
      Toaster.error("You have not selected a playlist");
      return;
    }

    await PlaylistController.create(data).then((created) 
    async{
      setState(() => isSaving = false);
      if(!created){
        Toaster.error(
          "Oops! while saving playlist, please try again"
        );
      }
      Toaster.success("Episode added to playlist: $name");

      controller.clear();
      Navigator.pop(context);
    });
  }

  Future<void> _deleteCall(  ) async {

    _deleteItem(widget.callback);

  }

  Future<void> _deleteItem(cb) async {
    Navigator.pop(context);
    Toaster.info("Deleting resource... please hold on.");

    //episode
    if(playlist == null){
      await EpisodeController.delete(episode).then((res){

        if(res){
          return cb();
        }
        Toaster.info("Error occurred! please try again");
      });
      return;
    }

    //playlist
    Map data = {
      'playlist_id': playlist!.id,
      'episode_id': episode.id
    };

    await PlaylistController.remove(data).then((deleted){
      if(deleted){
        cb(episode, {
          "deleted": true
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var layout = Str.toUpperCase(
      widget.type
    );
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;

    if(layout == 'GRID'){
      return Container(
        width: 140,
        height: 170,
        margin: EdgeInsets.only(
          right: widget.compact ? 0 : 10,
        ),
        padding: EdgeInsets.fromLTRB(5,5,5,0),
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          color: Color(0XFF0D1921),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.hardEdge,
        child: GestureDetector(
          onTap: () {
            RouteGenerator.goto(TRACK_PLAYER, {
              "track": episode,
              "channel": "podcast",
              "playlist": podcasts
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: widget.compact ? 130 : 120,
                margin: EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(5)
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: <Widget>[
                    CachedNetworkImage(
                      width: double.infinity,
                      height: widget.compact ? 130 : 120,
                      imageUrl: episode.logo,
                      placeholder: (context, url) {
                        return Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator()
                          )
                        );
                      },
                      errorWidget: (context, url, error) =>  Icon(
                        Icons.error
                      ),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      left: 5,
                      bottom: 5,
                      child: Visibility(
                        visible: false,
                        child: Container(
                          height: 15,
                          constraints: const BoxConstraints(
                            minWidth: 30
                          ),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 4, right: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(95),
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: Text(episode.duration, style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                          ),
                            textAlign: TextAlign.center
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Labels.primary(
                episode.title,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                margin: EdgeInsets.only(bottom: 3)
              ),
              Text(
               episode.creator?.username() ?? '-',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12
                ),
              )
            ],
          ),
        ),
      );
    }

    if(layout == 'LIST'){
      return GestureDetector(
        onTap: () {
          RouteGenerator.goto(
            widget
            .creator ? CREATOR_EPISODE : TRACK_PLAYER, {
            "track": episode,
            "channel": "podcast",
            "playlist": podcasts,
            "callback": widget.callback
          });
        },
        child: Container(
          width: double.infinity,
          height: 80,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: !widget.playing ? Color(0XFF12222D) : 
            Color(0XFF12222D).withAlpha(50),
            borderRadius: BorderRadius.circular(5)
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(5)
                ),
                clipBehavior: Clip.hardEdge,
                child: CachedNetworkImage(
                  imageUrl: episode.logo,
                  placeholder: (context, url) {
                    return Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator()
                      )
                    );
                  },
                  errorWidget: (context, url, error) =>  Icon(
                    Icons.error
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width - 145,
                height: 70,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                            child: !widget.playing ? Labels.primary(
                              episode.title,
                              maxLines: 2,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              margin: EdgeInsets.only(bottom: 5)
                            ) : Labels.secondary(
                              episode.title,
                              maxLines: 2,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              margin: EdgeInsets.only(bottom: 5)
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: width - 240,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(episode.podcast, style: TextStyle(
                                      color: Color(0XFF9A9FA3),
                                      fontSize: 12,
                                    ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(episode.creator?.username() ?? '', 
                                    style: TextStyle(
                                      color: Color(0XFF9A9FA3),
                                      fontSize: 10
                                    ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              SizedBox(
                                width: !widget.creator 
                                ? 80 : 25,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    if(!widget.creator)
                                    GestureDetector(
                                      onTap: () async {
                                        if(user == null) {
                                          return Toaster.info(
                                            "You need to be signed in to like ${
                                              ""
                                            }this podcast"
                                          );
                                        }
                                        
                                        await _doSubscribe();

                                      },
                                      child: !_fav ? Icon(
                                        Iconsax.heart, 
                                        color: Color(0XFF575C5F),
                                        size: 18,
                                      ) : Icon(
                                        Iconsax.heart5, 
                                        color: AppColor.secondary,
                                        size: 18,
                                      ),
                                    ),
                                    if(!widget.creator)
                                    GestureDetector(
                                      onTap: () async {
                                        if(!widget.onPlaylist){
                                          if(user == null) {
                                            return Toaster.info(
                                              "You need to be signed in to add ${
                                                ""
                                              }track to playlist"
                                            );
                                          }
                                          
                                          return playlistModal(
                                            context: context,
                                            label: selectedLabel,
                                            playlist: dropdown,
                                            fn: _savePlaylist,
                                            callback: callback,
                                            controller: controller,
                                          );
                                        }
                                        
                                        return deleteModal(
                                          context: context,
                                          title: Message.build(Message.delete_item, {
                                            "item": "track",
                                            "source": "playlist"
                                          }),
                                          state: _setState,
                                          callback: _deleteCall
                                        );
                                      },
                                      child: Icon(
                                        !widget.onPlaylist 
                                              ? Iconsax.add : Iconsax.close_circle, 
                                        color: Color(0XFF575C5F),
                                        size: 18,
                                      ),
                                    ),
                                    PopupMenuButton(
                                      color: AppColor.primary,
                                      itemBuilder: (context) {
                                        return [
                                          PopupMenuItem(
                                            onTap: () {
                                              Future((){
                                                RouteGenerator.goto(TRACK_PLAYER, {
                                                  "track": episode,
                                                  "channel": "podcast",
                                                  "playlist": podcasts
                                                });
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.play_arrow, 
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 10),
                                                Text("Play", style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14
                                                )),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            onTap: () async => await _share(),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.share, 
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 10),
                                                Text("Share", style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14
                                                )),
                                              ],
                                            ),
                                          ),
                                          if(widget.creator)
                                          PopupMenuItem(
                                            onTap: () async {
                                              await Future((){ });
                                              deleteModal(
                                                context: context,
                                                title: Message
                                                  .build(Message.delete_item, {
                                                  "item": "episode",
                                                  "source": "podcast"
                                                }),
                                                state: _setState,
                                                callback: _deleteCall
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  size: 14,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 10),
                                                Text("Delete", style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14
                                                )),
                                              ],
                                            ),
                                          )
                                        ];
                                      },
                                      child: Icon(
                                        Icons.more_horiz, color: Color(0XFF9A9FA3)
                                      )
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    if(layout == 'PLAY'){
      return GestureDetector(
        onTap: () => RouteGenerator.goto(TRACK_PLAYER, {
          "track": episode,
          "channel": "podcast",
          "playlist": podcasts
        }),
        child: Visibility(
          visible: isVisible,
          child: Container(
            width: width / 1.3,
            height: double.infinity,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Color(0XFF0D1921)
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    imageUrl: episode.logo,
                    placeholder: (context, url) {
                      return Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          )
                        )
                      );
                    },
                    errorWidget: (context, url, error) =>  Icon(
                      Icons.error
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: (width / 1.3) - 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.title, 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(episode.creator?.username() ?? '', 
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0XFF9A9FA3)
                              )),
                              PopupMenuButton(
                                color: AppColor.primary,
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      onTap: () {
                                        Future((){
                                          ((cb)=>cb(episode))(widget.callback);
                                        });
                                        setState(() => isVisible = false);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Iconsax.play_remove,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text("Remove", style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14
                                          )),
                                        ],
                                      ),
                                    ),
                                  ];                                
                                },
                                child: Icon(
                                  Icons.more_horiz, color: /**/Color(0XFF9A9FA3)
                                )
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }

    //:layout == 'SLIM //
      return Container();
      
  }
}