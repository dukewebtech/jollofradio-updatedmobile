import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/models/Creator.dart';
// import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/Creator/FollowerController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
// import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/date.dart';
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/screens/Layouts/Templates/Follower.dart';
import 'package:provider/provider.dart';

class SubscriberScreen extends StatefulWidget {
  const SubscriberScreen({ Key? key }) : super(key: key);

  @override
  State<SubscriberScreen> createState() => _SubscriberScreenState();
}

class _SubscriberScreenState extends State<SubscriberScreen> {
  late Creator user;
  bool isLoading = true;
  CacheStream cacheManager = CacheStream();
  List subscribers = [];
  List todaySubs = [];

  @override
  void initState() {
    var auth = Provider.of<CreatorProvider>(context,listen: false);
    user = auth.user;

    super.initState();

    //cache manager
    (() async {
      await cacheManager.mount({
        'subscribers': {
          'data': () async {
            return await FollowerController.index(); ////////////
          },
          'rules': (data){
            return data.isNotEmpty;
          },
        },
      }, null);

      getSubscribers();

    }());
  }

  Future<void> getSubscribers() async {
    final subscribers = await cacheManager.stream( //////////////
      'subscribers', 
      fallback: () async {
        return FollowerController.index();
      },
    );

    this.subscribers = subscribers;

    todaySubs = subscribers.where((dynamic user) {   //callback!
      String subDate = user['created_at']
      .split('T')[0];

      return subDate == Date().format("yyyy-MM-dd"); //test date

    }).toList();

    setState(() {
      isLoading = false;
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;

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
              Container(
                height: 100,
                margin: EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: width / 2.4,
                      height: 100,
                      padding: EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColor.secondary,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              Icon(
                                Iconsax.user,
                                color: AppColor.secondary,
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                todaySubs.length.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          Labels.secondary(
                            "Today Subscribers",
                            fontSize: 12
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: width / 2.4,
                      height: 100,
                      padding: EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: Color(0XFF0D1921),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              Icon(
                                Iconsax.people,
                                color: AppColor.secondary,
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                subscribers.length.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          Labels.secondary(
                            "Total Subscribers",
                            fontSize: 12
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Labels.primary(
                      "Subscribers",
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),

                    // Labels.secondary(
                    //   "${subscribers.length} follower(s)"
                    // )
                  ],
                ),
              ),
              if(subscribers.isEmpty)
              Container(
                height: 300,
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 6
                ),
                padding: EdgeInsets.fromLTRB(40, 20, 40, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Iconsax.people5,
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ...subscribers.map((user) => FollowerTemplate(
                        follower: user,
                      ))
                    ],
                  ),
                ),
              )
            ]
          ]
        )
      )
    );
  }

}