import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:water_delivery/screens/add_address_screen.dart';
import 'package:water_delivery/screens/create_order_screen.dart';
import 'package:water_delivery/screens/sign_in_screen.dart';

class UserScreen extends StatefulWidget {
  UserScreen({Key? key}) : super(key: key);

  static const String id = "user_screen";


  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  _goToCreateOrderScreen() {
    Navigator.of(context).pushNamed(CreateOrderScreen.id);
  }

  _goToAddAddressScreen() {
    Navigator.of(context).pushNamed(AddAddressScreen.id);
  }

  @override
  void initState() {
    // TODO: implement initState
    users.doc(currentUserId).get().then((value) {
      userNameFromFireStore = value.get("name");
    });

    super.initState();
  }


  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String? userNameFromFirebaseAuth = FirebaseAuth.instance.currentUser
      ?.displayName;
  String? userNameFromFireStore;


  @override
  Widget build(BuildContext context) {
    final String currentUserName = userNameFromFireStore ??
        userNameFromFirebaseAuth ?? "";

    final Stream<QuerySnapshot> _addressStream = users
        .doc(currentUserId)
        .collection("addresses")
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("UserScreen"),
        actions: [
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Добро пожаловать,", style: Theme
                    .of(context)
                    .textTheme
                    .headline5,),
                Text(currentUserName, style: Theme
                    .of(context)
                    .textTheme
                    .headline4,),
                SizedBox(height: 15,),
                StreamBuilder<QuerySnapshot>(
                    stream: _addressStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("snapshot has error"),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return Center(
                          child: Text("Loading..."),
                        );
                      }
                      return Container(
                        height: 180,
                        child: ListView.builder(

                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot doc = snapshot.data!.docs[index];

                              return ListTile (
                                leading: Icon(Icons.map),
                                title: Text(doc.get("streetName") + ", " + doc.get("houseNumber") + ", " + doc.get("apartmentNumber")),
                              );
                            }
                        ),
                      );
                    }),
                SizedBox(height: 15,),
                ElevatedButton(
                    onPressed: () async {
                      await _goToAddAddressScreen();
                    },
                    child: Text("Add Address")),
                SizedBox(height: 30,),
                FloatingActionButton.extended(
                    onPressed: () async {
                      await _goToCreateOrderScreen();
                    },
                    label: Text("Create order")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
