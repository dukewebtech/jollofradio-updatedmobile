import 'package:jollofradio/config/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:jollofradio/config/strings/Constants.dart';
import 'package:jollofradio/config/strings/Message.dart';
import 'package:jollofradio/widget/Buttons.dart';
import 'package:jollofradio/widget/Labels.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        margin: EdgeInsets.only(left: 40, right: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: Text(Message.startup_heading, style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600
              ),
                textAlign: TextAlign.center
              ),
            ),
            SizedBox(height: 80),
            Buttons.primary(
              label: "Signup as Listener",
              onTap: () => RouteGenerator.goto(SIGNUP, {
                "account": "user"
              }),
            ),
            // SizedBox(height: 5),
            Buttons.secondary(
              label: "Signup as a Creator",
              onTap: () => RouteGenerator.goto(SIGNUP, {
                "account": "creator"
              }),
            ),
            Labels.secondary(
              "Have an account? Sign In",
              onTap: () => RouteGenerator.goto(SIGNIN),
            ),
          ],
        ),
      ),
    );
  }
}