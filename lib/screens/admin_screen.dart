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
  CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  void _confirmOrder(String orderID) {
    context.read<AuthCubit>().confirmOrderAndSendToDriver(orderID: orderID);
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _newOrdersStream = orders
        //.orderBy("orderNumber") - сортировать по другому полю в запросе нельзя. можно только по тому же полю, что и выборка (ограничение)
        .where('orderStatus', isEqualTo: "new")
        .snapshots();
    final Stream<QuerySnapshot> _confirmedOrdersStream =
        orders.where('orderStatus', isEqualTo: "confirmed").snapshots();
    final Stream<QuerySnapshot> _deliveredOrdersStream =
        orders.where('orderStatus', isEqualTo: "delivered").snapshots();

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Администратор"),
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
            bottom: const TabBar(tabs: [
              Tab(
                icon: Icon(Icons.directions_car),
                text: "Новые",
              ),
              Tab(icon: Icon(Icons.directions_transit), text: "Подтвержденные"),
              Tab(icon: Icon(Icons.directions_bike), text: "Выполненные"),
            ]),
          ),
          body: TabBarView(
            children: [
              //New Orders
              Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.5),
                ),
                child: SingleChildScrollView(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _newOrdersStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("snapshot has error"),
                          );
                        }
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.connectionState == ConnectionState.none) {
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

                              DateTime _timeStartDelivery = doc
                                  .get("orderDeliveryStartTimeStamp")
                                  .toDate();
                              DateTime _timeFinishDelivery = doc
                                  .get("orderDeliveryFinishTimeStamp")
                                  .toDate();

                              return FutureBuilder<DocumentSnapshot>(
                                  future:
                                      users.doc(doc.get("orderClientID")).get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.hasError) {
                                      return Text("Something went wrong");
                                    }
                                    if (snapshot.hasData &&
                                        !snapshot.data!.exists) {
                                      return Text("Document does not exist");
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      Map<String, dynamic> userMap =
                                          snapshot.data!.data()
                                              as Map<String, dynamic>;
                                      //return Text("Full Name: ${data['full_name']} ${data['last_name']}");

                                      return FutureBuilder<DocumentSnapshot>(
                                          future: users
                                              .doc(doc.get("orderClientID"))
                                              .collection("addresses")
                                              .doc(doc.get(
                                                  "orderDeliveryAddressID"))
                                              .get(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                  "Something went wrong");
                                            }
                                            if (snapshot.hasData &&
                                                !snapshot.data!.exists) {
                                              return Text(
                                                  "Document does not exist");
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              Map<String, dynamic>
                                                  addressesMap =
                                                  snapshot.data!.data()
                                                      as Map<String, dynamic>;
                                              //return Text("Full Name: ${data['full_name']} ${data['last_name']}");

                                              return FutureBuilder<
                                                      DocumentSnapshot>(
                                                  future: products
                                                      .doc(doc.get(
                                                          "orderProductID"))
                                                      .get(),
                                                  builder: (BuildContext
                                                          context,
                                                      AsyncSnapshot<
                                                              DocumentSnapshot>
                                                          snapshot) {
                                                    if (snapshot.hasError) {
                                                      return Text(
                                                          "Something went wrong");
                                                    }
                                                    if (snapshot.hasData &&
                                                        !snapshot
                                                            .data!.exists) {
                                                      return Text(
                                                          "Document does not exist");
                                                    }
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      Map<String, dynamic>
                                                          productsMap =
                                                          snapshot.data!.data()
                                                              as Map<String,
                                                                  dynamic>;

                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Container(
                                                          decoration:
                                                          BoxDecoration(
                                                            gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .lightBlueAccent
                                                                    .withOpacity(
                                                                    0.5),
                                                                Colors.amber
                                                                    .withOpacity(
                                                                    0.5),
                                                              ],
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                            ),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                15),
                                                            border: Border.all(
                                                                width: 2.0),
                                                            //borderRadius: BorderRadius.circular(20.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  5),
                                                                          child:
                                                                              Text(
                                                                            doc.get("orderNumber").toString(),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                                          )),
                                                                      Column(
                                                                        children: [
                                                                          Text(
                                                                            _timeStartDelivery.month.toString() +
                                                                                "." +
                                                                                _timeStartDelivery.day.toString(),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                          ),
                                                                          Text(
                                                                            _timeStartDelivery.hour.toString().padLeft(2, '0') +
                                                                                " : " +
                                                                                _timeStartDelivery.minute.toString().padLeft(2, '0'),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        children: [
                                                                          Text(
                                                                            _timeFinishDelivery.month.toString() +
                                                                                "." +
                                                                                _timeFinishDelivery.day.toString(),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                          ),
                                                                          Text(
                                                                            _timeFinishDelivery.hour.toString().padLeft(2, '0') +
                                                                                " : " +
                                                                                _timeFinishDelivery.minute.toString().padLeft(2, '0'),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Icon(Icons
                                                                          .map),
                                                                      Flexible(
                                                                        child: Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                                                            child: Text(
                                                                              addressesMap['addressName'],
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                              textAlign: TextAlign.center,
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Flexible(
                                                                        child: Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                                                            child: Text(
                                                                              productsMap["productName"],
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                              textAlign: TextAlign.center,
                                                                            )),
                                                                      ),
                                                                      Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  5),
                                                                          child:
                                                                              Text(
                                                                            doc.get("orderProductQuantity").toString() +
                                                                                " шт.",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                                          )),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                                                            child: Text(
                                                                              userMap['name'],
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      ElevatedButton(
                                                                        child: Text(
                                                                            "Отмена"),
                                                                        onPressed:
                                                                            () {
                                                                          String
                                                                              orderID =
                                                                              doc.get("orderID");
                                                                          _confirmOrder(
                                                                              orderID);
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      ElevatedButton(
                                                                        child: Text(
                                                                            "На проверку"),
                                                                        onPressed:
                                                                            () {
                                                                          String
                                                                              orderID =
                                                                              doc.get("orderID");
                                                                          _confirmOrder(
                                                                              orderID);
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      ElevatedButton(
                                                                        child: Text(
                                                                            "OK"),
                                                                        onPressed:
                                                                            () {
                                                                          String
                                                                              orderID =
                                                                              doc.get("orderID");
                                                                          _confirmOrder(
                                                                              orderID);
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return Text("Loading");
                                                  });
                                            }
                                            return Text("Loading...");
                                          });
                                    }
                                    return Text("loading...");
                                  });
                            });
                      }),
                ),
              ),
              //Confirmed Orders
              Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.5),
                ),
                child: SingleChildScrollView(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _confirmedOrdersStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("snapshot has error"),
                          );
                        }
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.connectionState == ConnectionState.none) {
                          return Center(
                            child: Text("Loading..."),
                          );
                        }
                        if (snapshot.data?.docs.length == 0) {
                          return Column(
                            children: [
                              Text("Нет подтвержденных заказов."),
                            ],
                          );
                        }
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot doc =
                                  snapshot.data!.docs[index];

                              DateTime _timeStartDelivery = doc
                                  .get("orderDeliveryStartTimeStamp")
                                  .toDate();
                              DateTime _timeFinishDelivery = doc
                                  .get("orderDeliveryFinishTimeStamp")
                                  .toDate();

                              return FutureBuilder<DocumentSnapshot>(
                                  future:
                                      users.doc(doc.get("orderClientID")).get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.hasError) {
                                      return Text("Something went wrong");
                                    }
                                    if (snapshot.hasData &&
                                        !snapshot.data!.exists) {
                                      return Text("Document does not exist");
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      // Map<String, dynamic> userMap =
                                      //     snapshot.data!.data()
                                      //         as Map<String, dynamic>;

                                      return FutureBuilder<DocumentSnapshot>(
                                          future: users
                                              .doc(doc.get("orderClientID"))
                                              .collection("addresses")
                                              .doc(doc.get(
                                                  "orderDeliveryAddressID"))
                                              .get(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                  "Something went wrong");
                                            }
                                            if (snapshot.hasData &&
                                                !snapshot.data!.exists) {
                                              return Text(
                                                  "Document does not exist");
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              // Map<String, dynamic>
                                              //     addressesMap =
                                              //     snapshot.data!.data()
                                              //         as Map<String, dynamic>;
                                              return FutureBuilder<
                                                      DocumentSnapshot>(
                                                  future: users
                                                      .doc(doc
                                                          .get("orderClientID"))
                                                      .get(),
                                                  builder: (BuildContext
                                                          context,
                                                      AsyncSnapshot<
                                                              DocumentSnapshot>
                                                          snapshot) {
                                                    if (snapshot.hasError) {
                                                      return Text(
                                                          "Something went wrong");
                                                    }
                                                    if (snapshot.hasData &&
                                                        !snapshot
                                                            .data!.exists) {
                                                      return Text(
                                                          "Document does not exist");
                                                    }
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      Map<String, dynamic>
                                                          userMap =
                                                          snapshot.data!.data()
                                                              as Map<String,
                                                                  dynamic>;
                                                      //return Text("Full Name: ${data['full_name']} ${data['last_name']}");

                                                      return FutureBuilder<
                                                              DocumentSnapshot>(
                                                          future: users
                                                              .doc(doc.get(
                                                                  "orderClientID"))
                                                              .collection(
                                                                  "addresses")
                                                              .doc(doc.get(
                                                                  "orderDeliveryAddressID"))
                                                              .get(),
                                                          builder: (BuildContext
                                                                  context,
                                                              AsyncSnapshot<
                                                                      DocumentSnapshot>
                                                                  snapshot) {
                                                            if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  "Something went wrong");
                                                            }
                                                            if (snapshot
                                                                    .hasData &&
                                                                !snapshot.data!
                                                                    .exists) {
                                                              return Text(
                                                                  "Document does not exist");
                                                            }
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .done) {
                                                              Map<String,
                                                                      dynamic>
                                                                  addressesMap =
                                                                  snapshot.data!
                                                                          .data()
                                                                      as Map<
                                                                          String,
                                                                          dynamic>;
                                                              //return Text("Full Name: ${data['full_name']} ${data['last_name']}");

                                                              return FutureBuilder<
                                                                      DocumentSnapshot>(
                                                                  future: products
                                                                      .doc(doc.get(
                                                                          "orderProductID"))
                                                                      .get(),
                                                                  builder: (BuildContext
                                                                          context,
                                                                      AsyncSnapshot<
                                                                              DocumentSnapshot>
                                                                          snapshot) {
                                                                    if (snapshot
                                                                        .hasError) {
                                                                      return Text(
                                                                          "Something went wrong");
                                                                    }
                                                                    if (snapshot
                                                                            .hasData &&
                                                                        !snapshot
                                                                            .data!
                                                                            .exists) {
                                                                      return Text(
                                                                          "Document does not exist");
                                                                    }
                                                                    if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .done) {
                                                                      Map<String,
                                                                          dynamic> productsMap = snapshot
                                                                              .data!
                                                                              .data()
                                                                          as Map<
                                                                              String,
                                                                              dynamic>;

                                                                      return Padding(
                                                                        padding:
                                                                            EdgeInsets.all(10),
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                          BoxDecoration(
                                                                            gradient:
                                                                            LinearGradient(
                                                                              colors: [
                                                                                Colors
                                                                                    .lightBlueAccent
                                                                                    .withOpacity(
                                                                                    0.5),
                                                                                Colors.amber
                                                                                    .withOpacity(
                                                                                    0.5),
                                                                              ],
                                                                              begin: Alignment
                                                                                  .topCenter,
                                                                              end: Alignment
                                                                                  .bottomCenter,
                                                                            ),
                                                                            borderRadius:
                                                                            BorderRadius
                                                                                .circular(
                                                                                15),
                                                                            border: Border.all(
                                                                                width: 2.0),
                                                                            //borderRadius: BorderRadius.circular(20.0),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Column(children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Padding(
                                                                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                                                                      child: Text(
                                                                                        doc.get("orderNumber").toString(),
                                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                                                      )),
                                                                                  Column(
                                                                                    children: [
                                                                                      Text(
                                                                                        _timeStartDelivery.month.toString() + "." + _timeStartDelivery.day.toString(),
                                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                                      ),
                                                                                      Text(
                                                                                        _timeStartDelivery.hour.toString().padLeft(2, '0') + " : " + _timeStartDelivery.minute.toString().padLeft(2, '0'),
                                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  Column(
                                                                                    children: [
                                                                                      Text(
                                                                                        _timeFinishDelivery.month.toString() + "." + _timeFinishDelivery.day.toString(),
                                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                                      ),
                                                                                      Text(
                                                                                        _timeFinishDelivery.hour.toString().padLeft(2, '0') + " : " + _timeFinishDelivery.minute.toString().padLeft(2, '0'),
                                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Icon(Icons.map),
                                                                                  Flexible(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                                                                        child: Text(
                                                                                          addressesMap['addressName'],
                                                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                                          textAlign: TextAlign.center,
                                                                                        )),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                                                                        child: Text(
                                                                                          productsMap["productName"],
                                                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                                          textAlign: TextAlign.center,
                                                                                        )),
                                                                                  ),
                                                                                  Padding(
                                                                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                                                                      child: Text(
                                                                                        doc.get("orderProductQuantity").toString() + " шт.",
                                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                                                                        child: Text(
                                                                                          userMap['name'],
                                                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                                                        )),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  ElevatedButton(
                                                                                    child: Text("Отмена"),
                                                                                    onPressed: () {
                                                                                      String orderID = doc.get("orderID");
                                                                                      _confirmOrder(orderID);
                                                                                    },
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  ElevatedButton(
                                                                                    child: Text("На проверку"),
                                                                                    onPressed: () {
                                                                                      String orderID = doc.get("orderID");
                                                                                      _confirmOrder(orderID);
                                                                                    },
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  ElevatedButton(
                                                                                    child: Text("OK"),
                                                                                    onPressed: () {
                                                                                      String orderID = doc.get("orderID");
                                                                                      _confirmOrder(orderID);
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ]),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    return Text(
                                                                        "Loading");
                                                                  });
                                                            }
                                                            return Text(
                                                                "Loading...");
                                                          });
                                                    }
                                                    return Text("loading...");
                                                  });
                                            }
                                            return Text("Loading...");
                                          });
                                    }
                                    return Text("loading...");
                                  });
                            });
                      }),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.4),
                ),
                child: SingleChildScrollView(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _deliveredOrdersStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("snapshot has error"),
                          );
                        }
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.connectionState == ConnectionState.none) {
                          return Center(
                            child: Text("Loading..."),
                          );
                        }
                        if (snapshot.data?.docs.length == 0) {
                          return Column(
                            children: [
                              Text(
                                  "Нет принятых и недоставленных заказов заказов."),
                            ],
                          );
                        }

                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot doc =
                                  snapshot.data!.docs[index];

                              DateTime _timeStartDelivery = doc
                                  .get("orderDeliveryStartTimeStamp")
                                  .toDate();
                              DateTime _timeFinishDelivery = doc
                                  .get("orderDeliveryFinishTimeStamp")
                                  .toDate();
                              DateTime _timeOrderDelivered =
                                  doc.get("orderDeliveredTimeStamp").toDate();

                              return FutureBuilder<DocumentSnapshot>(
                                  future:
                                      users.doc(doc.get("orderClientID")).get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.hasError) {
                                      return Text("Something went wrong");
                                    }
                                    if (snapshot.hasData &&
                                        !snapshot.data!.exists) {
                                      return Text("Document does not exist");
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      Map<String, dynamic> userMap =
                                          snapshot.data!.data()
                                              as Map<String, dynamic>;
                                      //return Text("Full Name: ${data['full_name']} ${data['last_name']}");

                                      return FutureBuilder<DocumentSnapshot>(
                                          future: users
                                              .doc(doc.get("orderClientID"))
                                              .collection("addresses")
                                              .doc(doc.get(
                                                  "orderDeliveryAddressID"))
                                              .get(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                  "Something went wrong");
                                            }
                                            if (snapshot.hasData &&
                                                !snapshot.data!.exists) {
                                              return Text(
                                                  "Document does not exist");
                                            }
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              Map<String, dynamic>
                                                  addressesMap =
                                                  snapshot.data!.data()
                                                      as Map<String, dynamic>;
                                              //return Text("Full Name: ${data['full_name']} ${data['last_name']}");

                                              return FutureBuilder<
                                                      DocumentSnapshot>(
                                                  future: products
                                                      .doc(doc.get(
                                                          "orderProductID"))
                                                      .get(),
                                                  builder: (BuildContext
                                                          context,
                                                      AsyncSnapshot<
                                                              DocumentSnapshot>
                                                          snapshot) {
                                                    if (snapshot.hasError) {
                                                      return Text(
                                                          "Something went wrong");
                                                    }
                                                    if (snapshot.hasData &&
                                                        !snapshot
                                                            .data!.exists) {
                                                      return Text(
                                                          "Document does not exist");
                                                    }
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      Map<String, dynamic>
                                                          productsMap =
                                                          snapshot.data!.data()
                                                              as Map<String,
                                                                  dynamic>;

                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .lightBlueAccent
                                                                    .withOpacity(
                                                                        0.5),
                                                                Colors.amber
                                                                    .withOpacity(
                                                                        0.5),
                                                              ],
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            border: Border.all(
                                                                width: 2.0),
                                                            //borderRadius: BorderRadius.circular(20.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  5),
                                                                          child:
                                                                              Text(
                                                                            doc.get("orderNumber").toString(),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                                          )),
                                                                      Column(
                                                                        children: [
                                                                          Text(
                                                                            _timeStartDelivery.month.toString() +
                                                                                "." +
                                                                                _timeStartDelivery.day.toString(),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                          ),
                                                                          Text(
                                                                            _timeStartDelivery.hour.toString().padLeft(2, '0') +
                                                                                " : " +
                                                                                _timeStartDelivery.minute.toString().padLeft(2, '0'),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        children: [
                                                                          Text(
                                                                            _timeFinishDelivery.month.toString() +
                                                                                "." +
                                                                                _timeFinishDelivery.day.toString(),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                          ),
                                                                          Text(
                                                                            _timeFinishDelivery.hour.toString().padLeft(2, '0') +
                                                                                " : " +
                                                                                _timeFinishDelivery.minute.toString().padLeft(2, '0'),
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Icon(Icons
                                                                          .map),
                                                                      Flexible(
                                                                        child: Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                                                            child: Text(
                                                                              addressesMap['addressName'],
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                              textAlign: TextAlign.center,
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Flexible(
                                                                        child: Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                                                            child: Text(
                                                                              productsMap["productName"],
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                              textAlign: TextAlign.center,
                                                                            )),
                                                                      ),
                                                                      Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  5),
                                                                          child:
                                                                              Text(
                                                                            doc.get("orderProductQuantity").toString() +
                                                                                " шт.",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                                          )),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                                                            child: Text(
                                                                              userMap['name'],
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Divider(
                                                                    height: 20,
                                                                    thickness:
                                                                        5,
                                                                    color: Colors
                                                                        .indigo,
                                                                  ),
                                                                  Text(
                                                                    "Доставлен " +
                                                                        _timeOrderDelivered
                                                                            .day
                                                                            .toString() +
                                                                        "." +
                                                                        _timeOrderDelivered
                                                                            .month
                                                                            .toString()
                                                                            .padLeft(2,
                                                                                '0') +
                                                                        " в " +
                                                                        _timeOrderDelivered
                                                                            .hour
                                                                            .toString()
                                                                            .padLeft(2,
                                                                                '0') +
                                                                        ":" +
                                                                        _timeOrderDelivered
                                                                            .minute
                                                                            .toString()
                                                                            .padLeft(2,
                                                                                '0'),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return Text("Loading");
                                                  });
                                            }
                                            return Text("Loading...");
                                          });
                                    }
                                    return Text("loading...");
                                  });
                            });
                      }),
                ),
              ),
            ],
          ),
        ));
  }
}
