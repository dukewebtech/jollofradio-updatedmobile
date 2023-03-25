import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/models/Playlist.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/User/PlaylistController.dart';
import 'package:jollofradio/config/services/controllers/User/StreamController.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/string.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PodcastTemplate extends StatefulWidget {
  final String type;
  final Episode episode;
  final bool compact;
  final Playlist? playlist;
  final bool onPlaylist;
  final dynamic callback;

  const PodcastTemplate({
    super.key,
    required this.type,
    required this.episode,
    this.playlist,
    this.onPlaylist = false,
    this.compact = false,
    this.callback
  });

  @override
  State<PodcastTemplate> createState() => _PodcastTemplateState();
}

class _PodcastTemplateState extends State<PodcastTemplate> {
  late User user;
  late Episode episode;
  Playlist? playlist;
  bool _fav = false;
  bool isSaving = false;
  bool showCreate = false;
  bool isVisible = true;
  dynamic _setState;
  String? selectedLabel;
  TextEditingController playlistName = TextEditingController();
  List<String> dropdown = [
    //
  ];

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    episode = widget.episode;
    _fav = episode.liked;

    if(widget
    .onPlaylist==true){
      playlist = widget.playlist;
    }

    dropdown 
    = user.playlist.map<String>((e)=>e['name']).toList();

    super.initState();
  }

  Future<void> _doSubscribe() async {
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
      await StreamController.create(data).then((status){
        if(liked && !status){
          setState(() => _fav = !_fav);
        }
      });
      return;
    // }
    
  }

  Future<void> _share() async {
    await Share.share(
      'Listen to: ${episode.title} on Jollof Radio', 
      subject: 'Listen to: ${
        episode.title
      } on Jollof Radio for FREE'
    );
  }

  Future<void> _savePlaylist() async {
    if(isSaving) return;
    _setState(() {
      isSaving = true;
    });

    final name = ( selectedLabel ?? playlistName.text );
    Map data = {
      'playlist_name': name,
      'episode_id': widget.episode.id
    };

    if(selectedLabel == null 
    && name.isEmpty){
      _setState(() => isSaving = false);
      Toaster.error("You have not selected a playlist");
      return;
    }

    await PlaylistController.create(data).then((created) 
    async{
      _setState(() => isSaving = false);
      if(!created){
        Toaster.error(
          "Oops! while saving playlist, please try again"
        );
      }
      Toaster.success("Episode added to playlist: $name");

      playlistName.clear(  );
      Navigator.pop(context);
    });
  }

  Future<void> _deleteItem(cb) async {
    Map data = {
      'playlist_id': playlist!.id,
      'episode_id': episode.id
    };

    Navigator.pop(context);
    await PlaylistController.remove(data).then((deleted){
      
      if(deleted){
        cb(episode, {
          "deleted": true
        });
      }

    });
  }

  Future<void> playlistModal() async {
    return showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {     
            _setState = setState;
            return AlertDialog(
              backgroundColor: AppColor.primary,
              title: Row(
                children: [
                  Icon(Iconsax.music, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Add to Playlist", style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  )),
                  Spacer(),
                  SizedBox(
                    width: 25,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: "Create New Playlist",
                      onPressed: () {
                        _setState((){
                          showCreate = !showCreate;
                        });
                      },
                      icon: Icon(
                        Iconsax.add, color: Colors.white
                      ),
                    ),
                  )
                ],
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if(!showCreate) ...[
                      SizedBox(height: 20),
                      select("Select a Playlist", dropdown),
                    ]
                    else ...[
                      SizedBox(height: 20),
                      Labels.secondary("Create a Playlist"),
                      Input.primary(
                        "Playlist Name",
                        leadingIcon: Icons.edit,
                        controller: playlistName,
                      ),
                    ],
                    SizedBox(height: 10),
                    Buttons.primary(
                      label: 
                      !isSaving ? "Add to Playlist" : "Saving...",
                      onTap: () => _savePlaylist(),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Future<void> deleteModal() async {
    return showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {     
            _setState = setState;
            return AlertDialog(
              backgroundColor: AppColor.primary,
              title: Row(
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Warning", style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  )),
                ],
              ),
              content: Text(
                "Are you sure you want to delete item from ${""
                }your playlist?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent
                  ),
                  onPressed: () {
                    
                    _deleteItem(widget.callback);
                  
                  }, 
                  child: Text("Yes", style: TextStyle(
                    color: Colors.red
                  ),)
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent
                  ),
                  onPressed: () {
                    //
                    Navigator.pop(context);
                    //                    
                  }, 
                  child: Text("No", style: TextStyle())
                ),
              ],
            );
          }
        );
      },
    );
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
              "channel": "podcast"
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
                  color: Color(0XFF0D1925),
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
               episode.creator.username(),
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
      return Container(
        width: double.infinity,
        height: 80,
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Color(0XFF12222D),
          borderRadius: BorderRadius.circular(5)
        ),
        child: GestureDetector(
          onTap: () => RouteGenerator.goto(TRACK_PLAYER, {
            "track": episode,
            "channel": "podcast"
          }),
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
                width: MediaQuery.of(context).size.width - 150,
                height: 70,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                            child: Labels.primary(
                              episode.title,
                              maxLines: 2,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              margin: EdgeInsets.only(bottom: 5)
                            ),
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(episode.creator.username(), style: TextStyle(
                                    color: Color(0XFF9A9FA3),
                                    fontSize: 12
                                  ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(episode.duration, style: TextStyle(
                                    color: Color(0XFF9A9FA3),
                                    fontSize: 10
                                  )),
                                ],
                              ),
                              Spacer(),
                              Container(
                                width: 85,
                                margin: EdgeInsets.only(left: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => _doSubscribe(),
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
                                    GestureDetector(
                                      onTap: () async {
                                        if(!widget.onPlaylist){
                                          await playlistModal(  );
                                          return;
                                        }
                                        deleteModal();
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
                                                  "channel": "podcast"
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
          "channel": "podcast"
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
                              Text(episode.creator.username(), style: TextStyle(
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

  Widget select(String name, List<String> items /** = [...i] **/ ) {
    return SizedBox(
      width: double.infinity,
      child: ButtonTheme(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors .red),
        padding: EdgeInsets.only(left: 50),
        child: DropdownButton(
          dropdownColor: AppColor.primary,
          underline: Container(
            height: 0.5,
            color: AppColor.secondary
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColor.secondary,
          ),
          value: selectedLabel,
          hint: Labels.secondary(name),
          items: items.map<DropdownMenuItem>((val)=> DropdownMenuItem
          <String>(
            value: val,
            child: Text(
              val, style: TextStyle(
                color: Colors.white,
                fontSize: 13
              )
            ),
          )).toList(),
          onChanged: (value) {
            _setState(() {
              selectedLabel = value;
            });
          },
        ),
      ),
    );
  }

}