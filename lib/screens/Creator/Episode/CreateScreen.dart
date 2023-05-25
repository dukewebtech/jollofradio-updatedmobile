import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/models/Episode.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/Creator/EpisodeController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Shared.dart';
import 'package:provider/provider.dart';

class CreateScreen extends StatefulWidget {
  final String type;
  final Podcast? podcast;
  final Episode? episode;
  final dynamic callback;

  const CreateScreen({ 
    Key? key,
    required this.type,
    this.podcast,
    this.episode,
    this.callback,
  }) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  late Creator user;
  bool isLoading = true;
  bool isSaving = false;
  TextEditingController title = TextEditingController();
  TextEditingController file = TextEditingController();
  TextEditingController source = TextEditingController();
  TextEditingController description = TextEditingController();
  String logo = "";
  String audio = "";
  bool urlUpload = false;
  Map mode = {
    true: {
      "bg": AppColor.secondary,
      "text": Colors.black
    },
    false: {
      "bg": Color(0XFF0D1921),
      "text": Colors.white
    },
  };
  
  Podcast? podcast;
  Episode? episode;
  String? active;

  Map status = {
    1: "ACTIVE",
    0: "DISABLED"
  };

  Map buttons = {
    "create": [
      "Upload", "Uploading..."
    ],
    "update": [
      "Update", "Updating ..."
    ],
  };

  @override
  void initState() {
    var auth = Provider.of<CreatorProvider>(context,listen: false);
    user = auth.user;

    podcast = widget.podcast;
    episode = widget.episode;
    _getEpisode();

    super.initState();
  }

  Future<void> _getEpisode() async {
    if(episode == null){
      setState(() {
        isLoading = false;        
      });

       return;
    }

    title.text = episode!.title;
    // file.text = "IMAGE";
    source.text = episode!.source;
    active = episode!.active!
    ? status[1] : status[0];
    description.text = episode!.description ?? ""; //////////////

    setState(() {
      isLoading = false;        
    });
  }

  Future _selectFile(type) async {
    Uint8List data;
    FileType format = {
      "logo": FileType.image,
      "file": FileType.audio
    }[type]!;

    if(type == 'file' && urlUpload)
      return;

    final dynamic result = await FilePicker.platform.pickFiles(
        type: format, 
        lockParentWindow: true, 
        withData: true
    );

    if (result == null) {
      return;
    }

    data = result.files.first.bytes!;

    setState(() {
      if(type == 'logo'){
        file.text = result.files.first.name;
        logo = "data:image/png;base64,"  + base64Encode (data);
      }

      if(type == 'file'){
        source.text = result.files.first.name;
        audio = "data:audio/mpeg;base64,"+ base64Encode (data);
      }
    });
  }

  Future uploadEpisode() async {
    if(isSaving)
      return;

    active = active ?? 'ACTIVE';

    dynamic item;
    Map data = <String, dynamic>{
      "podcast": podcast,
      "episode": episode,
      "episodes": [
        {
          "title": title.text,
          "logo": logo,
          "description": description.text, ////////////////////
          "source": source.text,
          "active": status.entries.firstWhere(
            (e)=>e.value==active)
            .value==status[1]?1:0
        }
      ]
    };

    item = data['episodes'][0];

    if(audio != ""){
      item['source'] = (audio);
    }
    
    if(urlUpload)  {
      if(!Uri.parse(
        item['source']).isAbsolute
      ){
        return Toaster.info("Audio source is not valid URL! ");

      }
    }

    if(widget.type == 'create'){
      if(item['title'].isEmpty){
        return Toaster.info("You have not specified a title!");
      }
      if(item['logo' ].isEmpty){
        return Toaster.info("You have not selected any logo ");
      }
      if(item['source'].isEmpty){
        return Toaster.info("You have not enter audio source");
      }

      setState(() {
        isSaving = true;
      });

      await EpisodeController.create(data).then(  (response) {
      
        finish(response);

      });
    }

    if(widget.type == 'update'){
      if(item['title'].isEmpty){
        return Toaster.info("You have not entered a title! ");
      }

      setState(() {
        isSaving = true;
      });

      await EpisodeController.update(data).then(  (response) {
      
        finish(response);

      });
    }
  }

  Future finish(response) async {
    setState(() {
      isSaving = false;
    });

    if(response['error']){
      return Toaster.error(
        response['message']
      );
    }

    if(episode == null){
      title.clear();
      file.clear();
      source.clear();
      description.clear();
      active = null;
    }

    Toaster.success(response['message'].toString()); ///////
    if(widget.callback != null){
      widget.callback();
    }
    
    /*
    await CacheStream().mount({
      '_podcasts': {
        'data': () async {
          return await PodcastController.index(); //////////
        },
        'rules': (data){
          return data.isNotEmpty;
        },
      },
    }, null);
    */

    if(episode != null){
      RouteGenerator.goBack(2);
      return;

    }
    
    RouteGenerator.goBack();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;

    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text("${episode==null ? "New" : "Edit"} Episode"),
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
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 100,
                  color: Color(0XFF0D1921),
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(
                    bottom: 20
                  ),
                  child: Text(
                    Message.episode_note, style: TextStyle(
                      fontSize: 13.5,
                      color: AppColor.secondary

                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 20
                  ),
                  width: width - 40,
                  child: Row(
                    mainAxisAlignment: 
                                  MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: (width - 40) / 2.1,
                        height: 40,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: mode[!urlUpload]['bg']
                          ),
                          onPressed: () {
                            setState(() {
                              urlUpload = false;
                              // source.clear();
                            });
                          },
                          child: Text(
                            "Upload from File", style: /**/TextStyle(
                              color: mode[
                                !urlUpload
                              ]['text']
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: (width - 40) / 2.1,
                        height: 40,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: mode[urlUpload]['bg']
                          ),
                          onPressed: () {
                            setState(() {
                              urlUpload = true;
                              // source.clear();
                            });
                          },
                          child: Text(
                            "Upload from URL", style: /**/TextStyle(
                              color: mode[
                                urlUpload
                              ]['text']
                            ),
                          ),
                        ),
                      )
                    ],

                  ),
                ),
                Input.primary(
                  "Episode Title",
                  leadingIcon: Iconsax.music,
                  controller: title
                ),
                GestureDetector(
                  onTap: () => _selectFile('logo'),
                  child: Stack(
                    children: [
                      AbsorbPointer(
                        child: Input.primary(
                          "Episode Logo",
                          leadingIcon: Iconsax.image,
                          controller: file
                        ),
                      ),
                      if(episode != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Image.network(
                            episode!.logo, fit: BoxFit.cover
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectFile('file'),
                  child: Stack(
                    children: [
                      AbsorbPointer(
                        absorbing: urlUpload == false,
                        child: Input.primary(
                          "Audio Source",
                          leadingIcon: Iconsax.music,
                          controller: source
                        ),
                      ),
                    ],
                  ),
                ),
                Dropdown(
                  label: "Status",
                  items: status
                  .entries
                  .map<String>((e)=>e.value.trim()).toList(),
                  value: active,
                  state: setState,
                  onChanged: (value){
                    active = value;
                  }
                ),
                Input.primary(
                  "Description",
                  leadingIcon: Iconsax.text,
                  controller: description,
                  height: 150,
                  maxLines: 7
                ),
                SizedBox(
                  child: Buttons.secondary(
                    label: !isSaving ?
                    buttons[widget.type][0] 
                    : 
                    buttons[widget.type][1],
                    onTap: () async => await uploadEpisode(),
                  ),
                )
              ]
            ]
          )
        )
      )
    );
  }
}