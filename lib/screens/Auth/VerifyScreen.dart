import 'package:jollofradio/config/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/services/controllers/AuthController.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/utils/toaster.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  const VerifyScreen({super.key, required this.email});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  bool isLoading = false;
  final TextEditingController email = TextEditingController();

  Future _doVerify() async {
    Map data = {
      'email': widget.email,
    };

    if(isLoading)
      return;

    setState(() {
      isLoading = true;
    });
    
    await AuthController.activate(data).then((dynamic data) {
      setState(() {
        isLoading = false;
      });
      if (data['error']){
        return Toaster.error(data['message']); //////////////
      }
      Toaster.success(data['message']);
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
                      "assets/images/illustration/shape.png"
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Labels.primary(
                  "Verify Account",
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                Labels.secondary(
                  Message.verify_account,
                  fontSize: 13,
                  maxLines: 3
                ),
                SizedBox(height: 20),
                Buttons.primary(
                  label: !isLoading ? "Resend Link" : "Loading... ",
                    onTap: () async => await _doVerify(),
                ),
                Center(
                  child: Labels.secondary(
                    "Login",
                    onTap: () => RouteGenerator.goto(SIGNIN, {
                      "email": widget.email
                    }),
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