import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/User.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/SearchController.dart';
import 'package:jollofradio/config/services/controllers/User/PlaylistController.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Creator.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/screens/Layouts/Templates/Podcast.dart';
import 'package:jollofradio/utils/helpers/Factory.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatefulWidget {
  final String query;
  const ResultScreen({super.key, required this.query});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late User user;
  bool isLoading = true;

  TextEditingController search = TextEditingController();
  Map results = {};
  List _folders = [];
  List playlist = [];
  List podcasts = [];
  List creators = [];

  @override
  void initState() {
    var auth = Provider.of<UserProvider>(context,listen: false);
    user = auth.user;

    search.text = widget.query;

    _doSearch(
      search.text
    );

    super.initState();
  }

  Future<void> _doSearch(String query) async {
    setState(() {
      isLoading = true;
    });

    final results = await SearchController.search( ( query ) );
    this.results = results;

    playlist = Factory(
      results['playlist']
    ).get(0,3);
    podcasts = Factory(
      results['podcasts']
    ).get(0,3);
    creators = Factory(
      results['creators']
    ).get(0,7);

    setState(() {
      isLoading = false;
    });
  }

  @Deprecated('Function is dead as record is in search results')
  Future<void> getPlaylists() async {

    final playlist = await PlaylistController.index(); //loading
    _folders = playlist;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: 0,
          left: 20, 
          right: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Input.primary(
                    "What do you want to listen to?",
                    controller: search,
                    leadingIcon: Iconsax.search_normal,
                    onSubmit: (value){
                      
                      if(value.isNotEmpty) _doSearch(value);
                    }
                  ),
                  Positioned(
                    right: 5,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        if(search.text.isNotEmpty)
                        _doSearch(search.text);
                        
                      }, 
                      icon: Icon(
                        Iconsax.arrow_right_1,
                        size: 18,
                        color: Colors.white54,
                      )
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              if(isLoading) ...[
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 3.6
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
                if(playlist.
                isEmpty && podcasts.isEmpty && creators.isEmpty) ...[
                  Container(
                    height: 300,
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 6.6
                    ),
                    padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Iconsax.search_favorite,
                          size: 40,
                          color: Color(0XFF9A9FA3),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          Message.no_data,
                          style: TextStyle(color: Color(0XFF9A9FA3),
                            fontSize: 14
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                ]
                else ...[
                  if(podcasts.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Labels.primary(
                          "Top Results",
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                        if(results['podcasts'].length > 3)
                        GestureDetector(
                          onTap: () {
                            RouteGenerator.goto(SEARCH_PODCAST, {
                              "podcasts": results['podcasts']
                            });
                          },
                          child: Labels.secondary(
                            "See More"
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 05),
                    Column(
                      children: [
                        ...podcasts.map((episode) => PodcastTemplate(
                          type: "LIST",
                          episode: episode,
                        ))
                      ],
                    ),
                    SizedBox(height: 20),
                  ],

                  if(playlist.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Labels.primary(
                          "Podcasts",
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                        if(results['playlist'].length > 3)
                        GestureDetector(
                          onTap: () {
                            RouteGenerator.goto(SEARCH_PLAYLIST, {
                              "playlist": results['playlist']
                            });
                          },
                          child: Labels.secondary(
                            "See More"
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 05),
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ...playlist.map((playlist) => Container(
                              width: 145,
                              height: 200,
                              margin: EdgeInsets.only(right: 10),
                              child: PlaylistTemplate(
                                playlist: playlist,
                              ),
                            ))
                          ]
                        )
                      )
                    ),
                    SizedBox(height: 20),
                  ],

                  if(creators.isNotEmpty) ...[
                    Labels.primary(
                      "Creators",
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    SizedBox(height: 05),
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ...creators.map((creator) => CreatorTemplate(
                              creator: creator,
                            ))
                          ]
                        )
                      )
                    ),
                    SizedBox(height: 20)
                  ]
                ]
              ]
            ],
          ),
        ),
      ),
    );
  }
}