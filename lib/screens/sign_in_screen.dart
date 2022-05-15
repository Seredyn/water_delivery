import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/create_user_screen.dart';
import 'package:water_delivery/screens/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  static const String id = "sign_in_screen";

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  String _email = "";
  String _password = "";

  late final FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // это вызывает метод onsave в формах
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      context.read<AuthCubit>().signInWithEmailAndPassword(
            email: _email,
            password: _password,
          ).then((value) => context.read<AuthCubit>().navigateToScreenByRole(context));

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error. Check all Text Fields')));
    }
  }

  //TODO:- Delete sign in like test user
  void _signInLikeUser1 (){
    context.read<AuthCubit>().signInWithEmailAndPassword(
      email: "user1@gmail.com",
      password: "111111"
    ).then((value) => context.read<AuthCubit>().navigateToScreenByRole(context));
  }
  void _signInLikeDriver1 (){
    context.read<AuthCubit>().signInWithEmailAndPassword(
        email: "driver1@gmail.com",
        password: "111111"
    ).then((value) => context.read<AuthCubit>().navigateToScreenByRole(context));
  }
  void _signInLikeAdmin1 (){
    context.read<AuthCubit>().signInWithEmailAndPassword(
        email: "admin1@gmail.com",
        password: "111111"
    ).then((value) => context.read<AuthCubit>().navigateToScreenByRole(context));
  }
  void _signInLikeUser2 (){
    context.read<AuthCubit>().signInWithEmailAndPassword(
        email: "user2@gmail.com",
        password: "111111"
    ).then((value) => context.read<AuthCubit>().navigateToScreenByRole(context));
  }
  void _signInLikeDriver2 (){
    context.read<AuthCubit>().signInWithEmailAndPassword(
        email: "driver2@gmail.com",
        password: "111111"
    ).then((value) => context.read<AuthCubit>().navigateToScreenByRole(context));
  }
  void _signInLikeAdmin2 (){
    context.read<AuthCubit>().signInWithEmailAndPassword(
        email: "admin2@gmail.com",
        password: "111111"
    ).then((value) => context.read<AuthCubit>().navigateToScreenByRole(context));
  }

  Future<void> _signInWithGoogle () async {
    try {
      await context.read<AuthCubit>().signInWithGoogle();

      //await context.read<AuthCubit>().navigateToScreenByRole(context);

    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error in Sign in with Google')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        "Water Delivery",
                        textDirection: TextDirection.ltr,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      child: Text(
                        "Log into your account",
                        textDirection: TextDirection.ltr,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      onSaved: (value) {
                        _email = value!.trim();
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Enter your email",
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      focusNode: _passwordFocusNode,
                      decoration: InputDecoration(
                        labelText: "Enter your password",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return "Password must contain at least 6 characters";
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      onSaved: (value) {
                        _password = value!.trim();
                      },
                      onFieldSubmitted: (_) {
                        _submit(context);
                      },
                    ),
                    const SizedBox(height: 15,),
                    ElevatedButton(
                      child: const Text('Sign In'),
                      onPressed: () {
                        _submit(context);
                      },
                    ),
                    const SizedBox(height: 15,),
                    TextButton(
                        child: Text("Create new account"),
                        onPressed: () {
                          //TODO:- Go to Sign Up Screen
                          Navigator.of(context).pushReplacementNamed(SignUpScreen.id);
                        }),
                    const SizedBox(height: 15,),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //TODO:- Delete TESTS Sign In before Publishing app
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: ElevatedButton(
                                onPressed: () {
                                  _signInLikeUser1();
                                },
                                child: Text("User 1")),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: ElevatedButton(
                                onPressed: () {
                                  _signInLikeDriver1();
                                },
                                child: Text("Driver 1")),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: ElevatedButton(
                                onPressed: () {
                                  _signInLikeAdmin1();
                                },
                                child: Text("Admin 1")),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15,),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //TODO:- Delete TESTS Sign In before Publishing app
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: ElevatedButton(
                                onPressed: () {
                                  _signInLikeUser2();
                                },
                                child: Text("User 2")),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: ElevatedButton(
                                onPressed: () {
                                  _signInLikeDriver2();
                                },
                                child: Text("Driver 2")),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: ElevatedButton(
                                onPressed: () {
                                  _signInLikeAdmin2();
                                },
                                child: Text("Admin 2")),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15,),
                    FloatingActionButton.extended(onPressed: () async {

                      await _signInWithGoogle ();

                    }, label: Text("Lod In With Google")),
                    SizedBox(height: 15,),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
