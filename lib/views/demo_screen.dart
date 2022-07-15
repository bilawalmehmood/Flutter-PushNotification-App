import 'package:flutter/material.dart';

class DemoScreen extends StatelessWidget {
  final String phone;
  const DemoScreen({Key? key, required this.phone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Notification')),
      body: Center(
        child: Text('this is $phone'),
      ),
    );
  }
}
