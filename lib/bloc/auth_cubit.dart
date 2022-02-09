import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    // Trigger the authentication flow Запускаем поток аутентификации
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request Получаем данные авторизации из запроса
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential Создаем новые учетные данные
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
          "phoneNumber" : _phoneNumber,
          "role": "customer",
        });
      }

    // Once signed in, return the UserCredential После входа возвращаем UserCredential
    return FirebaseAuth.instance.signInWithCredential(credential);

    } );

  }

  navigateToScreenByRole (context) {
    //TODO:- create navigation for all users role
      Navigator.of(context).pushReplacementNamed(UserScreen.id);
    }

  Future<void> addAddressDelivery ({
    required String addressOwnerID,
  required String addressName,
  required String townName,
  required String streetName,
  required String houseNumber,
  required String korpusNumber,
  required String sectionNumber,
  required String apartmentNumber,
  required String entranceNumber, //номер подъезда
  required String floorNumber,
  required String additionalInformAddress,
}) async {

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(addressOwnerID)
          .collection("addresses")
          .add({})
          .then((value) {
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

}
