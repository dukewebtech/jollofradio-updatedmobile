import 'package:flutter/material.dart';

class ErrorScreen extends StatefulWidget {
  final int code;
  const ErrorScreen({this.code = 404, super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.code.toString(), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Text("Page Not Found!"),
          ],
        ),
      ),
    );
  }
}