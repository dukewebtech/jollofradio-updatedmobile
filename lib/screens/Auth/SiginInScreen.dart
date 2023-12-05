import 'package:cache_stream/utils/helpers/storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:jollofradio/utils/helpers/Cache.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:provider/provider.dart';

class SiginInScreen extends StatefulWidget {
  final String? email;
  const SiginInScreen({super.key, this.email});

  @override
  State<SiginInScreen> createState() => _SiginInScreenState();
}

class _SiginInScreenState extends State<SiginInScreen> {
  bool isLoading = false;
  bool showPassword = false;
  bool social = false;
  String userType = "user";
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  GoogleSigninAuth googleSignIn = GoogleSigninAuth();
  String? token;
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

  @override
  void initState() {
    email.text = widget.email ?? '';
    Future(() async {

      token = await NotificationService.getToken(); // device ID

    });
    
    googleSignIn.init();
    super.initState();
  }

  Future _doSignin() async {
    Map data = {
      'email': email.text,
      'password': password.text,
      'device_id': token,
      'userType': userType
    };

    if(isLoading)
      return;

    setState(() {
      isLoading = true;
    });

    await AuthController.signin(data).then((dynamic data) async {
      
      completeSignin(data);

    });
  }

  Future<void> _googleSignin() async {
    if(userType.isEmpty){
      Toaster.info("You have not selected a user account type ");
      return;
    }

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
      final Map auth = login(result)['user']; ///////////////////
      final String token = login(result)['token']; //////////////
      final Map? verification = auth['verification']; ///////////

      if(verification == null
      || verification
      ['data']['email']['status'] == 'unverified') { ////////////
        if(!social){
          RouteGenerator.goto(
            VERIFY_ACCOUNT, {
              "email": email.text
            }
          );
          return;
        }
      }

      Storage.set('token', token);
      Storage.delete('guest');

      //unmount caching
      CacheStream().unmount({
        'streams',
        'stations',
        'category',
        'subscriptions',
        'playlist',
        'statistics',
        '_podcasts',
        'subscribers',  
      });

      final user = Provider
      .of<UserProvider   >(context, listen: false ); ////////////

      final creator = Provider
      .of<CreatorProvider>(context, listen: false ); ////////////

      if(auth['role'] == 'USER'){
        user.login(auth);
        RouteGenerator.exit(DASHBOARD, {  });
        return;
      }
      
      creator.login(auth);
      RouteGenerator.exit(CREATOR_DASHBOARD);
      ///////////////////////////////////////////////////////////
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_cast
    double width = MediaQuery.of(context).size.width as double;

    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Container(
          // width: MediaQuery.of(context).size.width,
          // height: double.infinity,
          margin: EdgeInsets.only(
            top: AppBar().preferredSize.height + 20,
            left: 30, 
            right: 30
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Labels.primary(
                    "Sign In",
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  ),
                  Labels.secondary(
                    "Skip >",
                    onTap: () async {
                      RouteGenerator.goto(PUBLIC);
                      Storage.set('guest', true );
                    }
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                margin: EdgeInsets.only(
                  bottom: 20
                ),
                width: width - 60,
                child: Row(
                  mainAxisAlignment: 
                                MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: (width - 60) / 2.1,
                      height: 40,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: mode[userType == 'user']['bg']
                        ),
                        onPressed: () {
                          setState(() {
                            userType = 'user';
                          });
                        },
                        child: Text(
                          "Login As User", style: /**/TextStyle(
                            color: mode[
                              userType == 'user'
                            ]['text']
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (width - 60) / 2.1,
                      height: 40,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: mode[userType != 'user']['bg']
                        ),
                        onPressed: () {
                          setState(() {
                            userType = 'creator';
                          });
                        },
                        child: Text(
                          "Login As Creator", style: /**/TextStyle(
                            color: mode[
                              userType != 'user'
                            ]['text']
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Labels.primary("Email Address, Username"),
              Input.primary(
                "",
                controller: email,
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
              /*
              Row(
                children: <Widget>[
                   Labels.primary("Signin as:"),
                   Spacer(),
                   Row(
                     children: [
                      SizedBox(
                        width: 30,
                        child: Radio(
                          fillColor: MaterialStateColor.resolveWith(
                            (states) => AppColor.secondary
                          ),
                          value: 'user', 
                          groupValue: userType, 
                          onChanged: (value) {
                            setState(() => userType = value!);
                          },
                        ),
                      ),
                      Text("USER", style: TextStyle(
                        fontSize: 10
                      ))
                     ],
                   ),
                   SizedBox(
                    width: 20,
                   ),
                   Row(
                     children: [
                      SizedBox(
                        width: 30,
                        child: Radio(
                          fillColor: MaterialStateColor.resolveWith(
                            (states) => AppColor.secondary
                          ),
                          value: 'creator', 
                          groupValue: userType, 
                          onChanged: (value) {
                            setState(() => userType = value!);
                          },
                        ),
                      ),
                      Text("CREATOR", style: TextStyle(
                        fontSize: 10
                      ))
                     ],
                   )
                ],
              ),
              */
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Labels.secondary(
                    "Don't have an account? Signup",
                    onTap: () => RouteGenerator.goto(ONBOARDING),
                  ),
                  Labels.secondary(
                    "Forgot Password",
                    onTap: () => RouteGenerator.goto(FORGOT),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Buttons.primary(
                label: !isLoading ? "Sign in" : "Signing in... ",
                onTap: () async => await _doSignin(),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Labels.primary("Or"),
                    SizedBox(height: 20),
                    SizedBox(
                      // width: 120,
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
                                  "Sign in with Google", style: TextStyle(
                                  ),
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}