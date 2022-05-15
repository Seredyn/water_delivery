import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:water_delivery/bloc/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:water_delivery/models/order_model.dart';
import 'package:water_delivery/screens/sign_in_screen.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({Key? key}) : super(key: key);

  static const String id = "driver_screen";

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');
  CollectionReference products = FirebaseFirestore.instance.collection('products');

  String currentDriverId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _getOrderForDelivery(String orderID) {
    context
        .read<AuthCubit>()
        .getOrderForDelivery(orderID: orderID, driverID: currentDriverId);
  }

  void _unGetOrderForDelivery(String orderID) {
    context.read<AuthCubit>().unGetOrderForDelivery(orderID: orderID);
  }

  void _orderDelivered(String orderID) {
    context.read<AuthCubit>().makeOrderAsDelivered(orderID: orderID);
  }

  @override
  Widget build(BuildContext context) {

    DateTime _nowTimeDateTime = DateTime.now();
    String _stringToParseBeginOfDay =
        _nowTimeDateTime.year.toString() + "-" +
        _nowTimeDateTime.month.toString().padLeft(2, '0') + "-" +
        _nowTimeDateTime.day.toString().padLeft(2, '0') + " " +
        "00:00:00";
    DateTime _beginOfDayDateTime = DateTime.parse(_stringToParseBeginOfDay);
    //Timestamp _nowTimeStamp = _beginOfDay.millisecondsSinceEpoch;
    Timestamp _beginOfThisDayTimeStamp = Timestamp.fromDate(_beginOfDayDateTime);

    print("_beginOfThisDayTimeStamp: $_beginOfThisDayTimeStamp");

    final Stream<QuerySnapshot> _confirmedOrdersStream =
        orders.where('orderStatus', isEqualTo: "confirmed").snapshots();
    final Stream<QuerySnapshot> _gettingsOrdersStream = orders
        .where('orderStatus', isEqualTo: "takenDriver")
        .where("driverDeliveryID", isEqualTo: currentDriverId)
        .snapshots();
    final Stream<QuerySnapshot> _ordersStreamByMilliseconds = orders
        //.where('orderStatus', isEqualTo: "delivered")
        //.where("driverDeliveryID", isEqualTo: currentDriverId)
        .where("orderDeliveredTimeStampMillisecondsSinceEpoch", isGreaterThanOrEqualTo:  _beginOfDayDateTime.millisecondsSinceEpoch)
        .snapshots();

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Driver"),
            actions: [
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
              Tab(
                icon: Icon(Icons.directions_car),
                text: "Активные",
              ),
              Tab(icon: Icon(Icons.directions_transit), text: "Принятые"),
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
                                                                          _getOrderForDelivery(
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
                                                                          _getOrderForDelivery(
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
                                                                          _getOrderForDelivery(
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
              //Confirm Orders
              Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.5),
                ),
                child: SingleChildScrollView(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _gettingsOrdersStream,
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
                              Text("Нет принятых и недоставленных заказов."),
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
                                                                  Divider(
                                                                    height: 10,
                                                                    thickness:
                                                                        8,
                                                                    color: Colors
                                                                        .indigo,
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
                                                                          _unGetOrderForDelivery(
                                                                              orderID);
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      ElevatedButton(
                                                                        child: Text(
                                                                            "Доставлен"),
                                                                        onPressed:
                                                                            () {
                                                                          String
                                                                              orderID =
                                                                              doc.get("orderID");
                                                                          _orderDelivered(
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
              // Delivered Orders
              Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.4),
                ),
                child: SingleChildScrollView(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _ordersStreamByMilliseconds,
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
                                  "Нет доставленных заказов сегодня."),
                            ],
                          );
                        }
                        // if (snapshot.connectionState == ConnectionState.done) {
                        //   Map<String, dynamic> orderMap = snapshot.data!. as Map<String, dynamic>;
                        // }

                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot doc =
                                  snapshot.data!.docs[index];

                              if (doc.get("driverDeliveryID") != currentDriverId) {
                                return Container();
                              }

                              DateTime _timeStartDelivery = doc
                                  .get("orderDeliveryStartTimeStamp")
                                  .toDate();
                              DateTime _timeFinishDelivery = doc
                                  .get("orderDeliveryFinishTimeStamp")
                                  .toDate();
                              DateTime _timeOrderDelivered =
                                  doc.get("orderDeliveredTimeStamp").toDate();

                              //if (_timeOrderDelivered)

                              return FutureBuilder<DocumentSnapshot>(
                                  future:
                                      users.doc(doc.get("orderClientID")).get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.hasError) {return Text("Something went wrong");}
                                    if (snapshot.hasData && !snapshot.data!.exists) {return Text("Document does not exist");}
                                    if (snapshot.connectionState == ConnectionState.done) { Map<String, dynamic> userMap = snapshot.data!.data()
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
                                              return Text("Something went wrong");
                                            }
                                            if (snapshot.hasData && !snapshot.data!.exists) {
                                              return Text("Document does not exist");
                                            }
                                            if (snapshot.connectionState == ConnectionState.done) {
                                              Map<String, dynamic> addressesMap = snapshot.data!.data() as Map<String, dynamic>;
                                              //return Text("Full Name: ${data['full_name']} ${data['last_name']}");

                                              return FutureBuilder<DocumentSnapshot>(
                                                  future: products
                                                      .doc(doc.get("orderProductID"))
                                                      .get(),
                                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                                    if (snapshot.hasError) {
                                                      return Text("Something went wrong");
                                                    }
                                                    if (snapshot.hasData && !snapshot.data!.exists) {
                                                      return Text("Document does not exist");
                                                    }
                                                    if (snapshot.connectionState == ConnectionState.done) {
                                                      Map<String, dynamic> productsMap = snapshot.data!.data()
                                                              as Map<String, dynamic>;

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
