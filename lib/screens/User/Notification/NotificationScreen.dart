import 'package:flutter/material.dart';
import 'package:jollofradio/screens/Layouts/Templates/Notification.dart';
import 'package:jollofradio/widget/Buttons.dart';

class NotificationScreen extends StatefulWidget {
  final dynamic user;
  final dynamic callback;
  const NotificationScreen({
    super.key, 
    required this.user,
    required this.callback
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  dynamic user;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Buttons.back(),
        title: Text("Notifications"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width, ///////
        height: double.infinity,
        margin: EdgeInsets.only(
          top: 0,
          left: 20, 
          right: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...user.notifications.map((notification) {
                return NotificationTemplate(
                  notification,
                  user,
                  widget.callback
                );

              }).toList()
            ],
          ),
        ),
      ),
    );
  }
}