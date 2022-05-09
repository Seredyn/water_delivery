import 'package:cloud_firestore/cloud_firestore.dart';

class WaterUser {
  final String? email;
  final String? phoneNumber;
  final String? name;
  final String? role;
  final String? userID;

  WaterUser({
    this.email,
    this.phoneNumber,
    this.name,
    this.role,
    this.userID,
  });

  WaterUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      )   : email = snapshot.data()?["email"],
        phoneNumber = snapshot.data()?["phoneNumber"],
        name = snapshot.data()?["name"],
        role = snapshot.data()?["role"],
        userID = snapshot.data()?["userID"];

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "email": email,
      if (phoneNumber != null) "phoneNumber": phoneNumber,
      if (name != null) "name": name,
      if (role != null) "role": role,
      if (userID != null) "userID": userID,
    };
  }
}