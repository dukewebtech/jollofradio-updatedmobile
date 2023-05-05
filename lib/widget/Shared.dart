import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/utils/Helpers/Country.dart';

class Tile extends StatefulWidget {
  final BuildContext context;
  final String type;
  final String label;
  final IconData icon;
  final dynamic data;

  const Tile({ 
    Key? key,
    required this.context,
    required this.type,
    required this.label,
    required this.icon,
    required this.data,
  }) : super(key: key);

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  double width = 0;
  Color? borderColor;
  Color? color;
  Color? backgroundColor;

  @override
  void initState() {
    width = MediaQuery.of(widget.context).size.width;
    borderColor = {
      "primary": AppColor.secondary,
      "secondary": Color(0XFF7c7450).withAlpha( 100 )
    }[widget.type]!;

    color = {
      "primary": Colors.black,
      "secondary": Colors.white
    }[widget.type]!;

    backgroundColor = {
      "primary": AppColor.secondary,
      "secondary": AppColor.primary
    }[widget.type]!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width / 2.4,
      height: 100,
      padding: EdgeInsets.fromLTRB(20,10,20,0),
      decoration: BoxDecoration(
        color: backgroundColor,
        image: DecorationImage(
          image: AssetImage(
            "assets/images/illustration/burst_circle.png"
          ),
          alignment: Alignment.bottomCenter
        ),
        border: Border.all(
          color: borderColor!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.label, style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color
                ),
              ),
              Icon(widget.icon, color: color)
            ],
          ),
          SizedBox(height: 10),
          FadeIn(
            child: Text(
              widget.data.toString(), 
              style: TextStyle(
                color: color,
                fontSize: 25, fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Summary extends StatefulWidget {
  final Map statistics;
  final dynamic data;

  const Summary({ 
    Key? key, 
    required this.statistics,
    required this.data 
  }) : super(key: key);

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  bool isLoading = true;
  double width = 0;
  double percentage = 0;
  double progress = 0;
  dynamic country;

  @override
  void initState() {
    Future(() async {
      country = await Countries.get( widget.data.key );
      setState(() {
        isLoading = false;
      });
    });

    width = MediaQueryData.fromWindow(
      WidgetsBinding.
      instance.window
    ).size.width - (40 /**parent */ + 40 /** body */);

    final int totalPlays = widget.statistics['plays'];
    int summary = widget.statistics['summary'].length;
    
    percentage = widget.data.value 
    / totalPlays;

    Timer(Duration(milliseconds: 200), (){ ///////////
      setState(() {
        var value = widget.data.value;
        progress = ((value / totalPlays) * width);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CachedNetworkImage image = CachedNetworkImage(
      imageUrl: country?['flag'] ?? '',
      placeholder: (context, url) {
        return Center(
          child: SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            )
          )
        );
      },
      errorWidget: (context, url, error) => Icon(
        Icons.error
      ),
      fit: BoxFit.cover,
    );

    return isLoading ? SizedBox() : Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 25,
                height: 25,
                child: image,
              ),
              SizedBox(width: 10),
              Labels.primary(
                widget.data.key,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                margin: EdgeInsets.zero
              ),
              Spacer(),
              Labels.primary(
                "${
                  (percentage * 100).toStringAsFixed(0)
                }%",
                fontSize: 12,
                fontWeight: FontWeight.bold,
                margin: EdgeInsets.zero
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            width: width,
            height: 5,
            decoration: BoxDecoration(
              color: Color(0XFFD9D9D9).withAlpha(50),
              borderRadius: BorderRadius.circular(50)
            ),
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.topLeft,
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              width: progress,
              height: 5,
              color: AppColor.secondary.withAlpha(255),
            ),
          )
        ],
      ),
    );
  }
}

class Select extends StatefulWidget {
  final String label;
  final String? selectedLabel;
  final dynamic state;
  final List<String> items;
  final dynamic callback;

  const Select({ 
    Key? key,
    required this.label,
    required this.selectedLabel,
    required this.state,
    required this.items,
    required this.callback,
  }) : super(key: key);

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  late String label;
  late String? selectedLabel;
  late dynamic state;
  late List<String> items;
  late dynamic callback;

  @override
  void initState() {
    label = widget.label;
    selectedLabel = widget.selectedLabel;
    state = widget.state;
    items = widget.items;
    callback = widget.callback;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ButtonTheme(
        // colorScheme: 
        // ColorScheme.fromSeed(seedColor: Colors.red),
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
          hint: Labels.secondary(label),
          items: items.map<DropdownMenuItem>( (val) => 
          DropdownMenuItem<String>(
            value: val,
            child: Text(
              val, style: TextStyle(
                color: Colors.white,
                fontSize: 13
              )
            ),
          )).toList(),
          onChanged: (value) {
            state(() {
              selectedLabel = value;
              callback({
                'state': state, 'label': selectedLabel
              });
            });
          },
        ),
      ),
    );
  }
}

Future<void> playlistModal({
  required BuildContext context,
  // required bool loading,
  required String? label,
  required List<String> playlist,
  required TextEditingController controller,
  required dynamic fn,
  required dynamic callback,
}) async {
  bool loading = false;
  bool createModal = false;
  dynamic state;

  return showDialog(
    context: context, 
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {     
          state = setState;
          callback({'state': state}); //fire parent logic
          // cb = callback;
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
                      state((){
                        createModal = !createModal;
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
                  if(!createModal) ...[
                    SizedBox(height: 20),
                    Select(
                      label: "Select a Playlist",
                      selectedLabel: label,
                      items: playlist,
                      state: state,
                      callback: callback
                    )
                  ]
                  else ...[
                    SizedBox(height: 20),
                    Labels.secondary("Create a Playlist"),
                    Input.primary(
                      "Playlist Name",
                      leadingIcon: Icons.edit,
                      controller: controller,
                    ),
                  ],
                  SizedBox(height: 10),
                  Buttons.primary(
                    label: 
                    !loading ? "Add to Playlist" : "Saving...",
                    onTap: () async {
                      state(() => loading = !loading); //update

                      await fn();
                      state(() => loading = !loading); //update
                    },
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

Future<void> deleteModal({
  required BuildContext context,
  required dynamic state,
  required dynamic callback
}) async {
  return showDialog(
    context: context, 
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {     
          state = setState;
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
                onPressed: () => callback(),
                child: Text("Yes", style: const TextStyle(
                  color: Colors.red
                ))
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent
                ),
                onPressed: () {
                  Navigator.pop(context);
                }, 
                child: Text("No", style: const TextStyle())
              ),
            ],
          );
        }
      );
    },
  );
}
