import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/User/SubscriptionController.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/widget/Labels.dart';

class PlaylistTemplate extends StatefulWidget {
  final dynamic playlist;
  final Function(dynamic v)? callback;

  const PlaylistTemplate({
    super.key,
    required this.playlist,
    this.callback
  });

  @override
  State<PlaylistTemplate> createState() => _PlaylistTemplateState();
}

class _PlaylistTemplateState extends State<PlaylistTemplate> {
  final List<Function()> callbacks = [];

  final Map<String, IconData> icons = {
    'Unsubscribe': Iconsax.user_minus,
    'View Playlist': Iconsax.menu,
    'Edit Playlist': Iconsax.edit,
    'Delete Playlist': Iconsax.close_circle
  };
  

  final Map<bool, Map> popup = {
    true: <String, dynamic>{
      'Unsubscribe': (playlist, cb) async {

        cb(playlist);

        return await SubscriptionController.delete({
          'podcast_id': playlist.id
        });

      }
    },
    false: <String, dynamic>{
      // /*
      'View Playlist': (playlist, cb) async {

        Future((){
          cb(playlist, {
            'redirect': PLAYLIST_TRACK
          });
        });
        
      },
      'Edit Playlist': (playlist, cb) async {

        cb(playlist, {
          "edit": true
        });

      },
      // */
      'Delete Playlist': (playlist, cb) async {

        cb(playlist, {
          "sync": true
        });

      }
    }
  };

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isPodcast = false;

    try {
      if(widget.playlist.collection == null){
        throw Exception();
      }
    } catch(e){
      isPodcast = true;
    }
      
    return GestureDetector(
      onTap: () {
        if(!isPodcast){
          RouteGenerator.goto(PLAYLIST_TRACK, {
            "playlist": widget.playlist
          });
          return;
        }

        RouteGenerator.goto(PODCAST, {
          "playlist": widget.playlist
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10), //edge inset
        padding: EdgeInsets.fromLTRB(5,5,5,0), //edge inset
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          color: Color(0XFF0D1921),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 130,
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(5), //.5
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    width: double.infinity,
                    height: 130,
                    imageUrl: widget.playlist.logo,
                    placeholder: (context, url) {
                      return Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator()
                        )
                      );
                    },
                    errorWidget: (context, url, error) => Icon(
                      Icons.error
                    ),
                    fit: BoxFit.cover,
                  ),
                  
                  if(isPodcast && widget.playlist.latest)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 70,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green[800],
                        borderRadius: BorderRadius.circular(0)
                      ),
                      child: Text("New Episode", style: TextStyle(
                        fontSize: 10,
                        color: Colors.white
                      ),
                        textAlign: TextAlign.center
                      ),
                    ),
                  )

                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 110,
                    child: Labels.primary(
                      isPodcast ? 
                      widget.playlist.title : widget.playlist.name,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      margin: EdgeInsets.only(bottom: 3)
                    ),
                  ),
                  if(widget.callback!=null)
                  
                  PopupMenuButton(
                    color: AppColor.primary,
                    onSelected: (index) {

                      /*
                      var action = popup[isPodcast]!.firstWhere((e)
                      =>e.keys.first==index);

                      action[index]();
                      */
                      
                    },
                    itemBuilder: (context) {
                      return 
                      popup[isPodcast]!.entries.map<PopupMenuItem>(
                        (e){
                        String label = e.key;
                        return PopupMenuItem(
                          value: label,
                          onTap: () {

                            popup[isPodcast]!
                            [label](widget.playlist, widget.callback);

                          },
                          child: Row(
                            children: [
                              Icon(
                                icons[label], 
                                size: 14, 
                                color: Colors.white,
                              ),
                              SizedBox(width: 20),
                              Text(
                                label,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Icon(
                      Icons.more_horiz, color: Color(0XFF9A9FA3)
                    )
                  )
                ],
              ),
            ),
            Text(
              isPodcast ?
              "${widget.playlist.episodes.length} Episodes"  : //podcasts
              "${widget.playlist.collection.length} Collection", //playlist
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
}