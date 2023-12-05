import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:jollofradio/config/services/core/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/services/auth/GoogleSignin.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/helpers/Country.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:jollofradio/widget/Shared.dart';
import 'package:provider/provider.dart';

class SiginUpScreen extends StatefulWidget {
  final String userType;
  const SiginUpScreen({super.key, required this.userType});

  @override
  State<SiginUpScreen> createState() => _SiginUpScreenState();
}

class _SiginUpScreenState extends State<SiginUpScreen> {
  bool isLoading = false;
  bool showPassword = false;
  bool toc = false;
  bool social = false;
  late String userType;
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController telephone = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  GoogleSigninAuth googleSignIn = GoogleSigninAuth();
  String? token;
  dynamic _setState;
  String? age;
  List<String> profiles = [
    '18-27',
    '28-37',
    '38-47',
    '48-57',
    '58-above',
  ];
  List countries = [];

  @override
  void initState() {
    userType = widget.userType;
    _setState = setState;

    Future(() async {

      token = await NotificationService.getToken(); // device ID
      countries = await Countries.get();

    });

    googleSignIn.init();
    super.initState();
  }

  Future _doSignup() async {
    Map data = {
      'firstname': firstname.text,
      'lastname': lastname.text,
      'email': email.text,
      'telephone': telephone.text,
      'country': country.text,
      'state': state.text,
      'city': city.text,
      'age': age ?? "",
      'password': password.text,
      'confirmPassword': confirmPassword.text,
      'userType': userType
    };

    if(toc  ==  false){
      Toaster.info( "You need to accept our terms & condition!" );
      return;
    }
    
    if(isLoading)
      return;

    setState(() {
      isLoading = true;
    });

    var signup = await AuthController.signup(data); //send request
    setState(() {
      isLoading = false;
    });
    
    if (signup['error']){
      Toaster.show(
        position: 'TOP',
        status: 'error',
        message: signup['message'],
      );
    }
    else{
      //attempt auto login
      Toaster.success(
        "You've successfully signup, redirecting ...".toString( )
      );

      await AuthController.signin(data).then((dynamic response) {
        if(response['error']){
          Toaster.error("Autologin failed! please login again.");
          RouteGenerator.goto(SIGNIN);
        }

        var user = login(response)['user'];
        var token = login(response)['token'];

        Storage.set('token', token);
        
        /*
        if(userType == 'user'){
          Provider.of<UserProvider   > ( context, listen: false )
          .login(user);

          return;
        }
          Provider.of<CreatorProvider> ( context, listen: false )
          .login(user);
          
          return;
        */
      });
      
      if(userType == 'user'){
        RouteGenerator.goto(SIGNUP_ONBOARD, < String, dynamic > {
          'type': userType,
          'token': signup['data']['token'],
          'email': email.text,
          'social': social
        });
        return;
      }

      RouteGenerator.goto(
        VERIFY_ACCOUNT, {
          "email": email.text
        }
      );
      /*
      RouteGenerator.goto(CREATOR_DASHBOARD);   // redirecting..
      */
    }
  }

  Future<void> _googleSignin() async {
    googleSignIn.signOut();
    final signIn = await googleSignIn.signIn(); // attempt login
    
    if(signIn == null){
      setState(() {
        isLoading = false;
      });

      return Toaster.show(
        position: 'TOP',
        status: 'error',
        message: 'Signin failed!, please try again!'.toString( ),
      );
    }

    setState(() {
      isLoading = true;
    });

    Map data = {
      'oauth': 'google',
      'token': signIn.accessToken,
      'device_id': token,
      'scope': userType.toUpperCase()
    };

    Toaster.info("Signing with Google account... please wait.");

    await AuthController.social(data).then((dynamic data) async {
      
      social = true;
      completeSignin(data);

    });
  }

  void completeSignin(dynamic result) {    
    setState(() {
      isLoading = false;
    });
    
    if (result['error']){
      Toaster.show(
        position: 'TOP',
        status: 'error',
        message: result['message'],
      );
    }
    else{
      final Map auth = login(result)['user'];
      final String token = login(result)['token'];
      Storage.set('token', token);

      //Invoking providers
      final user = Provider
      .of<UserProvider   >(context, listen: false ); ////////////

      final creator = Provider
      .of<CreatorProvider>(context, listen: false ); ////////////

      if(userType == 'user'){
        if(social){
          user.login(auth);
        }
        RouteGenerator.goto(SIGNUP_ONBOARD, < String, dynamic > {
          'type': userType,
          'token': auth['token'],
          'email': email.text,
          'social': social
        });
        return;
      }

      if(!social){
        RouteGenerator.goto(
          VERIFY_ACCOUNT, {
            "email": email.text
          }
        );
      }
      else {
        creator.login(auth);
        RouteGenerator.goto(CREATOR_DASHBOARD);  // redirecting..
      }
    }
  }

