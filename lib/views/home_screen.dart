import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pushnotification/views/demo_screen.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void getInitialMessage() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      if (message.data["page"] == "email") {
        Get.to(() => const HomeScreen());
      } else if (message.data["page"] == "phone") {
        Get.to(() => DemoScreen(
              phone: message.data["page"],
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid Page!"),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    //* 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method
    getInitialMessage();

    //* 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message.data["page"].toString()),
            duration: const Duration(seconds: 10),
            backgroundColor: Colors.red,
          ));
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
        }
      },
    );

    //* 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("App was opened by a notification"),
            duration: Duration(seconds: 10),
            backgroundColor: Colors.green,
          ));
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: const Center(
        child: Text('push notification'),
      ),
    );
  }
}
