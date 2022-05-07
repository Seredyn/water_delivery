import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/become_supplier_screen.dart';
import 'package:water_delivery/screens/sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  static const String id = "sign_up_screen";

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _email = "";
  String _password = "";

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // это вызывает метод onsave в формах
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      context.read<AuthCubit>().createUserWithEmailAndPassword(
            name: _name,
            email: _email,
            password: _password,
          ).then((value) => context.read<AuthCubit>().navigateToScreenByRole(context));
      //  Не выводится ошибка авторизации и ничего не происходит при ошибке
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
                        "Create new account",
                        textDirection: TextDirection.ltr,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      onSaved: (value) {
                        _name = value!.trim();
                      },
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: "Enter your name",
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_emailFocusNode);
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      focusNode: _emailFocusNode,
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
                    const SizedBox(
                      height: 15,
                    ),
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
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _submit(context);
                      },
                      child: const Text('Создать новый аккаунт'),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        child: Text("Войти в свой аккаунт"),
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(SignInScreen.id);
                    }),
                    SizedBox(height: 50,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(BecomeSupplierScreen.id);
                      },
                      child: const Text('Стать поставщиком'),
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
