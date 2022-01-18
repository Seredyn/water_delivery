import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';

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
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error. Check all Text Fields')));
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
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        "Water Delivery",
                        textDirection: TextDirection.ltr,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
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
                    SizedBox(height: 15,),
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
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _submit(context);
                      },
                      child: const Text('Sign In'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        onPressed: () {
                          //TODO:- Go to Sign Up Screen
                        },
                        child: Text("Create new account")),
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
                                  //TODO:- Sign In as test1
                                },
                                child: Text("Test1")),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: ElevatedButton(
                                onPressed: () {
                                  //TODO:- Sign In as test2
                                },
                                child: Text("Test2")),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: ElevatedButton(
                                onPressed: () {
                                  //TODO:- Sign In as test3
                                },
                                child: Text("Test3")),
                          ),
                        ],
                      ),
                    ),
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
