// ignore_for_file: use_build_context_synchronously
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jollofradio/config/routes/router.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    // email.text = 'smithjohn@gmail.com';
    // password.text = 'smith.com';

    super.initState();
  }

  Future _doSignin() async {
    Map data = {
      'email': email.text,
      'password': password.text,
      'userType': userType
    };

    if(isLoading)
      return;

    setState(() {
      isLoading = true;
    });

    var signin = await AuthController.signin(data); //send request
    setState(() {
      isLoading = false;
    });
    
    if (signin['error']){
      Toaster.error(
        signin['message']
      );
    }
    else{     
      final Map auth = login(signin)['user'];
      final String token = login(signin)['token'];

      Storage.set('token', token);

      //Invoking providers
      final user = Provider
      .of<UserProvider   >(context, listen: false ); ////////////

      final creator = Provider
      .of<CreatorProvider>(context, listen: false ); ////////////


      if(userType == 'user'){
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
              Input.primary(
                "",
                controller: password,
                password: true
                // trailingIcon: Icons.visibility
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