import 'package:cloud_firestore/cloud_firestore.dart';
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

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');



  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    final Stream<QuerySnapshot> _newOrdersStream = orders
        .where('orderStatus', isEqualTo: "new")
        .snapshots();

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Administrator"),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, ManageProductsScreen.id);
                  },
                  icon: Icon(Icons.add_shopping_cart)),
              IconButton(
                onPressed: () {
                  context.read<AuthCubit>().signOut().then((value) =>
                      Navigator.of(context)
                          .pushReplacementNamed(SignInScreen.id));
                  //если будет ошибка при разлогине, то переход не будет исполняться.
                },
                icon: Icon(Icons.logout),
              ),
            ],
            bottom: TabBar(tabs: [
              Tab(icon: Icon(Icons.directions_car), text: "Новые",),
              Tab(icon: Icon(Icons.directions_transit), text: "Подтвержденные"),
              Tab(icon: Icon(Icons.directions_bike), text: "Выполненные"),
            ]),
          ),
          body: TabBarView(
            children: [
              //Icon(Icons.directions_car),
              SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                    stream: _newOrdersStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("snapshot has error"),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
                        return Center(
                          child: Text("Loading..."),
                        );
                      }
                      if (snapshot.data?.docs.length == 0) {
                        return Column(
                          children: [
                            Text("Нет новых или необработанных заказов."),
                          ],
                        );
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data?.docs.length ?? 0,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot doc =
                            snapshot.data!.docs[index];

                            return ListTile(
                              leading: Icon(Icons.shopping_cart_outlined),
                              title: Text("orderID: " + doc.get("orderID")),
                              subtitle: Text("orderClientID: " + doc.get("orderClientID")),
                              //subtitle: Text("orderClientID: " + doc.get("orderClientID")),
                            );
                          });
                    }),
              ),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ));
  }
}
