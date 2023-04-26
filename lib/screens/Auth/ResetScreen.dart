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

class ResetScreen extends StatefulWidget {
  final String otp;
  const ResetScreen({super.key, required this.otp });

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  bool isLoading = false;
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  late List<TextEditingController> _controllers = [];

  @override
  void initState() {
    _controllers = [
      password,
      confirmPassword,
    ];

    super.initState();
  }

  Future _doReset() async {
    Map data = {
      "otp": widget.otp,
      'password': password.text,
      'confirmPassword': confirmPassword.text
    };

    if(isLoading || password.text.isEmpty)
      return;

    setState(() {
      isLoading = true;
    });

    await AuthController.reset(data).then((dynamic data) async {
      
      setState(() {
        isLoading = false;
      });

      if (data['error']){
        
        return Toaster.error(data['message']); //////////////////

      }

      Toaster.success(
        data['message']
      );
  
      RouteGenerator.exit(SIGNIN, {});
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

                    child: Transform.scale(
                      scale: 1.5, 
                       
                      child: Image.asset(
                        "assets/images/illustration/rocket.gif"
                      ),
                    ),

                  ),
                ),
                SizedBox(height: 20),
                Labels.primary(
                  "Reset Password",
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                Labels.secondary(
                  Message.reset_password,
                  fontSize: 13,
                  maxLines: 2
                ),
                SizedBox(height: 20),
                Input.primary(
                  "Password",
                  controller: password,
                  leadingIcon: Iconsax.key,
                  password: true
                ),
                Input.primary(
                  "Confirm Password",
                  controller: confirmPassword,
                  leadingIcon: Iconsax.key,
                  password: true
                ),
                Buttons.primary(
                  label: !isLoading ? "Reset" : "Reseting... ",
                    onTap: () async => await _doReset(),
                ),
                Center(
                  child: Labels.secondary(
                    "Remember? Sign In",
                    onTap: () => RouteGenerator.goBack(3),
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