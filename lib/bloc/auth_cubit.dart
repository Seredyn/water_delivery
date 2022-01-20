import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      print ("Crete user will done");

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


}
