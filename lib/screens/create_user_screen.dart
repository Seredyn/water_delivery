
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({Key? key}) : super(key: key);

  static const String id = "create_user_screen";

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;
  String? currentUserPhoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber;
  String? currentUserDisplayName = FirebaseAuth.instance.currentUser!.displayName;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create User"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Text in Column"),
            Text("currentUserId: $currentUserId"),
            Text("currentUserEmail: $currentUserEmail"),
            Text("currentUserPhoneNumber: $currentUserPhoneNumber"),
            Text("currentUserDisplayName: $currentUserDisplayName"),
          ],
        ),
      ),

    );
  }
}
