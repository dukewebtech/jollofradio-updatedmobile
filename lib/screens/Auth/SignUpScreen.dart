import 'package:flutter_svg/flutter_svg.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/services/providers/CreatorProvider.dart';
import 'package:jollofradio/config/services/providers/UserProvider.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/utils/helper.dart';
import 'package:jollofradio/utils/helpers/Storage.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';
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
  late String userType;
  final TextEditingController fullname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController telephone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  @override
  void initState() {
    userType = widget.userType;
    super.initState();
  }

  Future _doSignup() async {
    Map data = {
      'fullname': fullname.text,
      'email': email.text,
      'telephone': telephone.text,
      'password': password.text,
      'confirmPassword': confirmPassword.text,
      'userType': userType
    };

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
      Toaster.error(
        signup['message']
      );
    }
    else{
      //attempt auto login
      await AuthController.signin(data).then((dynamic response) {
        if(response['error']){
          Toaster.error("Autologin failed! please login again.");
          RouteGenerator.goto(SIGNIN);
        }

        var user = login(response)['user'];
        var token = login(response)['token'];

        Storage.set('token', token);

        if(userType == 'user'){
          Provider.of<UserProvider   > ( context, listen: false )
          .login(user);

          return;
        }
          Provider.of<CreatorProvider> ( context, listen: false )
          .login(user);
          
          return;
      });


      if(userType == 'user'){
        RouteGenerator.goto(SIGNUP_ONBOARD, < String, dynamic > {
          'token': signup['data']['token']
        });
        
        return;
      }
      
      RouteGenerator.goto(CREATOR_DASHBOARD); // redirect creator
    }
  }

  @override
  void dispose() {
    fullname.dispose();
    email.dispose();
    telephone.dispose();
    password.dispose();
    confirmPassword.dispose();
    
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
                "Sign Up",
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
              SizedBox(height: 40),
              Labels.primary("Fullname"),
              Input.primary(
                "e.g Smith John",
                controller: fullname,
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
                          Colors.white24 : Colors.white,
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
                          Colors.white24 : Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Labels.secondary(
                    "Have an account? Signin",
                    onTap: () => RouteGenerator.goto(SIGNIN),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Buttons.primary(
                label: !isLoading ? "Sign up" : "Signing up... ",
                onTap: () async => await _doSignup(),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Labels.primary("Or"),
                    SizedBox(height: 30),
                    Container(
                      width: 120,
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: <Widget>[
                          SvgPicture.asset(
                            "assets/images/icons/svg/google.svg"
                          ),
                          SvgPicture.asset(
                            "assets/images/icons/svg/facebook.svg"
                          ),
                          SvgPicture.asset(
                            "assets/images/icons/svg/apple.svg"
                          ),
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
}