  @override
  void dispose() {
    firstname.dispose();
    lastname.dispose();
    email.dispose();
    telephone.dispose();
    password.dispose();
    confirmPassword.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
      ),
      body: SingleChildScrollView(
        child: Container(          
          margin: EdgeInsets.only(
            // top: AppBar().preferredSize.height + 20,
            left: 30, 
            right: 30
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Labels.primary(
                "Sign Up",
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Labels.primary("Firstname"),
                        Input.primary(
                          "e.g Smith",
                          controller: firstname,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Labels.primary("Lastname"),
                        Input.primary(
                          "John",
                          controller: lastname,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Labels.primary("E-mail"),
              Input.primary(
                "",
                controller: email,
              ),
              SizedBox(height: 10),
              Labels.primary("Telephone"),
              Input.primary(
                "",
                controller: telephone,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Labels.primary("Country"),
                        GestureDetector(
                          onTap: () {
                            _showCountryDialog();
                          },
                          child: AbsorbPointer(
                            child: Input.primary(
                              "",
                              controller: country,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Labels.primary("State"),
                        Input.primary(
                          "",
                          controller: state,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Labels.primary("City"),
              Input.primary(
                "",
                controller: city,
              ),
              SizedBox(height: 10),
              Labels.primary("Age"),
              Dropdown(
                label: "How old are you?",
                icon: false,
                items: profiles,
                value: age,
                state: _setState,
                onChanged: (value){
                  _setState((){
                    age = value;
                  });
                }
              ),
              SizedBox(height: 10),
              Labels.primary("Password"),
              SizedBox(
                child: Stack(
                  children: [
                    Input.primary(
                      "",
                      controller: password,
                      password: !showPassword,
                      // trailingIcon: Icons.visibility
                    ),
                    Positioned(
                      top: 18,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: Icon(!showPassword ? 
                          Icons.visibility_off : Icons.visibility,
                          size: 15,
                          color: !showPassword ? 
                          Colors.white30 : Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Labels.primary("Confirm Password"),
              SizedBox(
                child: Stack(
                  children: [
                    Input.primary(
                      "",
                      controller: confirmPassword,
                      password: !showPassword,
                      // trailingIcon: Icons.visibility
                    ),
                    Positioned(
                      top: 18,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: Icon(!showPassword ? 
                          Icons.visibility_off : Icons.visibility,
                          size: 15,
                          color: !showPassword ? 
                          Colors.white30 : Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.topLeft,
                      child: Checkbox(
                        activeColor: AppColor.secondary,
                        checkColor: AppColor.primary,
                        side: BorderSide(
                          color: AppColor.secondary
                        ),
                        value: toc,
                        onChanged: (value)=> setState(()=> toc = !toc),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 90,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 18
                        ),
                        child: Text.rich(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60
                          ),
                          TextSpan(
                            text: "I hereby agrees to the JollofRadio ",
                            children: <TextSpan>[
                              TextSpan(
                                text: "Terms",
                                style: TextStyle(
                                  color: AppColor.secondary,
                                  fontFamily: 'Satoshi'
                                ),
                                recognizer: TapGestureRecognizer()..onTap=() async {
                                  RouteGenerator.goto(WEBVIEW, {
                                    "url": 'https://m.jollofradio.com/terms-of-service',
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
                                    "url": 'https://m.jollofradio.com/privacy',
                                    "title": 'Privacy Policy'
                                  });
                                },
                              ),
                            ]
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Buttons.primary(
                label: !isLoading ? "Sign up" : "Signing up... ",
                onTap: () async => await _doSignup(),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Labels.primary("Or"),
                    SizedBox(height: 20),
                    Container(
                      // width: 120,
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          /*
                          GestureDetector(
                            onTap: () => _googleSignin(),
                            child: Image.asset(
                              "assets/images/icons/google.png"
                            ),
                          ),
                          GestureDetector(
                            onTap: () => {},
                            child: Image.asset(
                              "assets/images/icons/facebook.png"
                            ),
                          ),
                          GestureDetector(
                            onTap: () => {},
                            child: Image.asset(
                              "assets/images/icons/apple.png"
                            ),
                          ),
                          */
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 60,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(9),
                                 border: Border.all(
                                  color: Color(0XFF414132)
                                 ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  )
                                ),
                                onPressed: () => _googleSignin(), 
                                icon: Icon(
                                  FontAwesomeIcons.google,
                                  size: 18,
                                ), 
                                label: Text(
                                  "Sign up with Google", style: TextStyle(
                                  ),
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _showCountryDialog() async {
    return showDialog(
      context: context, 
      builder: (context) {

        return Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.red
            ),
            child: Scaffold(
              body: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white24)
                              )
                            ),
                            child: Row(
                              mainAxisAlignment: 
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Labels.primary(
                                  "Select Country",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                                /*
                                Icon(
                                  Iconsax.search_favorite,
                                  size: 14,color: Colors.white,
                                )
                                */
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              key: const PageStorageKey<String>('country'),
                              shrinkWrap: true,
                              itemCount: countries.length,
                              itemBuilder: (context, index) {
                                Map data = countries[index] as Map;
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  minLeadingWidth: 30,
                                  leading: Container(
                                    width: 30,
                                    height: 20,
                                    color: Color(0XFF0D1921),
                                    child: Image.network(
                                      data['flag'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(data['name'], style: TextStyle(
                                    color: Colors.white
                                  )),
                                  onTap: () {
                                    RouteGenerator.goBack();
                                    country.text = data[ 'name' ].toString( );
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}