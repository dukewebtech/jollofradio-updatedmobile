import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jollofradio/config/services/controllers/NotificationController.dart';
import 'package:jollofradio/config/strings/AppColor.dart';
import 'package:jollofradio/utils/scope.dart';
import 'package:jollofradio/widget/Labels.dart';

class NotificationTemplate extends StatefulWidget {
  final Map notification;
  const NotificationTemplate(this.notification, {
    Key? key, 
  }) : super(key: key);

  @override
  State<NotificationTemplate> createState() => _NotificationTemplateState();
}

class _NotificationTemplateState extends State<NotificationTemplate> {
  late Map notification;

  @override
  void initState() {
    notification = widget.notification;

    super.initState();
  }

  Future showNotification(alert) async {
    Map data = {
      'id': alert['id'],
      'userType': await isCreator() ? 'creator' : 'user'
    };

    final seen = NotificationController.update( data );

    setState(() {
      notification['status'] = 'read';
    });

    return showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(alert['title'], style: TextStyle(
            color: AppColor.primary,
            fontSize: 15,
            fontWeight: FontWeight.bold
          )),
          content: Text(
            alert['message'],
            style: TextStyle(
              fontSize: 14
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => showNotification(notification),
      child: Container(
        width: double.infinity,
        height: 80,
        padding: EdgeInsets.fromLTRB (10,10,10,0),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Color(0XFF0D1921),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(100)
              ),
              child: Icon(
                Iconsax.notification,
                size: 16,
                color: Colors.red,
              ),
            ),
            SizedBox(
              width: width - 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Labels.primary(
                        notification['title'],
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                        margin: EdgeInsets.only(bottom: 5),
                      ),
                      Spacer(),
                      if(notification['status'] == 'unread')
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(100)
                        ),
                      )
                    ],
                  ),
                  Text(
                    notification['message'],
                    style: TextStyle(color: const Color(0XFF9A9FA3),
                      fontSize: 12
                    ),
                    maxLines: 2,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}