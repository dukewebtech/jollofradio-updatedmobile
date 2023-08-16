import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/models/Podcast.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/CategoryController.dart';
import 'package:jollofradio/config/services/controllers/Creator/PodcastController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/string.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Crop.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Shared.dart';
import 'package:provider/provider.dart';

class UploadScreen extends StatefulWidget {
  final String type;
  final dynamic callback;
  final Podcast? podcast;

  const UploadScreen({ 
    Key? key,
    required this.type,
    required this.callback,
    this.podcast
  }) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late Creator user;
  bool isLoading = true;
  bool importing = false;
  bool uploading = false;
  TextEditingController rssInput = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController file = TextEditingController();
  TextEditingController description = TextEditingController();
  String logo = "";
  Uint8List? imageByte;
  
  List<String> dropdown = [];
  List categories = [];
  dynamic state;
  dynamic podcast;
  String? selectedLabel;
  String? active;
  bool update = false;
  Map tagline = {
    "import": Message.import_note,
    "edit": Message.upload_note,
    "create": Message.upload_note
  };

  Map status = {
    1: "ACTIVE",
    0: "DISABLED"
  };

  Map buttons = {
    "import": [
      "Import", "Importing..."
    ],
    "edit": [
      "Save", "Saving..."
    ],
    "create": [
      "Save", "Saving..."
    ],
  };

  @override
  void initState() {
    var auth = Provider.of<CreatorProvider>(context,listen: false);
    user = auth.user;

    state = setState;
    podcast = widget.podcast;

    _getPodcast ();
    _getCategory();

    super.initState();
  }

  Future _getPodcast () async {
    if(podcast == null) 
      return;

    selectedLabel = podcast.category['name'];  /////////////////
    title.text = podcast.title;
    // file.text = "IMAGE";
    category.text = podcast.category['name'];  /////////////////
    active = podcast.active
    ? status[1] : status[0];
    description.text = podcast.description  ;  /////////////////
  }

  Future _getCategory() async {
    await CategoryController.index().then((categories) { ///////
      this.categories = categories;

      for(var i in categories){
        dropdown.add(i.name.toString());
      }
      
      setState(() {
        isLoading = false;
      });
      
    });
  }

  Future _selectLogo  () async {
    Uint8List image;
    File? imageFile;

    final dynamic result = await FilePicker.platform.pickFiles(
        type: FileType.image, 
        lockParentWindow: true, 
        withData: true
    );

    if (result == null) {
      return;
    }

    image = result.files.first.bytes!;
    imageFile = File(
      result.files.first.path
    );

    //init crop
    dynamic cropImage = ( await Cropper.cropImage(imageFile) );
    if(cropImage == null)
      return;

    image = await cropImage
    .readAsBytes();

    setState(() {
      imageByte = image;
      file.text = result.files.first.name;
      logo = "data:image/png;base64," + base64Encode ( image );
    });
  }

  Future uploadPodcast() async {
    if(importing || uploading)
      return;

    active = active ?? 'ACTIVE';

    int? categoryId;
    var  category = 
             categories.where((e) => e.name == selectedLabel);
    if(category.isNotEmpty){
      categoryId = category.first.id;
    }

    Map data = {
      "url": rssInput.text,
      "category_id": categoryId,
      "auto_update": update,

      "id": podcast?.id,
      "name": title.text,
      "category": categoryId,
      "logo": logo,
      "description": description.text,
      "active": status.entries
      .firstWhere((e)=>e.value==active).value==status[1]? 1:0
    };

    if(widget.type == 'import'){
      if(data[ 'url' ].isEmpty){
        return 
            Toaster.info("You have not entered an RSS link!");
      }
      if(selectedLabel == null){
        return 
            Toaster.info("You have not selected a category!");
      }

      setState(() {
        importing = true;
        uploading = true;
      });

      await PodcastController.import(data).then(  (response) {
      
        upload(response);

      });
    }

    if(widget.type == 'create'
    || widget.type == 'edit') {
      if(data['name'].isEmpty){
        return 
            Toaster.info("You have not entered podcast name");
      }
      if(selectedLabel == null){
        return 
            Toaster.info("You have not selected a category!");
      }
      if(data['logo'].isEmpty){
        if(podcast == null)
        return 
            Toaster.info("You have not select podcast logo ");
      }

      setState(() {
        importing = true;
        uploading = true;
      });

      if(podcast == null)
      await PodcastController.upload(data).then(  (response) {
      
        upload(response);

      });
      else
      await PodcastController.update(data).then(  (response) {
        
        upload(response);

      });    
    }
  }

