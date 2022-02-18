import 'package:flutter/material.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  static const String id = "create_order_screen";

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Order"),
      ),
      body: Column(children: [
        Text ("Address (список всех адресов пользователя для выбора одного)"),
        Text ("Water type <List> or Map with count. Возможность заказать несколько разных баллонов на один адресс"),
        Text ("Время ожидания доставки"),
        FloatingActionButton.extended(
          onPressed: () {},
          label: Text("Confirm"),
        ),
      ],),
    );
  }
}
