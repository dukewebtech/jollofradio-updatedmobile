import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Category.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/CategoryController.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/screens/Layouts/Templates/Playlist.dart';
import 'package:jollofradio/widget/Buttons.dart';

class SelectionScreen extends StatefulWidget {
  final Category category;
  const SelectionScreen({super.key, required this.category});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  bool isLoading = true;
  List<Podcast> playlist = [];

  @override
  void initState() {
    getCategory(
      widget.category
      .name
    );
    
    super.initState();
  }

  Future<void> getCategory(cat) async {
    Map query = {
      'category': cat
    };

    final playlist = await CategoryController.show(query);//get
    this.playlist = playlist;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text(widget.category.name),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(
          top: 0,
          left: 20, 
          right: 20
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              Column(
                children: [
                  if(playlist.isEmpty)
                    Container(
                      height: 300,
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 4
                      ),
                      padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Iconsax.music,
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
                          return GestureDetector(
                            onTap: () {

                              RouteGenerator.goto(PODCAST, {
                                "playlist": playlist[index]
                              });
                              
                            },
                            child: AbsorbPointer(
                              child: PlaylistTemplate(playlist: playlist[index]),
                            ),
                          );
                        }
                      ),
                    ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}