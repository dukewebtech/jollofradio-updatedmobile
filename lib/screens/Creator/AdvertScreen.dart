import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/models/Creator.dart';
import 'package:jollofradio/config/services/controllers/Creator/AdvertController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:provider/provider.dart';

class AdvertScreen extends StatefulWidget {
  const AdvertScreen({ Key? key }) : super(key: key);

  @override
  State<AdvertScreen> createState() => _AdvertScreenState();
}

class _AdvertScreenState extends State<AdvertScreen> {
  late Creator user;
  bool isLoading = false;

  @override
  void initState() {
    var auth = Provider.of<CreatorProvider>(context,listen: false);
    user = auth.user;

    super.initState();
  }

  Future _enroll() async {
    if(isLoading || user.enrolled!)
      return;

    setState(() {
      isLoading = true;
    });
    
    await AdvertController.enroll({}).then((dynamic data) async {
      setState(() {
        isLoading = false;
      });

      if (data['error']){
        
        return Toaster.info(data['message']); ///////////////////

      }
      successDialog();
    });
  }

  @override
  dispose() {
    super.dispose();
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
        child: FadeInUp(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: Transform.scale(
                  scale: 1.6,
                  child: Image.asset(
                    "assets/images/illustration/rocket.gif"
                  ),
                ),
              ),
              SizedBox(height: 60),
              Labels.primary(
                "Launching soon",
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
              Text(
                Message.launch,
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 50,
                child: Divider()
              ),
              SizedBox(height: 20),
              Text(
                Message.launch_message,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.secondary
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  minWidth: 200,
                  maxWidth: 220
                ),
                child: Buttons.secondary(
                  label: isLoading 
                  ? "Enrolling ..." : !user.enrolled! ? 
                  "Join the beta program" : 
                  "You're already Enrolled!",
                  onTap: () => _enroll(),
                ),
              ),
            ]
          ),
        )
      )
    );
  }

  Future successDialog() async {
    Widget icon() {
      return SizedBox(
        width: 200,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.loose,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(50),
                borderRadius: BorderRadius.circular(50)
              ),
            ),
            ZoomIn(
              delay: Duration(milliseconds: 200),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColor.secondary,
                  borderRadius: BorderRadius.circular(50)
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return FadeInUp(
          child: Center(
            child: Container(
              width: 300,
              height: 250,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    spreadRadius: 5.0
                  )
                ]
              ),
              clipBehavior: Clip.hardEdge,
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      icon(),
                      SizedBox(height: 20),
                      Text(
                        Message.enrolled,
                        style: TextStyle(
                          color: AppColor.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}