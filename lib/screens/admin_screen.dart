import 'package:flutter/material.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/screens/manage_products_screen.dart';
import 'package:water_delivery/screens/sign_in_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  static const String id = "admin_screen";

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Administrator"),
        actions: [
          IconButton(onPressed: () {
            Navigator.pushReplacementNamed(context, ManageProductsScreen.id);
          }, icon: Icon(Icons.add_shopping_cart)),
          IconButton(
              onPressed: () {
                context.read<AuthCubit>().signOut().then((value) =>
                    Navigator.of(context)
                        .pushReplacementNamed(SignInScreen.id));
                //если будет ошибка при разлогине, то переход не будет исполняться.
              },
              icon: Icon(Icons.logout)),

        ],
      ),
      body: Column(),
    );
  }
}
