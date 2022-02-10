import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/add_address_screen.dart';
import 'package:water_delivery/screens/add_product_screen.dart';
import 'package:water_delivery/screens/admin_screen.dart';
import 'package:water_delivery/screens/create_order_screen.dart';
import 'package:water_delivery/screens/create_user_screen.dart';
import 'package:water_delivery/screens/driver_screen.dart';
import 'package:water_delivery/screens/manage_products_screen.dart';
import 'package:water_delivery/screens/my_home_page.dart';
import 'package:water_delivery/screens/sign_in_screen.dart';
import 'package:water_delivery/screens/sign_up_screen.dart';
import 'package:water_delivery/screens/user_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  Widget _buildHomeScreen () {

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    String? documentId = FirebaseAuth.instance.currentUser?.uid;

    if (documentId == null) {
      return SignUpScreen();
    }

    if (documentId.isEmpty) {
      return SignUpScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(documentId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot)  {

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return Scaffold(
              body: Center(
                child: Text("Loading..."),
              ),
            );
          }

          if (snapshot.hasError) {
            print("Snapshot have some error");
            return SignUpScreen();
          }

          if (!snapshot.hasData) {
            print("Snapshot does not have a data");
            return SignUpScreen();
          }

          if (snapshot == null) {
            print("Snapshot is null");
            return SignUpScreen();
          }

          // if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          //   Map<String, dynamic>? data = snapshot.data?.data() as Map<String, dynamic>;
          //   String? role = data["role"];
          //   if (role == null) {
          //     return SignUpScreen();
          //   }
          //   if (role == "customer") {
          //     return UserScreen();
          //   }
          //   if (role == "admin") {
          //     return AdminScreen();
          //   }
          //   if (role == "driver") {
          //     return DriverScreen();
          //   }
          //   return SignUpScreen();
          // }

          return SignUpScreen();
        }
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        title: 'Water Delivery',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        //home: const MyHomePage(title: 'MyHomePage'),
        home: _buildHomeScreen(),
        routes: {
          SignInScreen.id : (context) => SignInScreen(),
          SignUpScreen.id : (context) => SignUpScreen(),
          AdminScreen.id : (context) => AdminScreen(),
          DriverScreen.id : (context) => DriverScreen(),
          UserScreen.id : (context) => UserScreen(),
          CreateUserScreen.id : (context) => CreateUserScreen(),
          CreateOrderScreen.id : (context) => CreateOrderScreen(),
          AddAddressScreen.id : (context) => AddAddressScreen(),
          ManageProductsScreen.id : (context) => ManageProductsScreen(),
          AddProductScreen.id : (context) => AddProductScreen(),
        },
      ),
    );
  }
}


