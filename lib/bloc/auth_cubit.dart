import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  }) async {}
}
