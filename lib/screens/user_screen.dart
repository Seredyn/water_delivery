import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/create_order_screen.dart';
import 'package:water_delivery/screens/sign_in_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  static const String id = "user_screen";

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {

  _goToCreateOrderScreen () {
    Navigator.of(context).pushNamed(CreateOrderScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UserScreen"),
        actions: [
          IconButton(
              onPressed: () {
                context.read<AuthCubit>().signOut().then((value) => Navigator.of(context).pushReplacementNamed(SignInScreen.id));
                //если будет ошибка при разлогине, то переход не будет исполняться.
              },
              icon: Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton.extended(onPressed: () async {

              await _goToCreateOrderScreen ();

            }, label: Text("Create order")),
          ],
        ),
      ),
    );
  }
}