  Future upload(response) async {
    setState(() {
      importing = false;
      uploading = false;
    });

    if(response['error']){
      return Toaster.error(
        response['message']
      );
    }

    if(podcast == null){
      rssInput.clear();
      title.clear();
      description.clear();
      file.clear();
      selectedLabel = null;
    }

    Toaster.success(response['message'].toString()); ///////
    
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

    await Future.delayed(Duration(seconds: 2), (){ /////////
      if(widget.callback != null){
        widget.callback();
      }
    });
    
    RouteGenerator.goBack();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text("${Str.capitalize(widget.type)} Podcast"),
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
                  color: Color(0XFF051724),
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.only(
                    bottom: 20
                  ),
                  child: Text(
                    tagline[widget.type], style: TextStyle(
                      fontSize: 13.5,
                      color: AppColor.secondary

                    ),
                  ),
                ),
                Divider(),
                SizedBox(
                  height: 20,
                ),
                if(widget.type == 'import') ...[
                  SizedBox(
                    width: double.infinity,
                    child: Input.primary(
                      "RSS Link",
                      leadingIcon: Iconsax.link,
                      controller: rssInput
                    ),
                  ),
                  Dropdown(
                    label: "Category",
                    items: dropdown,
                    value: selectedLabel,
                    state: state,
                    onChanged: (value){
                      selectedLabel = value;
                    }
                  ),
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColor.input,
                      borderRadius: BorderRadius.circular(7)
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 15,
                            right: 15
                          ),
                          child: Icon(
                            Icons.refresh, color: Colors.white30, size: 20,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text("Auto Update", style: TextStyle(
                            fontSize: 13,
                            color: Colors.white30
                          )),
                        ),
                        Spacer(),
                        CupertinoSwitch(
                          activeColor: AppColor.secondary,
                          value: update, 
                          onChanged: (value) {
                            setState(()=> update = value);
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    child: Buttons.secondary(
                      label: !importing ? 
                      buttons[widget.type][0] 
                      : 
                      buttons[widget.type][1],
                      onTap: () async => await uploadPodcast(),
                    ),
                  ),
                ] else ...[
                  Input.primary(
                    "Podcast Title",
                    leadingIcon: Iconsax.music,
                    controller: title
                  ),
                  Dropdown(
                    label: "Category",
                    items: dropdown,
                    value: selectedLabel,
                    state: state,
                    onChanged: (value){
                      selectedLabel = value;
                    }
                  ),
                  GestureDetector(
                    onTap: () => _selectLogo(),
                    child: Stack(
                      children: [
                        AbsorbPointer(
                          child: Input.primary(
                            "Podcast Logo",
                            leadingIcon: Iconsax.image,
                            controller: file
                          ),
                        ),
                        if(podcast  !=  null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.network(
                              podcast.logo, fit: BoxFit.cover
                            ),
                          ),
                        ),
                        if(imageByte != null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.memory(
                              imageByte!, fit: BoxFit.cover
                            ),
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
                    state: state,
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
                      label: !uploading ?
                      buttons[widget.type][0] 
                      : 
                      buttons[widget.type][1],
                      onTap: () async => await uploadPodcast(),
                    ),
                  )
                ]
              ]
            ]
          )
        )
      )
    );
  }
}