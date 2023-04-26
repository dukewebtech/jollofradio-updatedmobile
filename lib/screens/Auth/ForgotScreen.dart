import 'package:jollofradio/config/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Input.dart';
import 'package:jollofradio/widget/Labels.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  bool isLoading = false;
  final TextEditingController email = TextEditingController();

  Future _doForgot() async {
    Map data = {
      'email': email.text,
    };

    if(isLoading || email.text.isEmpty)
      return;

    setState(() {
      isLoading = true;
    });
    

    await AuthController.forgot(data).then((dynamic data) async {
      
      setState(() {
        isLoading = false;
      });

      if (data['error']){
        
        return Toaster.error(data['message']); //////////////////

      }
  
      RouteGenerator.goto(VERIFY, { });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(null),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(left: 40, right: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 300,
                    child: Image.asset(
                      "assets/images/illustration/forgot-password.png"
                    ),
                  ),
                ),
                // SizedBox(height: 20),
                Labels.primary(
                  "Forgot Password?",
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                Labels.secondary(
                  Message.forgot_password,
                  fontSize: 13,
                  maxLines: 2
                ),
                SizedBox(height: 20),
                Input.primary(
                  "Enter Email Address",
                  controller: email,
                  leadingIcon: Iconsax.user
                ),
                Buttons.primary(
                  label: !isLoading ? "Continue" : "Loading... ",
                    onTap: () async => await _doForgot(),
                ),
                Center(
                  child: Labels.secondary(
                    "Remember? Sign In",
                    onTap: () => RouteGenerator.goBack(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}