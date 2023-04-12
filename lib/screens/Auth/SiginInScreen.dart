// ignore_for_file: use_build_context_synchronously
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';
import 'package:provider/provider.dart';

class SiginInScreen extends StatefulWidget {
  const SiginInScreen({super.key});

  @override
  State<SiginInScreen> createState() => _SiginInScreenState();
}

class _SiginInScreenState extends State<SiginInScreen> {
  bool isLoading = false;
  bool showPassword = false;
  String userType = "user";
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  GoogleSigninAuth googleSignIn = GoogleSigninAuth();
  String? token;

  @override
  void initState() {
    // email.text = 'smithjohn@gmail.com';
    // password.text = 'smith.com';

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
    final signIn = await googleSignIn.signIn(); // attempt login
    if(signIn == null){
      setState(() {
        isLoading = false;
      });
      return Toaster.error('Signin failed!, please try again!');
    }

    setState(() {
      isLoading = true;
    });

    Map data = {
      'oauth': 'google',
      'token': signIn.accessToken,
      'device_id': token
    };

    Toaster.info("Signing with Google account... please wait.");

    await AuthController.social(data).then((dynamic data) async {

      completeSignin(data);

    });
  }

  void completeSignin(dynamic result) {
    setState(() {
      isLoading = false;
    });
    
    if (result['error']){
      Toaster.error(
        result['message']
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

      if(auth['role'] == 'USER'){
        user.login(auth);
        RouteGenerator.goto(DASHBOARD, {  });
        return;
      }
      
      creator.login(auth);
      RouteGenerator.goto(CREATOR_DASHBOARD);

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
              Labels.primary(
                "Sign In",
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
              SizedBox(height: 40),
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
                          Colors.white24 : Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Labels.secondary(
                    "Don't have an account? Signup",
                    onTap: () => RouteGenerator.goto(ONBOARDING),
                  ),
                  Labels.secondary(
                    "Forgot Password"
                  ),
                ],
              ),
              SizedBox(height: 20),
              Buttons.primary(
                label: !isLoading ? "Sign in" : "Signing in... ",
                onTap: () async => await _doSignin(),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Labels.primary("Or"),
                    SizedBox(height: 30),
                    SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => _googleSignin(),
                            child: SvgPicture.asset(
                              "assets/images/icons/svg/google.svg"
                            ),
                          ),
                          GestureDetector(
                            onTap: () => {},
                            child: SvgPicture.asset(
                              "assets/images/icons/svg/facebook.svg"
                            ),
                          ),
                          GestureDetector(
                            onTap: () => {},
                            child: SvgPicture.asset(
                              "assets/images/icons/svg/apple.svg"
                            ),
                          ),
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