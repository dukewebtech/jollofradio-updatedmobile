import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/User/PlaylistController.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatefulWidget {
  final Function(int page)? tabController;
  const PlaylistScreen(this.tabController, {super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late User user;
  bool isLoading = true;
  late List playlist;
  bool isEdit = false;
  int currentId = 0;
  bool isSaving = false;
  dynamic _setState;
  TextEditingController playlistName = TextEditingController();
  CacheStream cacheManager = CacheStream();

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    super.initState();

    //cache manager
    (() async {
      await cacheManager.mount({
        'playlist': {
          'data': () async {
            return await PlaylistController.index();
          },
          // 'rules': (data) => data.isNotEmpty,
        }
      }, null);

      getPlaylists();

    }());
  }

  Future<void> getPlaylists([cache]) async {
    final playlist = await cacheManager.stream( ///////////////
      'playlist',
      refresh: cache,
      fallback: () async {
        return PlaylistController.index();
      },
      callback: PlaylistController.construct
    );

    this.playlist = playlist;

    // if(cache != null && cache==false)
    //   return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _savePlaylist() async {
    if(isSaving) return;

    _setState(() {
      isSaving = true;
    });

    Map data = {
      'playlist_id': currentId,
      'playlist_name': playlistName.text
    };

    final name = data['playlist_name'];

    if(name.isEmpty){
      _setState(() => isSaving = false);
      return Toaster.error("You have not enter playlist name");
    }

    if(!isEdit){
    await PlaylistController.create(data).then((created) async{
      _setState(() => isSaving = false);
      if(!created){

        Toaster.error("Oops! error occured, please try again");
        return;

      }

      Toaster.success("Playlist: $name successfully created!");
      getPlaylists(true);

      playlistName.clear(  );
      Navigator.pop(context);
    });
      return;
    }

    await PlaylistController.update(data).then((updated) async{
      _setState(() => isSaving = false);
      if(!updated){

        Toaster.error("Oops! error occured, please try again");
        return;

      }

      Toaster.success("Playlist: $name successfully updated!");
      
      getPlaylists(true);

      playlistName.clear(  );
      Navigator.pop(context);
    });
  }

  void callback(playlist, [Map? data]) 
  async {
    data = data ?? {};

    if(data.containsKey ('sync')){
      await PlaylistController.delete(playlist.id); //spooling
      Toaster.info(
        "Deleting playlist... please wait."
      );
      this.playlist.removeWhere((e) => e.id == (playlist.id));

      getPlaylists(true);
    }

    if(data.containsKey ('edit')){
      setState(() {
        isEdit = true;
        currentId = playlist.id;
        playlistName.text = playlist.name;
      });

      Future(() => _invokeDialog( ));
      return;
    }

    if(data.containsKey ('redirect')){
      RouteGenerator.goto(
        data['redirect'], {
        "playlist": playlist
      });
      return;
    }

    setState(() {
      /*
      this.playlist.removeWhere((e) => e.id == (playlist.id));
      */
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: AppBar().preferredSize.height + 00,
          left: 20, 
          right: 20
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if(isLoading) ...[
                          Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 2.6
                            ),
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: const CircularProgressIndicator(),
                                )
                              ],
                            ),
                          )
                        ]
                        else ...[
                          if(playlist.isEmpty)
                            Container(
                              height: 300,
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 3.6
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
                            FadeIn(
                              child: GridView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 100 / 125,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                ),
                                physics: 
                                ScrollPhysics(parent: NeverScrollableScrollPhysics(  )),
                                itemCount: playlist.length,
                                itemBuilder: (context, index){
                                  return PlaylistTemplate(
                                    playlist: playlist[index],
                                    callback: callback,
                                  );
                                }
                              ),
                            ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: !isLoading,
              child: Positioned(
                right: -5,
                bottom: 20,
                child: FadeInRight(
                  child: FloatingActionButton(
                    tooltip: "Create Playlist",
                    onPressed: () async {
                      setState(() => isEdit = false);
                      playlistName.clear();
                      _invokeDialog();
                    },
                    child: Icon(
                      Icons.add,
                      color: AppColor.secondary,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  dynamic _invokeDialog() async {
    final title = !isEdit ? 'New Playlist' : 'Edit Playlist';
    final action = !isEdit ? 'Create Playlist' : 'Save Playlist';

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
                  Icon(Iconsax.folder_2, color: Colors.white),
                  SizedBox(width: 10),
                  Text(title, style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  )),
                ],
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Input.primary(
                      "Playlist Name",
                      leadingIcon: Icons.edit,
                      controller: playlistName,
                    ),
                    SizedBox(height: 10),
                    Buttons.primary(
                      label: !isSaving ? action : "Saving... ",
                      onTap: () => _savePlaylist(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}