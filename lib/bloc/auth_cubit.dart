import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:water_delivery/screens/admin_screen.dart';
import 'package:water_delivery/screens/driver_screen.dart';
import 'package:water_delivery/screens/user_screen.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    //FirebaseAuth auth = FirebaseAuth.instance;
    emit(AuthLoading());

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthSignedIn());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(AuthFailure(message: "Error: user-not-found"));
        print('FirebaseAuthException: No user found for that email.');
      } else if (e.code == 'wrong-password') {
        emit(AuthFailure(message: "Error: wrong-password"));
        print('FirebaseAuthException: Wrong password provided for that user.');
      }
    } catch (error) {
      emit(AuthFailure(
          message: "An error has occurred in signInWithEmailAndPassword()"));
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "userID": userCredential.user!.uid as String,
        "name": name as String,
        "email": email as String,
        "role": "customer" as String,
        "registrationDateTime": DateTime.now(),
      });

      print("Crete user will done");

      userCredential.user!.updateDisplayName(name);

      emit(AuthSignedUp());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(AuthFailure(message: "The password provided is too weak."));
        print('Create user: The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        emit(
            AuthFailure(message: "The account already exists for that email."));
        print('Create user: The account already exists for that email.');
      }
    } catch (e) {
      emit(AuthFailure(message: "An error occurred while creating an account"));
      print(e.toString());
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow ?????????????????? ?????????? ????????????????????????????
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request ???????????????? ???????????? ?????????????????????? ???? ??????????????
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential ?????????????? ?????????? ?????????????? ????????????
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print("==========================================");
        print('Document data: ${documentSnapshot.data()}');
      } else {
        print('Document does not exist on the database');

        String _userName = "";
        String _userEmail = "";
        String _phoneNumber = "";
        if (FirebaseAuth.instance.currentUser!.displayName != null) {
          _userName = FirebaseAuth.instance.currentUser!.displayName!;
        }
        if (FirebaseAuth.instance.currentUser!.email != null) {
          _userEmail = FirebaseAuth.instance.currentUser!.email!;
        }
        if (FirebaseAuth.instance.currentUser!.phoneNumber != null) {
          _phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber!;
        }

        FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          "userID": FirebaseAuth.instance.currentUser!.uid,
          "name": _userName,
          "email": _userEmail,
          "phoneNumber": _phoneNumber,
          "role": "customer",
          "registrationDateTime": DateTime.now(),
        });
      }

      // Once signed in, return the UserCredential ?????????? ?????????? ???????????????????? UserCredential
      return FirebaseAuth.instance.signInWithCredential(credential);
    });
  }

  navigateToScreenByRole(context) async {
    //TODO:- create navigation for all users role
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        String role = documentSnapshot.get("role");
        print("role is: $role");
        if (role == "admin") {
          Navigator.of(context).pushReplacementNamed(AdminScreen.id);
        }
        if (role == "customer") {
          Navigator.of(context).pushReplacementNamed(UserScreen.id);
        }
        if (role == "driver") {
          Navigator.of(context).pushReplacementNamed(DriverScreen.id);
        }
      } else {
        print('Document does not exist on the database');
        Navigator.of(context).pushReplacementNamed(UserScreen.id);
      }
    });
    //Navigator.of(context).pushReplacementNamed(UserScreen.id);
  }

  Future<void> addProduct({
    required String productName,
    required String productDescription,
    required String productSorting,
    required String productCode,
    required double productPrise,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("products")
          .add({}).then((value) {
        FirebaseFirestore.instance.collection("products").doc(value.id).set({
          "productID": value.id as String,
          "productName": productName as String,
          "productDescription": productDescription as String,
          "productSorting": productSorting as String,
          "productCode": productCode as String,
          "productPrise": productPrise as double,
          "productActive": true as bool,
        });
      }).catchError((error) => print("Failed to add new product: $error"));
    } catch (e) {
      print("Some error in addProduct()");
    }
  }

  Future<void> addOrderToFirebase({
    required String orderClientID,
    required String orderProductID,
    required int orderProductQuantity,
    required String orderDeliveryAddressID,
    required double orderPrice,
    required Timestamp orderDeliveryStartTimeStamp,
    required Timestamp orderDeliveryFinishTimeStamp,
  }) async {
    int _orderNumber = 0;
    Stream documentStream = FirebaseFirestore.instance
        .collection('settings')
        .doc('orderSettings')
        .snapshots();
    //int orderNumber = documentStream.
    FirebaseFirestore.instance
        .collection('settings')
        .doc('orderSettings')
        .get()
        .then((value) {
      _orderNumber = value.get("lastOrderNumber") + 1;
    }).then((value) {
      FirebaseFirestore.instance
          .collection('settings')
          .doc('orderSettings')
          .set({
        "lastOrderNumber": _orderNumber as int,
      });
    });

    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .add({}).then((value) {
        print("order begin Writing");

        FirebaseFirestore.instance.collection("orders").doc(value.id).set({
          "orderNumber": _orderNumber as int,
          "orderID": value.id as String,
          "orderClientID": orderClientID as String,
          "orderProductID": orderProductID as String,
          "orderProductQuantity": orderProductQuantity as int,
          "orderDeliveryAddressID": orderDeliveryAddressID as String,
          "orderStatus": "new" as String,
          "orderPrice": orderPrice as double,
          "orderCreateTimeStamp": Timestamp.now(),
          "orderDeliveryStartTimeStamp": orderDeliveryStartTimeStamp,
          "orderDeliveryFinishTimeStamp": orderDeliveryFinishTimeStamp,
        });
        print("Order was added to Firebase");
      }).catchError((error) => print("Failed to add Order: $error"));
    } catch (e) {
      print("Some error hapens when Order was added");
    }
  }

  Future<void> addAddressDelivery({
    required String addressOwnerID,
    required String addressName,
    required String townName,
    required String streetName,
    required String houseNumber,
    required String korpusNumber,
    required String sectionNumber,
    required String apartmentNumber,
    required String entranceNumber, //?????????? ????????????????
    required String floorNumber,
    required String additionalInformAddress,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(addressOwnerID)
          .collection("addresses")
          .add({}).then((value) {
        print("collection Address Added");
        FirebaseFirestore.instance
            .collection("users")
            .doc(addressOwnerID)
            .collection("addresses")
            .doc(value.id)
            .set({
          "addressID": value.id as String,
          "addressOwnerID": addressOwnerID as String,
          "addressName": addressName as String,
          "townName": townName as String,
          "streetName": streetName as String,
          "houseNumber": houseNumber as String,
          "korpusNumber": korpusNumber as String,
          "sectionNumber": sectionNumber as String,
          "apartmentNumber": apartmentNumber as String,
          "entranceNumber": entranceNumber as String,
          "floorNumber": floorNumber as String,
          "additionalInformAddress": additionalInformAddress as String,
        });
        print("Address field added");
      }).catchError((error) => print("Failed to add address: $error"));
    } catch (e) {
      print("Some error hapens when address was added");
    }
  }

  Future<void> deactivateProduct({
    required String productID,
  }) async {
    try {
      FirebaseFirestore.instance
          .collection("products")
          .doc(productID)
          .update({"productActive": false as bool})
          .then((value) => print("Product deactivated"))
          .catchError((error) => print("Can't deactivated product: $error"));
    } catch (e) {
      print("Error when try deactivate product");
    }
  }

  Future<void> activateProduct({
    required String productID,
  }) async {
    try {
      FirebaseFirestore.instance
          .collection("products")
          .doc(productID)
          .update({"productActive": true as bool})
          .then((value) => print("Product activated"))
          .catchError((error) => print("Can't activated product: $error"));
    } catch (e) {
      print("Error when try activate product");
    }
  }

  Future<void> confirmOrderAndSendToDriver({
    required String orderID,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(orderID)
          .update({"orderStatus": "confirmed"})
          .then((value) => print("order confirmed"))
          .catchError((error) => print(
              "This error $error was occurred, when order status try cinfirmed"));
    } catch (e) {
      print("Error: $e was occurred when confirmOrderAndSendToDriver()");
    }
  }

  Future<void> getOrderForDelivery({
    required String orderID,
    required String driverID,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(orderID)
          .update({"orderStatus": "takenDriver"}).then((value) {
        print("Order taken by the driver");
        FirebaseFirestore.instance.collection("orders").doc(orderID).update({
          "driverDeliveryID": driverID as String,
        });
        print("driverDeliveryID: $driverID pushed to Firebase");
      }).catchError((error) =>
              print("Errorr: $error was occured in getOrderForDelivery()"));
    } catch (e) {
      print("Error: $e was occurred in getOrderForDelivery()");
    }
  }

  Future<void> unGetOrderForDelivery({
    required String orderID,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(orderID)
          .update({"orderStatus": "confirmed"}).then((value) {
        print("The driver canceled the delivery of the order");
        FirebaseFirestore.instance
            .collection("orders")
            .doc(orderID)
            .update({
              "driverDeliveryID": FieldValue.delete(),
            })
            .then((value) => print("DriverID deleted from Firebase"))
            .catchError((error) =>
                print("Failed to delete driver's ID property: $error"));
      }).catchError((error) =>
              print("Errorr: $error was occured in getOrderForDelivery()"));
    } catch (e) {
      print("Error: $e was occurred in unGetOrderForDelivery()");
    }
  }

  Future<void> makeOrderAsDelivered({
    required String orderID,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(orderID)
          .update({"orderStatus": "delivered"}).then((value) {
        print("Order delivered");
        DateTime _now = DateTime.now();
        FirebaseFirestore.instance
            .collection("orders")
            .doc(orderID)
            .update({
          "orderDeliveredTimeStamp": _now,
          "orderDeliveredTimeStampMillisecondsSinceEpoch": _now.millisecondsSinceEpoch
        })
            .then((value) => print("Order delivered timestamp added"))
            .catchError((error) =>
            print("Failed to Order delivered timestamp added: $error"));
      }).catchError((error) =>
          print("Errorr: $error was occured in makeOrderAsDelivered()"));
    } catch (e) {
      print("Error: $e in makeOrderAsDelivered()");
    }
  }
}
