import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:water_delivery/screens/select_address_delivery.dart';
import 'package:water_delivery/screens/select_product_id_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  static const String id = "create_order_screen";

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  //Тут объявляются динамические переменные

  late String checkedAddressID;
  late String currentUserId;
  late String addressName;
  late String checkedProductID;
  late String productName;
  late int quantity;
  late double productPrise;
  late double orderPrise;

  late List<String> waitingTimeHourStartList;
  late List<String> waitingTimeMinutesStartList;
  late List<String> waitingTimeHourFinishList;
  late List<String> waitingTimeMinutesFinishList;

  //late Map<DropdownMenuItem<int>> waitingTimeHourMap;

  late DateTime nowTime;

  late DateTime waitingTimeFrom;
  late DateTime waitingTimeTo;

  late int starterWaitingTimeHour;
  late int starterWaitingTimeMinutes;

  late String currentWaitingTimeHourStart;
  late String currentWaitingTimeMinutesStart;
  late String currentWaitingTimeHourFinish;
  late String currentWaitingTimeMinutesFinish;

  @override
  void initState() {
    // TODO: implement initState
    //Этот метод вызывается один раз при вставке
    // виджета стфулл в дерево виджетов. тут нужно
    // определять первые значения динамических переменных
    checkedAddressID = "";
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    addressName = "";
    checkedProductID = "";
    productName = "";
    quantity = 1;
    productPrise = 0.0;
    orderPrise = 0.0;

    waitingTimeHourStartList = [
      "9",
      "10",
      "11",
      "12",
      "13",
      "14",
      "15",
      "16",
      "17",
      "18",
      "19",
      "20"
    ];
    waitingTimeMinutesStartList = ["00", "15", "30", "45"];

    waitingTimeHourFinishList = waitingTimeHourStartList;
    waitingTimeMinutesFinishList = waitingTimeMinutesStartList;

    nowTime = DateTime.now();
    waitingTimeFrom = nowTime;
    waitingTimeTo = waitingTimeFrom.add(const Duration(hours: 3));

    currentWaitingTimeHourStart = waitingTimeHourStartList[0];
    currentWaitingTimeMinutesStart = waitingTimeMinutesStartList[0];
    currentWaitingTimeHourFinish = waitingTimeHourStartList.last;
    currentWaitingTimeMinutesFinish = waitingTimeMinutesStartList.last;

    super.initState(); //super.initState() обязательно нужно вызывать
  }

  void _checkTimeToDelivery() {

  }

  void _navigateAndGetAddressDelivery(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final String result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectionAddressDeliveryScreen()));

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Address: $result')));

    checkedAddressID = result;

    //в такой метод setState нужно передавать измененные перемнные,
    // чтоб флаттер понимал факт их изменения и заново вызывал
    //void _navigateAndGetAddressDelivery(BuildContext context)
    //при этом перестраивается весь виджет билда соответственно с новыми
    // значениями переменных

    //DocumentReference doc = FirebaseFirestore.instance.collection('users').doc("currentUserId").collection("addresses").doc("checkedAddressID");
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection("addresses")
        .doc(checkedAddressID)
        .get()
        .then((value) {
      setState(() {
        addressName = value.get("addressName");
      });
    });
  }

  void _navigateAndGetProductID(BuildContext context) async {
    final String result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SelectionProductIDScreen()));

    checkedProductID = result;

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Product: $result')));

    await FirebaseFirestore.instance
        .collection("products")
        .doc(checkedProductID)
        .get()
        .then((value) {
      setState(() {
        productName = value.get("productName");
        productPrise = value.get("productPrise").toDouble();
        orderPrise = productPrise * quantity;
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('orderPrise: $orderPrise')));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Создание заказа"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              Container(
                child: checkedAddressID == ""
                    ? Text("Выберите адрес:",
                        style: Theme.of(context).textTheme.headline5)
                    : Text("Адрес доставки:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
              ),
              // Visibility(
              //   visible: checkedAddressID == "" ? true : false,
              //     child: Text("Выберите адрес:", style: Theme.of(context).textTheme.headline5)),
              Text(
                addressName,
                style: TextStyle(
                  fontSize: 26,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              //Text("Доставить сюда: $checkedAddressID"),
              ElevatedButton(
                child: checkedAddressID == ""
                    ? Text("Выбрать адрес")
                    : Text("Изменить адрес"),
                onPressed: () {
                  _navigateAndGetAddressDelivery(context);
                },
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                child: checkedProductID == ""
                    ? Text("Выберите товар:",
                        style: Theme.of(context).textTheme.headline5)
                    : Text("Выбранный товар:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
              ),
              Text(
                productName,
                style: TextStyle(
                  fontSize: 26,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: checkedProductID == ""
                    ? Container()
                    : Column(
                        children: [
                          Text("Количество:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                child: Text("-"),
                                onPressed: () {
                                  if (quantity <= 1) {
                                    ScaffoldMessenger.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(SnackBar(
                                          content: Text(
                                              "Количество не может быть меньше 1 шт.")));
                                    return;
                                  }
                                  setState(() {
                                    quantity--;
                                    orderPrise = productPrise * quantity;
                                  });
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                child: Text("+"),
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                    orderPrise = productPrise * quantity;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              ElevatedButton(
                child: checkedProductID == ""
                    ? Text("Выбрать товар")
                    : Text("Изменить товар"),
                onPressed: () {
                  _navigateAndGetProductID(context);
                },
              ),

              Container(
                child: checkedProductID == ""
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Стоимость заказа",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child:
                                  Text(orderPrise.toStringAsFixed(2) + " грн.",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                            ),
                          ],
                        ),
                      ),
              ),

              SizedBox(
                height: 30,
              ),

              Text("Время доставки:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "C",
                      style: TextStyle(fontSize: 23),
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: currentWaitingTimeHourStart,
                          icon: Icon(Icons.arrow_downward),
                          style: TextStyle(fontSize: 23, color: Colors.indigo),
                          iconSize: 20,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.indigo,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              currentWaitingTimeHourStart = newValue!;
                              // waitingTimeHourFinishList.clear();
                              // for (int i = int.parse(currentWaitingTimeHourStart) + 2; i <= 19; i++) {
                              //   waitingTimeHourFinishList.add(i.toString());
                              // }
                              // currentWaitingTimeHourFinish = waitingTimeHourFinishList[0];
                            });
                          },
                          items: waitingTimeHourStartList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            ":",
                            style:
                                TextStyle(fontSize: 23, color: Colors.indigo),
                          ),
                        ),
                        DropdownButton<String>(
                          value: currentWaitingTimeMinutesStart,
                          icon: Icon(Icons.arrow_downward),
                          style: TextStyle(fontSize: 23, color: Colors.indigo),
                          iconSize: 20,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.indigo,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              currentWaitingTimeMinutesStart = newValue!;
                            });
                          },
                          items: waitingTimeMinutesStartList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "ДО",
                      style: TextStyle(fontSize: 23),
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: currentWaitingTimeHourFinish,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 20,
                          style: TextStyle(fontSize: 23, color: Colors.indigo),
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.indigo,
                          ),
                          onChanged: (String? newValue) {
                            int check = int.parse(currentWaitingTimeHourFinish) - int.parse(currentWaitingTimeHourStart);
                            if (check < 2) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Время ожидания должно быть более 2-х часов")));
                              setState(() {
                                currentWaitingTimeHourFinish = (int.parse(currentWaitingTimeHourStart) + 2).toString();
                              });
                            } else {
                              setState(() {
                                currentWaitingTimeHourFinish = newValue!;
                              });
                            }
                          },
                          items: waitingTimeHourFinishList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            ":",
                            style:
                                TextStyle(fontSize: 23, color: Colors.indigo),
                          ),
                        ),
                        DropdownButton<String>(
                          value: currentWaitingTimeMinutesFinish,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 20,
                          style: TextStyle(fontSize: 23, color: Colors.indigo),
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.indigo,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              currentWaitingTimeMinutesFinish = newValue!;
                            });
                          },
                          items: waitingTimeMinutesStartList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 30,
              ),
              Text(
                  "Water type <List> or Map with count. Возможность заказать несколько разных баллонов на один адресс"),
              Text("Время ожидания доставки"),
              FloatingActionButton.extended(
                onPressed: () {},
                label: Text("Confirm"),
              ),
              ElevatedButton(
                child: Text("Show SnackBar"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("checkedAddressID: $checkedAddressID")));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
