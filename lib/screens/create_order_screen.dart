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

    super.initState();//super.initState() обязательно нужно вызывать
  }

  void _navigateAndGetAddressDelivery(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final String result = await Navigator.push(context, MaterialPageRoute(
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
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).collection("addresses").doc(checkedAddressID).get().then((value) {
      setState(() {
        addressName = value.get("addressName");
      });
    });
  }

  void _navigateAndGetProductID (BuildContext context) async {
    final String result = await Navigator.push(context, MaterialPageRoute(
        builder: (context) => SelectionProductIDScreen()));

    checkedProductID = result;

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Product: $result')));

    await FirebaseFirestore.instance.collection("products").doc(checkedProductID).get().then((value) {
      setState(() {
        productName = value.get("productName");
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, )),
              ),
              // Visibility(
              //   visible: checkedAddressID == "" ? true : false,
              //     child: Text("Выберите адрес:", style: Theme.of(context).textTheme.headline5)),
              Text(addressName, style: TextStyle(fontSize: 26,),),
              SizedBox(height: 10,),
              //Text("Доставить сюда: $checkedAddressID"),
              ElevatedButton(
                child: checkedAddressID == ""
                    ? Text("Выбрать адрес")
                    : Text("Изменить адрес"),
                onPressed: () {
                  _navigateAndGetAddressDelivery(context);
                },
              ),
              SizedBox(height: 30,),
              Container(
                child: checkedProductID == ""
                    ? Text("Выберите товар:",
                    style: Theme.of(context).textTheme.headline5)
                    : Text("Выбранный товар:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, )),
              ),
              Text(productName, style: TextStyle(fontSize: 26,),),
              SizedBox(height: 10,),
              ElevatedButton(
                child: checkedProductID == ""
                    ? Text("Выбрать товар")
                    : Text("Изменить товар"),
                onPressed: () {
                  _navigateAndGetProductID (context);
                },
              ),
              SizedBox(height: 30,),




              Text("Address (список всех адресов пользователя для выбора одного)"),
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
