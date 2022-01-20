import 'package:flutter/material.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({Key? key}) : super(key: key);

  static const String id = "driver_screen";

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DriverScreen"),
      ),
      body: Center(),
    );
  }
}
