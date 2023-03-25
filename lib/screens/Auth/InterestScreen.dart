import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/services/controllers/CategoryController.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Buttons.dart';

class InterestScreen extends StatefulWidget {
  final String token;
  const InterestScreen({super.key, required this.token});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  bool isLoading = true;
  bool isOnboarding = false;
  List<Map<String, dynamic>> interests = [];

  @override
  void initState() {
    _getCategory();
    super.initState();
  }

  Future<void> _getCategory() async {
    await CategoryController.index().then((categories) {
      int total = 0;
      List<Map<String, dynamic>> interests = [];

      if(categories.isNotEmpty){
        for(var category in categories){
          if(total < 10){
            interests.add({
              'id': category.id,
              'name': category.name,
              'selected': false
            });
            total++;
          }
        }
      }
      interests.shuffle();

      setState(() {
        isLoading = false;
        this
        .interests = interests as List<Map<String, dynamic>>;
      });
    });
  }

  Future _onboard() async {
    var token = widget.token;
    List selected = interests.where( (interest) => interest[
      'selected'
    ]).map(
      (e) => e['id']
    ).toList();

    if(isOnboarding) return;

    if(selected.length < 3){
      Toaster.info("You need to select at least 3 interest");
      return;
    }

    setState(() {
      isOnboarding = true;
    });

    Map data = {
      "token": token,
      "interests": selected
    };

    await AuthController.onboard(data).then((dynamic data) {
      setState(() {
        isOnboarding = false;
      });
      RouteGenerator.exit(DASHBOARD);
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
          top: AppBar().preferredSize.height + 20,
          left: 30, 
          right: 30
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  Labels.primary(
                    "Select categories of interest", /////////////////////
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(!isLoading) ...[
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              runAlignment: WrapAlignment
                              .center,
                              alignment: WrapAlignment
                              .spaceBetween,
                              children: <Widget>[
                                ...interests.map((interest) => /**/ Container(
                                  constraints: BoxConstraints(
                                    minWidth: 90,
                                    maxWidth: 140
                                  ),
                                  child: interest['selected'] 
                                  ? Buttons.primary(
                                    label: interest['name'],
                                    onTap: () {
                                      setState(() {
                                        interest['selected'] = 
                                        !interest['selected'];
                                      });
                                    },
                                  ) : Buttons.secondary(
                                    label: interest['name'],
                                    onTap: () {
                                      setState(() {
                                        interest['selected'] = 
                                        !interest['selected'];
                                      });
                                    },
                                  ),
                                ))
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Buttons.primary(
                            label: !isOnboarding 
                            ? "Finish up" : "Finishing up...",
                            onTap: () async => await _onboard(),
                          ),
                        ] else ...[
                          Center(
                            child: CircularProgressIndicator(),
                          )
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: Text.rich(
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60
                ),
                TextSpan(
                  text: "By pressing Sign up securely, you agree to our ",
                  children: <TextSpan>[
                    TextSpan(
                      text: "Terms & Conditions",
                      style: TextStyle(
                        color: AppColor.secondary,
                        fontFamily: 'Satoshi'
                      ),
                      recognizer: TapGestureRecognizer()..onTap=() async {
                        RouteGenerator.goto(WEBVIEW, {
                          "url": 'https://jollofradio.com', 
                          "title": 'Terms & Conditions'
                        }); 
                      },
                    ),
                    TextSpan(
                      text: " and ",
                    ),
                    TextSpan(
                      text: "Privacy Policy. ",
                      style: TextStyle(
                        color: AppColor.secondary
                      ),
                      recognizer: TapGestureRecognizer()..onTap=() async {
                        RouteGenerator.goto(WEBVIEW, {
                          "url": 'https://jollofradio.com/privacy', 
                          "title": 'Privacy Policy'
                        }); 
                      },
                    ),
                    TextSpan(
                      text: "Your data will be securely encrypted with us",
                    ),
                  ]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}